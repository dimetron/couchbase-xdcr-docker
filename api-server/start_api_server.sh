#!/bin/bash

cd cb-java

export node_ip=$(docker-machine ip node-$1-master)

mvn clean install
mvn spring-boot:run \
	-Drun.arguments="--spring.couchbase.bucket.name=amsscache,--spring.couchbase.bootstrap-hosts=$node_ip"