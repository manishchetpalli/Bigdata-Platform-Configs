#!/bin/bash

set -eo pipefail

mongodb_create_users()
{

    echo "Creating users..."

    if [[ -n "$MONGODB_USERNAME" ]] && [[ -n "$MONGODB_PASSWORD" ]] && [[ -n "$MONGODB_DATABASE" ]]; then
        echo "Creating '$MONGODB_USERNAME' user..."

        result=$(mongo <<EOF
db.getSiblingDB('$MONGODB_DATABASE').createUser({ "user" : "$MONGODB_USERNAME", "pwd" : "$MONGODB_PASSWORD", roles: [{ "role" : "root", "db" : "$MONGODB_DATABASE" }]})
EOF
)   echo $result
    fi
}




mongodb_initialize()
{

    echo "Initializing MongoDB..."

    if [[ -n "$MONGODB_REPLICA_SET_NAME" ]] && [[ -n "$MONGODB_SERVER01" ]] && [[ -n "$MONGODB_SERVER02" ]] && [[ -n "$MONGODB_SERVER03" ]]; then

        result=$(mongo <<EOF
rs.initiate({_id : '$MONGODB_REPLICA_SET_NAME', members: [{ _id : 0, host : "$MONGODB_SERVER01" }, { _id : 1, host : "$MONGODB_SERVER02" }, { _id : 2, host : "$MONGODB_SERVER03" }]})
EOF
)
        echo $result
    else
        exit 1
    fi
}

is_mongo_running()
{
    host="$(hostname --ip-address || echo '127.0.0.1')"

    if mongo --quiet "$host/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
        echo "Mongo is running"
    else
        echo "Mongo is not running"
    fi
}

while :
do
    host="$(hostname --ip-address || echo '127.0.0.1')"
    if mongo --quiet "$host/test" --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)'; then
        echo "Mongo is running"
        mongodb_initialize
        mongodb_create_users
        exit 0
    else
        echo "Mongo is not running"
        sleep 5
    fi  
done