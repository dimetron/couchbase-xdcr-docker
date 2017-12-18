#!/bin/sh

echo ====================================================== create cluster $1
for node in master master-backup 01 02 03
do
  echo ++ create cluster node-$1-$node

  docker-machine \
    create \
    -d virtualbox \
    --virtualbox-cpu-count "1" \
    --virtualbox-memory "512"  \
    --virtualbox-no-share \
    node-$1-$node

    #for couchbase persistance each node will use persistent volume
    docker-machine ssh node-$1-$node sudo  mkdir -p /opt/couchbase/var
done