#!/bin/sh

echo "=== remove previous machines ==="
docker-machine rm  -f swarm-node-B-01 swarm-node-B-02
docker-machine rm  -f swarm-node-A-01 swarm-node-A-02

docker-machine rm  -f swarm-master-A swarm-master-B 
docker-machine rm  -f consul-machine

