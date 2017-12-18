#!/bin/sh

echo ======================================== clear docker cluster ========================================

#remove service before 
docker-machine ssh node-$1-master docker service rm couchbase

for node in 01 02 03 master master-backup
do
  docker-machine ssh node-$1-$node 'docker swarm leave --force'
  docker-machine ssh node-$1-$node 'sudo  rm -rf /opt/couchbase/var/   2>/dev/null'
  docker-machine ssh node-$1-$node 'sudo  mkdir -p /opt/couchbase/var/ 2>/dev/null'
done

echo ======================================== starting docker cluster ========================================

export master_ip=$(docker-machine ip node-$1-master)
docker-machine ssh node-$1-master "docker swarm init  --advertise-addr=$master_ip 2>/dev/null" 

export master_token=$(docker-machine ssh node-$1-master docker swarm join-token manager -q)
export worker_token=$(docker-machine ssh node-$1-master docker swarm join-token worker  -q)

echo ======================================== swarm created =======	=========================================
echo TOKENS: 
echo 	manager: $master_token 
echo 	worker : $worker_token
echo ======================================== joining nodes ================================================

for node in 01 02 03
do
  docker-machine ssh node-$1-$node docker swarm join --token $worker_token $master_ip:2377
done

for node in master-backup
do
  docker-machine ssh node-$1-$node docker swarm join --token $master_token $master_ip:2377
done

echo ======================================== swarm status =================================================
docker-machine ssh node-$1-master docker node ls
echo =======================================================================================================
