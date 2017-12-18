#!/bin/bash

docker-machine ssh node-A-master 'docker run --rm -i loadimpact/k6 run --vus 2 --duration 200s -'< script.js