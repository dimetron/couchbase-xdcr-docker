#!/bin/sh

echo "=== remove previous machines ==="
docker-machine rm  -f swarm-node-B-01 swarm-node-B-02
docker-machine rm  -f swarm-node-A-01 swarm-node-A-02
docker-machine rm  -f swarm-master-A swarm-master-B 

echo "=== create cluster A ==="
./create-docker-swarm-cluster.sh A

echo "=== create cluster B ==="
./create-docker-swarm-cluster.sh B

echo "=== list of machines ==="
docker-machine ls

echo "=== list of machines ==="
docker-machine ls

echo "=== list of servers ==="
docker ps

echo "=== node A01 ==="
docker-machine inspect swarm-node-A-01 | jq ".Driver.IPAddress"

echo "=== node B01 ==="
docker-machine inspect swarm-node-B-01 | jq ".Driver.IPAddress"

