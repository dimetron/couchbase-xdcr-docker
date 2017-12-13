#!/bin/sh
echo "=== stop couchbase on cluster A ==="
eval "$(docker-machine env --swarm swarm-master-A)"
docker-compose down
sleep 5
docker ps 

echo "=== stop couchbase on cluster B ==="
eval "$(docker-machine env --swarm swarm-master-B)"
docker-compose down
sleep 5
docker ps 

echo "=== start couchbase on cluster A ==="
eval "$(docker-machine env --swarm swarm-master-A)"
docker-compose scale db=3

echo "=== start couchbase on cluster B ==="
eval "$(docker-machine env --swarm swarm-master-B)"
docker-compose scale db=3

sleep 30
echo "=== STATUS ==="
eval "$(docker-machine env --swarm swarm-master-A)"
docker-compose ps

echo "=== STATUS ==="
eval "$(docker-machine env --swarm swarm-master-B)"
docker-compose ps

echo "=== Add nodes to the cluster A ==="
./create-couchbase-cluster.sh A

echo "=== add nodes to the cluster B ==="
./create-couchbase-cluster.sh B

echo "=== Setup Replication between cluster A -> B ==="
./setup-xdcr.sh A B

echo "=== Setup Replication between cluster B -> A ==="
./setup-xdcr.sh B A