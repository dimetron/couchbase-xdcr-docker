#!/bin/bash

for i in {1..1000}; do
	curl -m1 -sS -u Administrator:password http://192.168.99.100:8091/nodeStatuses | xargs -L 1 echo A-$(date +'[%Y-%m-%d %H:%M:%S]') $1; 
	curl -m1 -sS -u Administrator:password http://192.168.99.105:8091/nodeStatuses | xargs -L 1 echo B-$(date +'[%Y-%m-%d %H:%M:%S]') $1; 
	sleep 1; 
done


