#!/bin/sh

./cleanup_all.sh

echo "=== start consul ==="
./start-consul.sh

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

