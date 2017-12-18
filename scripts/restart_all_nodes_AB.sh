#!/bin/bash

echo Restarting Cluster-A
eval $(docker-machine env node-A-master)
docker swarm update --task-history-limit 0
docker service update couchbase --force --detach=false
sleep 30
echo =====================================================================================================
docker service ps couchbase
echo =====================================================================================================
sleep 30
curl -s -u Administrator:password http://192.168.99.100:8091/nodeStatuses | jq
echo =====================================================================================================

echo Restarting Cluster-B
eval $(docker-machine env node-B-master)
docker swarm update --task-history-limit 0
docker service update couchbase --force --detach=false
echo =====================================================================================================
sleep 30
docker service ps couchbase
echo =====================================================================================================
sleep 30
curl -s -u Administrator:password http://192.168.99.100:8091/nodeStatuses | jq
echo =====================================================================================================
