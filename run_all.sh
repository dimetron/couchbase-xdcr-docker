#!/bin/sh
cd ./scripts/ && chmod +x *.sh

export NODES='01 02 03 master-backup'

echo "=== create cluster A ==="
./docker-clean-nodes.sh A $1
./docker-create-nodes.sh A
./docker-create-cluster.sh A
./docker-create-couchbase-cluster.sh A
./docker-configure-couchbase-cluster.sh A $NODES

echo "=== create cluster B ==="
# -- cleanup
./docker-clean-nodes.sh B $1
./docker-create-nodes.sh B
./docker-create-cluster.sh B
./docker-create-couchbase-cluster.sh B
./docker-configure-couchbase-cluster.sh B $NODES

echo "=== replica A-::-B ==="
./docker-create-xdcr.sh A B
./docker-create-xdcr.sh B A


