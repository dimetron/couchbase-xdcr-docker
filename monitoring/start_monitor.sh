#!/bin/bash


T1='curl -m1 -sS -u Administrator:password http://192.168.99.100:8091/nodeStatuses | xargs -L 1 echo $(date +''[%Y-%m-%d %H:%M:%S]'') $1'

for i in {1..1000}; do $T1 ; sleep 1; done

