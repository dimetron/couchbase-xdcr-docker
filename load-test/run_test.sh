#!/bin/bash

docker-machine ssh node-$1-master 'docker run --rm -i loadimpact/k6 run --vus 2 --duration 120s -'< script.js