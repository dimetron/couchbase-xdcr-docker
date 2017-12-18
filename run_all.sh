#!/bin/sh
cd ./scripts/ && chmod +x *.sh
	
echo "=== create cluster A ==="
# -- cleanup
./docker-clean-nodes.sh A $1
# -- creat vm nodes and set docker swarm
./docker-create-nodes.sh A
./docker-create-cluster.sh A
./docker-create-couchbase-cluster.sh A
# -- here is couchbase related section
./docker-configure-couchbase-cluster.sh A

echo "=== create cluster B ==="
# -- cleanup
./docker-clean-nodes.sh B $1
# -- creat vm nodes and set docker swarm
./docker-create-nodes.sh B
./docker-create-cluster.sh B
./docker-create-couchbase-cluster.sh B
# -- here is couchbase related section
./docker-configure-couchbase-cluster.sh B

echo "=== list of machines ==="
docker-machine ls
