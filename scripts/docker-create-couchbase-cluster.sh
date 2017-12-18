#!/bin/sh

echo ======================================== start couchbase $1 on every node ============================

# https://docs.docker.com/engine/reference/commandline/service_create/#options

eval $(docker-machine env node-$1-master)
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
 
sleep 30
echo =====================================================================================================
docker service ps couchbase
echo =====================================================================================================