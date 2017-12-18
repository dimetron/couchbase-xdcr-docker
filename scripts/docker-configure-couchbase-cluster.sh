#!/bin/sh

# netstat -lntu - verify ports are listening
# we will run CLI on master node docker

export MASTER_IP=$(docker-machine ip node-$1-master)
export CB_CLI="docker-machine ssh node-$1-master docker run --rm arungupta/couchbase couchbase-cli"
export CB_USER=Administrator
export CB_PASSWORD=password
export CB_AUTH="--user $CB_USER --password $CB_PASSWORD --cluster-name=cluster$1 --cluster=$MASTER_IP:8091"

echo "+++ STEP-1 - Set cluster Name:  cluster$1 $MASTER_IP"

#init node
docker-machine ssh node-$1-master "curl -s -u Administrator:password -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex%2Cfts"
docker-machine ssh node-$1-master "curl -s -u Administrator:password -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=$CB_USER -d password=$CB_PASSWORD"

#setup cluster
$CB_CLI setting-cluster $CB_AUTH

echo "+++ STEP-2 - Create groups"
$CB_CLI group-manage $CB_AUTH --create --group-name=data-$1

echo "+++ STEP-3 - Adding nodes [ $2 $3 $4 $5 ] to the master server"
for node in $2 $3 $4 $5
do
	export NODE_IP=$(docker-machine ip node-$1-$node)
	echo "Node: $node : $NODE_IP"
	$CB_CLI server-add $CB_AUTH \
		--server-add=$NODE_IP \
		--server-add-username=$CB_USER \
		--server-add-password=$CB_PASSWORD \
		--group-name=data-$1
done

$CB_CLI "group-manage --group-name=Group\ 1 --rename=master $CB_AUTH"

echo "+++ STEP-4 - Rebalance nodes"
$CB_CLI  rebalance   $CB_AUTH
sleep 5
$CB_CLI  server-list $CB_AUTH

echo "+++ STEP-5 - Create data bucket with replication == $3"
$CB_CLI bucket-create $CB_AUTH \
	--bucket amsscache \
	--bucket-type=couchbase \
	--bucket-ramsize=200 \
	--bucket-replica=$3 \
	--bucket-priority=high \
	--bucket-eviction-policy=fullEviction \
	--enable-flush=1 \
	--wait

echo ====================================================================
curl -m1 -sS -u Administrator:password http://$MASTER_IP:8091/nodeStatuses | jq
echo ====================================================================


