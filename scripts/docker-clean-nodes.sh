#/bin/bash

if [ "$2" == "clean" ]; then
	for node in 01 02 03 master master-backup 
	do
	  docker-machine rm -f node-$1-$node 2>/dev/null 
	done
	echo ====================================================================
	docker-machine ls
	echo ====================================================================
fi

