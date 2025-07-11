import sys
import yaml # type: ignore
import requests # type: ignore
import logging
import datetime
import consul # type: ignore

# Configure Logging to Print to Stdout (For Airflow)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

logger = logging.getLogger()

# Flink Cluster Endpoints
FLINK_CLUSTERS = {
    "ajiob2b01": "http://IP.IP131.192:32000/ajiob2b01",
    "ajiob2b02": "http://IP.IP131.192:32000/ajiob2b02",
    "ajiob2c01": "http://IP.IP131.192:32000/ajiob2c01",
    "ajiob2c02": "http://IP.IP131.192:32000/ajiob2c02",
    "ajiob2c03": "http://IP.IP131.192:32000/ajiob2c03",
    "fusion": "http://IP.IP131.192:32000/fusion",
    "fusion02": "http://IP.IP131.192:32000/fusion02",
    "fusion03": "http://IP.IP131.192:32000/fusion03",
    "jiomart01": "http://IP.IP131.192:32000/jiomart01",
    "jiomart02": "http://IP.IP131.192:32000/jiomart02",
    "ros01": "http://IP.IP131.192:32000/ros01",
    "ros02": "http://IP.IP131.192:32000/ros02",
    "ros03": "http://IP.IP131.192:32000/ros03",
    "rp2": "http://IP.IP131.192:32000/rp2",
    "abcr3p19": "http://IP.IP131.192:32000/abcr3p19",
    "abcr3p22": "http://IP.IP131.192:32000/abcr3p22",
    "abcr3p33": "http://IP.IP131.192:32000/abcr3p33",
    "abcr3p44": "http://IP.IP131.192:32000/abcr3p44",
    "abcr3p52": "http://IP.IP131.192:32000/abcr3p52",
    "abcr3p51": "http://IP.IP131.192:32000/abcr3p51",
    "abcr3p54": "http://IP.IP131.192:32000/abcr3p54"
    }

# JAR Mapping for Each Cluster
JAR_MAPPING = {
    "ajiob2b01":   "flink_ecomm_core.jar",
    "ajiob2b02":   "flink_ecomm_core.jar",
    "ajiob2c01":   "flink_ecomm_core.jar",
    "ajiob2c02":   "flink_ecomm_core.jar",
    "ajiob2c03":   "flink_ecomm_core.jar",
    "fusion":      "flink_fusion.jar",
    "fusion02":    "flink_fusion02.jar",
    "fusion03":    "flink-rpos-sales.jar",
    "jiomart01":   "flink-ecomm-sales.jar",
    "jiomart02":   "flink-ecomm-sales.jar",
    "ros01":       "flink-rpos-sales.jar", 
    "ros02":       "flink-rpos-sales.jar",
    "ros03":       "flink-rpos-sales.jar", 
    "rp2":         "flink-rp2-sales.jar",  
    "abcr3p19": "flink_abcr3.jar",
    "abcr3p22": "flink_abcr3.jar",
    "abcr3p33": "flink_abcr3.jar",
    "abcr3p44": "flink_abcr3.jar",
    "abcr3p52": "flink_abcr3.jar",
    "abcr3p51": "flink_abcr3.jar",
    "abcr3p54": "flink_abcr3.jar"
    }

# Authentication Credentials
USERNAME = "dlkadmin"
PASSWORD = "dlkadmin#321"

# Fixed Entry Class for All Jobs
ENTRY_CLASS = "com.ril.rra.hana.MainClass"

# Read YAML from Consul 
def read_yaml_from_consul(yaml_file_name):
    c = consul.Consul(host='IP.IP37.163', port=8500, token='4eb5bd5e-5500-9b1f-af41-1da254f11bfa')
    index, data = c.kv.get(f'rradlk/flink_prod_new/{yaml_file_name}')
    if data is None:
        raise ValueError(f"YAML file '{yaml_file_name}' not found in Consul")
    yaml_data = yaml.safe_load(data["Value"])
    return yaml_data

# Get the list of running jobs on Flink cluster
def get_running_jobs(cluster_url):
    """Fetch the list of currently running Flink jobs."""
    response = requests.get(f"{cluster_url}/jobs/overview", auth=(USERNAME, PASSWORD))
    
    if response.status_code != 200:
        logger.error(f"Error fetching running jobs from {cluster_url}: {response.text}")
        return []

    jobs = response.json().get("jobs", [])
    running_jobs = {job["name"] for job in jobs if job["state"] in ["RUNNING", "CREATED"]}

    logger.info(f"Currently running jobs on {cluster_url}: {running_jobs}")
    return running_jobs

