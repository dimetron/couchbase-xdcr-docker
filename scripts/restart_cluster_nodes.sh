#!/bin/bash

echo Restarting Cluster-A
eval $(docker-machine env node-$1-master)
docker swarm update --task-history-limit 0
docker service update couchbase --force --detach=false
sleep 30
echo =====================================================================================================
docker service ps couchbase
echo =====================================================================================================
sleep 30
curl -s -u Administrator:password http://$(docker-machine ip node-$1-master):8091/nodeStatuses | jq
echo =====================================================================================================
