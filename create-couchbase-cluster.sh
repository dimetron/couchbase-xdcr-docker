export COUCHBASE_CLI=/Applications/Couchbase-Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli
for node in 01 02
do
    $COUCHBASE_CLI \
        server-add \
        --cluster=$(docker-machine ip swarm-master-$1):8091 \
        --user Administrator \
        --password password \
        --server-add=$(docker-machine ip swarm-node-$1-$node) \
        --server-add-username=Administrator \
        --server-add-password=password
done

sleep 5 && echo "=== Creating Cluster$1"

$COUCHBASE_CLI \
	setting-cluster \
	--cluster=$(docker-machine ip swarm-master-$1):8091 \
	--user Administrator \
	--password password \
	--cluster-name=cluster$1

$COUCHBASE_CLI \
    server-list \
    --cluster=$(docker-machine ip swarm-master-$1):8091 \
    --user Administrator \
    --password password \
    --cluster-name=cluster$1

sleep 5 && echo "=== Rebalance"

$COUCHBASE_CLI \
    rebalance \
    --cluster=$(docker-machine ip swarm-master-$1):8091 \
    --user Administrator \
    --password password \
    --cluster-name=cluster$1

#sleep 10 && echo "=== RebalanceStop"
#$COUCHBASE_CLI \
#    rebalance-stop \
#    --cluster=$(docker-machine ip swarm-master-$1):8091 \
#    --user Administrator \
#    --password password  \
#    --cluster-name=cluster$1

$COUCHBASE_CLI \
    bucket-create \
    --bucket amsscache \
    --cluster=$(docker-machine ip swarm-master-$1):8091 \
    --user Administrator \
    --password password \
    --cluster-name=cluster$1 \
    --bucket-type=couchbase \
    --bucket-ramsize=200 \
    --bucket-replica=2 \
    --bucket-priority=high \
    --bucket-eviction-policy=valueOnly \
    --enable-flush=1 \
    --wait