#  Get the uploaded JAR ID and its upload timestamp
def get_uploaded_jar_id(cluster_url, jar_name):
    """Find the uploaded JAR ID and its upload timestamp."""
    response = requests.get(f"{cluster_url}/jars", auth=(USERNAME, PASSWORD))
    
    if response.status_code != 200:
        logger.error(f"Error fetching JARs from {cluster_url}: {response.text}")
        sys.exit(1)

    jars = response.json().get("files", [])
    
    if not jars:
        logger.info("No JARs found in Flink UI!")
        sys.exit(1)

    for jar in jars:
        if jar_name in jar["name"]:
            jar_id = jar["id"]
            jar_upload_time = jar["uploaded"]
            jar_upload_date = datetime.datetime.fromtimestamp(jar_upload_time / 1000).strftime('%Y-%m-%d %H:%M:%S')

            logger.info(f"✅ Found JAR: {jar['name']} (ID: {jar_id}) uploaded at {jar_upload_date}")
            return jar_id, jar["name"], jar_upload_date

    logger.info(f"JAR '{jar_name}' not found in uploaded JARs!")
    sys.exit(1)


def submit_flink_job(cluster_url, jar_id, jar_name, job_name, job_args, parallelism):
    """Submit a Flink job using REST API."""
    running_jobs = get_running_jobs(cluster_url)
    
    if job_name in running_jobs:
        logger.info(f"⚠️ Job '{job_name}' is already running on cluster {cluster_url}. Skipping submission.")
        return
    
    submit_url = f"{cluster_url}/jars/{jar_id}/run"
    payload = {
        "entryClass": ENTRY_CLASS,
        "programArgs": job_args,
        "parallelism": parallelism
    }

    logger.info(f"🚀 Submitting job '{job_name}' from JAR '{jar_name}' on cluster {cluster_url}")

    response = requests.post(submit_url, json=payload, auth=(USERNAME, PASSWORD))

    if response.status_code == 200:
        job_id = response.json().get("jobid", "Unknown")
        logger.info(f"✅ Successfully submitted job '{job_name}' (Job ID: {job_id}) from JAR '{jar_name}'")
    else:
        logger.info(f"❌ Failed to submit job '{job_name}' from JAR '{jar_name}': {response.text}")


def main(yaml_file, cluster_name, job_name):
    """Main function to trigger Flink jobs based on YAML config."""
    if cluster_name not in FLINK_CLUSTERS:
        logger.info(f"❌ Cluster '{cluster_name}' not found in config!")
        sys.exit(1)

    cluster_url = FLINK_CLUSTERS[cluster_name]
    jar_name = JAR_MAPPING.get(cluster_name)

    if not jar_name:
        logger.info(f"❌ No JAR configured for cluster '{cluster_name}'")
        sys.exit(1)

    yaml_data = read_yaml_from_consul(yaml_file)

    jobs_to_run = []
    
    for java_app in yaml_data.get("java", []): # type: ignore
        for job in java_app.get("flink_jobs", []):
            if job["group"] == cluster_name and (job_name == "ALL" or job["name"] == job_name):
                jobs_to_run.append(job)

    if not jobs_to_run:
        logger.info(f"❌ No jobs found for cluster '{cluster_name}' with name '{job_name}'!")
        sys.exit(1)

    jar_id, found_jar_name, jar_upload_date = get_uploaded_jar_id(cluster_url, jar_name)
    
    for job in jobs_to_run:
        submit_flink_job(cluster_url, jar_id, found_jar_name, job["name"], job["argument"], job["parallelism"])

if __name__ == "__main__":
    if len(sys.argv) != 4:
        logger.error("Usage: python flink_trigger.py <yaml_file> <cluster_name> <job_name|ALL>")
        sys.exit(1)
    
    yaml_file, cluster_name, job_name = sys.argv[1:]

    logger.info(f"🟢 Starting Flink job trigger for cluster '{cluster_name}', job '{job_name}' using config '{yaml_file}'")

    main(yaml_file, cluster_name, job_name)
