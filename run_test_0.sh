#!/bin/sh
cd ./scripts/ && chmod +x *.sh

docker-machine ssh node-0-master docker service rm couchbase
docker-machine ssh node-0-master docker swarm leave --force
docker-machine ssh node-0-master sudo  rm -rf /opt/couchbase/var

if [ "$1" == "clean" ]; then
   docker-machine rm -f node-0-master  2>/dev/null 
fi

docker-machine    \
	create 		  \
    -d virtualbox \
    --virtualbox-cpu-count "1" \
    --virtualbox-memory "512"  \
    --virtualbox-no-share      \
	node-0-master

#for couchbase persistance each node will use persistent volume
docker-machine ssh node-0-master sudo  mkdir -p /opt/couchbase/var

echo ====================================================================
docker-machine ls
echo ====================================================================

export master_ip=$(docker-machine ip node-0-master)
docker-machine ssh node-0-master "docker swarm init  --advertise-addr=$master_ip"
docker-machine ssh node-0-master "docker node ls"

eval $(docker-machine env node-0-master)
docker swarm update --task-history-limit 0
docker service create --detach=false --network host --mode global \
 --restart-window 30s \
 --restart-condition any \
 --publish mode=host,target=8091,published=8091 \
 --publish mode=host,target=8092,published=8092 \
 --publish mode=host,target=8093,published=8093 \
 --publish mode=host,target=4369,published=4369 \
 --publish mode=host,target=11210,published=11210 \
 --mount type=bind,source=/opt/couchbase/var,target=/opt/couchbase/var \
 --name couchbase \
 arungupta/couchbase

sleep 10
echo =====================================================================================================
docker service ps couchbase
echo =====================================================================================================

./docker-configure-couchbase-cluster.sh 0 master 0

