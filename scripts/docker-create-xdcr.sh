#!/bin/sh

export MASTER_IP_1=$(docker-machine ip node-$1-master)
export MASTER_IP_2=$(docker-machine ip node-$2-master)

export CB_CLI="docker-machine ssh node-$1-master docker run --rm arungupta/couchbase couchbase-cli"
export CB_USER=Administrator
export CB_PASSWORD=password
export CB_AUTH="--user $CB_USER --password $CB_PASSWORD --cluster-name=cluster$1 --cluster=$MASTER_IP_1:8091"


$CB_CLI xdcr-setup $CB_AUTH \
--create --xdcr-cluster-name=cluster$2 --xdcr-hostname=$MASTER_IP_2:8091 \
--xdcr-username=$CB_USER --xdcr-password=$CB_PASSWORD --xdcr-demand-encryption=0

$CB_CLI xdcr-replicate $CB_AUTH \
 --create --xdcr-cluster-name=cluster$2 --xdcr-from-bucket=amsscache --xdcr-to-bucket=amsscache
