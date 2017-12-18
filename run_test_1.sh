#!/bin/sh
cd ./scripts/ && chmod +x *.sh
	

export NODES='01 02 03 master-backup'

echo "=== create cluster A ==="
./docker-clean-nodes.sh A $1
./docker-create-nodes.sh A
./docker-create-cluster.sh A
./docker-create-couchbase-cluster.sh A
./docker-configure-couchbase-cluster.sh A $NODES