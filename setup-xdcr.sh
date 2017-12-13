export COUCHBASE_CLI=/Applications/Couchbase-Server.app/Contents/Resources/couchbase-core/bin/couchbase-cli
$COUCHBASE_CLI \
	xdcr-setup \
	--cluster=$(docker-machine ip swarm-master-$1):8091 \
	--user Administrator \
	--password password \
	--create \
	--xdcr-cluster-name=cluster$2 \
	--xdcr-hostname=$(docker-machine ip swarm-master-$2):8091 \
	--xdcr-username=Administrator \
	--xdcr-password=password \
	--xdcr-demand-encryption=0

$COUCHBASE_CLI \
	xdcr-replicate \
	--cluster $(docker-machine ip swarm-master-$1):8091 \
	--xdcr-cluster-name=cluster$2 \
	--user Administrator \
	--password password \
	--create \
	--xdcr-from-bucket=amsscache \
	--xdcr-to-bucket=amsscache

