PRECHECK ()
{

#1) Host name validation
#ssh -t $1 "hostname -f |tr '\n' ' ' ; hostname" 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; date" 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; nslookup $1" 2>/dev/null
#scp -rp /etc/chrony.conf $1:/etc/ 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; cp /etc/chrony.conf /etc/bkp_chrony.conf_20230704 " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; systemctl restart chronyd " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; systemctl status chronyd " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; date " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; systemctl status cloudera-scm-agent " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; systemctl restart cloudera-scm-agent " 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; rpm -e --nodeps  cloudera-manager-agent-7.7.1-31068812.el8.x86_64 cloudera-manager-daemons-7.7.1-31068812.el8.x86_64 " 2>/dev/null

#2) Java installation
#ssh -t $1 "hostname -i ; yum install -y java-1.8.0-openjdk.x86_64" 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; java -version"  2>/dev/null
#read vb
#ssh -t $1 "hostname -i ; yum install -y httpd" 2>/dev/null
#ssh -t $1 "hostname -i |tr '\n' ' ' ; systemctl restart httpd" 2>/dev/null

#3) net-tool instllation for ifconfig command
#ssh -t $1 "hostname -i ; yum install -y net-tools telnet mlocate dstat" 2>/dev/null

#4) umask validation
#ssh -t $1 "hostname -i |tr '\n' ' '; umask" 2>/dev/null

#5) MTU validation
#ssh -t $1 "hostname  -i |tr '\n' ' ' ; ifconfig |grep -B1 10.131 |tr '\n' ' ' ; echo ''"  2>/dev/null
#ssh -t $1 2>/dev/null
## Run below command on each host
###clear
###ifconfig ens4f0 mtu 9000 up
###cd /etc/sysconfig/network-scripts/
###echo "MTU=9000" >> ifcfg-ens4f0
#cat ifcfg-ens4f0
###exit

#6) installation scp, curl, unzip, tar, wget, and gcc
#ssh -t $1 "hostname  -i ; yum install -y gcc unzip"  2>/dev/null

#7) openssl instllation
#ssh -t $1 "hostname  -i ; yum install -y openssl"  2>/dev/null
#ssh -t $1 "hostname  -i ; yum install -y python2"  2>/dev/null
#ssh -t $1 "hostname  -i ; rpm -qa |grep openssl"  2>/dev/null

#8) python-devel instllation
#ssh -t $1 "hostname  -i ; alternatives --set python /usr/bin/python2 " 2>/dev/null
#ssh -t $1 "hostname  -i |tr '\n' ' ' ; python --version" 2>/dev/null

#9) Softlimit & Hard limit of nproc and nfile 65536 to 262144 ## Document Ref:https://docs.cloudera.com/cdp-private-cloud-base/7.1.7/installation/topics/cdpdc-os-requirements.html

#ssh -t $1 2>/dev/null
###clear
###sed -i 's/* soft nproc 65536/* soft nproc 262144/g' /etc/security/limits.conf
###sed -i 's/* hard nproc 65536/* hard nproc 262144/g' /etc/security/limits.conf
###sed -i 's/* soft nofile 65536/* soft nofile 262144/g' /etc/security/limits.conf
###sed -i 's/* hard nofile 65536/* hard nofile 262144/g' /etc/security/limits.conf
#cat /etc/security/limits.conf |tail -5
###exit

#10) krb5-workstation and krb5-lib instllation
#ssh -t $1 "hostname  -i ; yum install -y krb5-workstation krb5-libs"  2>/dev/null
#ssh -t $1 "hostname  -i ; rpm -qa |egrep 'krb5|openldap-clients' " 2>/dev/null

#11) Validate Filesystem
#ssh -t $1 "hostname  -i ;df -Ph |egrep -v 'boot|monitoring_logs|vg_os-root|devtmpfs|tmpfs|Filesystem'|sort -n " 2>/dev/null
#read vb
#clear

#12) Selinux status
#ssh -t $1 "hostname -i |tr '\n' ' '; sestatus" 2>/dev/null

#13) /proc/sys/fs/file-max value should be 1048576
#ssh -t $1 "hostname -i |tr '\n' ' '; cat /proc/sys/fs/file-max" 2>/dev/null

#14) transparent_hugepage should be disabled
#ssh -t $1
###clear
###echo '' >> /etc/rc.local
###echo '# transparent_hugepage should be never' >> /etc/rc.local
###echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
###echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.local
###cat /etc/rc.local |tail -5
###echo never > /sys/kernel/mm/transparent_hugepage/defrag
###echo never > /sys/kernel/mm/transparent_hugepage/enabled
#cat /sys/kernel/mm/transparent_hugepage/enabled
#cat /sys/kernel/mm/transparent_hugepage/defrag

#15) Hostfile for all Node.
#ssh -t $1
#ssh -t $1 "hostname -i |tr '\n' ' ' ; hostname |tr '\n' ' ' ; hostname -f " 2>/dev/null
### awk '{print $1, $2".jio.com", $2}' /tmp/YOUR_FILE_NAME |column -t


#16)hostfile entry for FQDN
#ssh -t $1 "hostname -i |tr '\n' ' '; hostname -f |tr '\n' ' ' ; hostname " 2>/dev/null
#ssh -t $1  2>/dev/null
### hostname -f > /etc/hostname ; cat /etc/hostname
#ssh -t $1 "hostname -f |tr '\n' ' ' ; cat /etc/hostname| hostname -i" 2>/dev/null


##17) rhel8.repo copy to all node
#scp -rp /etc/yum.repos.d/rhel8.repo $1:/etc/yum.repos.d/  2>/dev/null
#scp -rp /etc/resolv.conf $1:/etc/ 2>/dev/null
#scp -rp /etc/sysctl.conf $1:/etc/ 2>/dev/null
#ssh -t $1 "hostname -f |tr '\n' ' ' ; cat /etc/resolv.conf" 2>/dev/null
#ssh -t $1 "hostname -f |tr '\n' ' ' ; cp /etc/sysctl.conf /etc/sysctl.conf_bkp" 2>/dev/null
#ssh -t $1 "hostname -f |tr '\n' ' ' ; sysctl -p " 2>/dev/null


##18) File system validation
#ssh -t $1  2>/dev/null

##19) Mysql Jar copy on all Master node.
#scp -rp /usr/share/java/mysql-connector-j-8.0.33.jar $1:/usr/share/java/mysql-connector-j-8.0.33.jar
#scp -rp /usr/share/java/mysql-connector-java.jar $1:/usr/share/java/mysql-connector-java.jar

##20) kudu pre requisite memkind
#ssh -t $1 "hostname -i ; yum install -y memkind" 2>/dev/null
#ssh -t $1 "hostname -f |tr '\n' ' ' ; df -Ph |grep -i kudu|tr '\n' ' ' ; echo ''" 2>/dev/null

## 21) High load avarage issue need to fix 'vm.swappiness=1' and  'vm.max_map_count=8000000'
#ssh -t $1
###cat /etc/sysctl.conf |grep vm.swappiness ; sed -i 's/vm.swappiness=10/vm.swappiness=1/g' /etc/sysctl.conf ; echo 'vm.max_map_count=8000000' >> /etc/sysctl.conf ; sysctl -p ;echo --; cat /etc/sysctl.conf |egrep 'vm.swappiness|vm.max_map_count' ; sleep 1 ; exit

#ssh -t $1 "hostname -i ; df -Ph | egrep 'data' ; df -Ph | egrep 'data' |wc -l"  2>/dev/null
#ssh -t $1 "hostname -i ; df -Ph /" 2>/dev/null
#read vb
#clear

}
