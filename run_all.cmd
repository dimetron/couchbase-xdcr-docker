@echo off

rem =======================================================================================================
rem cluster nodes setup
rem =======================================================================================================

echo ######################################## CLUSTER - A ##################################################
call :docker-clean-nodes A %1
call :docker-create-nodes A
call :docker-clean-cluster A
call :docker-create-cluster A
call :docker-create-couchbase-cluster A
call :docker-configure-couchbase-cluster A

echo ######################################## CLUSTER - B ##################################################
call :docker-clean-nodes B
call :docker-create-nodes B
call :docker-clean-cluster B
call :docker-create-cluster B
call :docker-create-couchbase-cluster B
call :docker-configure-couchbase-cluster B

echo ######################################## REPLICATION (A <-::-> B) #####################################
call :docker-create-xdcr A B
call :docker-create-xdcr B A
echo ###################################### ~ DONE ~ #######################################################
rem main program must end with exit /b or goto :EOF
rem ########################################################################################################
exit /b


:docker-clean-nodes
if NOT "%2" == "clean" exit /b
rem =======================================================================================================
rem all nodes removed from docker-machine
rem =======================================================================================================
echo off
echo ======================================== cleanup ==========================
docker-machine rm  -f node-A-01 node-A-02 node-A-03
docker-machine rm  -f master-A  master-A-backup
docker-machine rm  -f node-B-01 node-B-02 node-B-03
docker-machine rm  -f master-B master-B-backup
exit /b
@rem =======================================================================================================


:docker-clean-cluster
rem =======================================================================================================
rem nodes removed from cluster but vm's are still up
rem =======================================================================================================
rem
echo ======================================== cleanup previous swarm =======================================
docker-machine ssh master-%1 docker service rm couchbase
docker-machine ssh node-%1-01 docker swarm leave --force
docker-machine ssh node-%1-02 docker swarm leave --force
docker-machine ssh node-%1-03 docker swarm leave --force
docker-machine ssh master-%1  docker swarm leave --force
docker-machine ssh master-%1-backup  docker swarm leave --force
exit /b
@rem =======================================================================================================


:docker-create-nodes
rem =======================================================================================================
rem create vm's
rem =======================================================================================================
echo off
set NO_PROXY=/var/run/docker.sock,localhost,127.0.0.1,192.168.99.0/16
set VM_CREATE_CMD=docker-machine create -d virtualbox --virtualbox-cpu-count "1" --virtualbox-memory "512" --virtualbox-no-share --engine-env NO_PROXY=%NO_PROXY% --engine-env HTTP_PROXY=http://genproxy:8080
echo ======================================== creating master-%1 master-%1-backup ==========================
%VM_CREATE_CMD% master-%1
%VM_CREATE_CMD% master-%1-backup
echo ======================================== creating node-%1-01 .. node-%1-03 ============================
echo off
@rem taking one more node to be a master as we require for docker min 3 for 5 nodes
%VM_CREATE_CMD%  node-%1-01
%VM_CREATE_CMD%  node-%1-02
%VM_CREATE_CMD%  node-%1-03

rem create mount points for couchbase persistance
docker-machine ssh master-%1 sudo mkdir -p /opt/couchbase/var
docker-machine ssh master-%1-backup sudo  mkdir -p /opt/couchbase/var
docker-machine ssh node-%1-01 sudo  mkdir -p /opt/couchbase/var
docker-machine ssh node-%1-02 sudo  mkdir -p /opt/couchbase/var
docker-machine ssh node-%1-03 sudo  mkdir -p /opt/couchbase/var

echo ======================================== status of nodes ==============================================
sleep 10
docker-machine ls --filter name=%1
exit /b
@rem =======================================================================================================


:docker-create-cluster
rem =======================================================================================================
rem create docker swarm
rem =======================================================================================================
echo off
echo ======================================== starting docker swarm ========================================
echo off
for /f %%i in ('docker-machine ip master-%1') do set master_ip=%%i
docker-machine ssh master-%1 docker swarm init  --advertise-addr=%master_ip%
for /f %%i in ('docker-machine ssh master-%1 docker swarm join-token manager -q') do set manager_token=%%i
for /f %%i in ('docker-machine ssh master-%1 docker swarm join-token worker -q') do set worker_token=%%i
echo ======================================== docker swarm created =========================================
echo TOKENS: %master_token% - %worker_token%
echo ======================================== joining nodes ================================================
@echo off
docker-machine ssh node-%1-01 docker swarm join --token %worker_token% %master_ip%:2377
docker-machine ssh node-%1-02 docker swarm join --token %worker_token% %master_ip%:2377
docker-machine ssh node-%1-03 docker swarm join --token %worker_token% %master_ip%:2377
docker-machine ssh master-%1-backup  docker swarm join --token %worker_token% %master_ip%:2377
echo ======================================== swarm status =================================================
docker-machine ssh master-%1 docker node ls
@rem =======================================================================================================
echo off
exit /b


:docker-create-couchbase-cluster
rem =======================================================================================================
rem create couchbase cluster
rem =======================================================================================================
echo off
echo ======================================== start couchbase %1 on every node ============================
echo off
call :docker-set-machine master-%1
set PP=
set PP=%PP% --publish mode=host,target=8091,published=8091
set PP=%PP% --publish mode=host,target=8092,published=8092
set PP=%PP% --publish mode=host,target=8093,published=8093
set PP=%PP% --publish mode=host,target=4369,published=4369
set PP=%PP% --publish mode=host,target=11210,published=11210
set PP=%PP% --mount type=bind,source=/opt/couchbase/var,target=/opt/couchbase/var
docker service rm couchbase
docker service create --detach=false --network host --mode global %PP% --name couchbase arungupta/couchbase
sleep 30

echo ======================================== deployment status %1 =========================================
docker service ls
docker service ps couchbase
@rem =======================================================================================================
exit /b


:docker-configure-couchbase-cluster
rem =======================================================================================================
rem configure couchbase cluster using couchbase-cli
rem =======================================================================================================
echo off
echo ======================================== configure couchbase cluster %1 ==============================
echo off
@for /f %%i in ('docker-machine ip node-%1-01') do set node1_ip=%%i
@for /f %%i in ('docker-machine ip node-%1-02') do set node2_ip=%%i
@for /f %%i in ('docker-machine ip node-%1-03') do set node3_ip=%%i
@for /f %%i in ('docker-machine ip master-%1') do set master1_ip=%%i
@for /f %%i in ('docker-machine ip master-%1-backup') do set master2_ip=%%i
echo _MT_%1 - %master1_ip% - %master2_ip%
echo _DT_%1 - %node1_ip% - %node2_ip% - %node3_ip%
echo ========================================
echo off
@rem netstat -lntu - verify ports are listening
@rem we will run CLI on master node docker
set CB_USER=Administrator
set CB_PASSWORD=password
set CB_CLI=docker-machine ssh master-%1 docker run --rm arungupta/couchbase couchbase-cli
set CB_AUTH=--cluster=%master1_ip%:8091 --user Administrator --password password --cluster-name=cluster%1
echo off
rem =====================================================================================================================
echo +++ STEP-1 - Set cluster Name -> cluster%1
rem =====================================================================================================================
%CB_CLI%  setting-cluster %CB_AUTH%
rem =====================================================================================================================
echo +++ STEP-2 - Create groups
rem =====================================================================================================================
%CB_CLI% group-manage %CB_AUTH% --create --group-name=data-%1
rem =====================================================================================================================
echo +++ STEP-3 - Adding nodes to the master server
rem =====================================================================================================================
%CB_CLI% server-add %CB_AUTH% --server-add=%node1_ip% --server-add-username=%CB_USER% --server-add-password=%CB_PASSWORD% --group-name=data-%1
%CB_CLI% server-add %CB_AUTH% --server-add=%node2_ip% --server-add-username=%CB_USER% --server-add-password=%CB_PASSWORD% --group-name=data-%1
%CB_CLI% server-add %CB_AUTH% --server-add=%node3_ip% --server-add-username=%CB_USER% --server-add-password=%CB_PASSWORD% --group-name=data-%1
%CB_CLI% server-add %CB_AUTH% --server-add=%master2_ip% --server-add-username=%CB_USER% --server-add-password=%CB_PASSWORD% --group-name=data-%1
%CB_CLI% group-manage %CB_AUTH% --group-name=Group\ 1 --rename=master
rem %CB_CLI% group-manage %CB_AUTH% --group-name=master --move-servers=%master1_ip%:8091 --services=query --to-group=master --from-group=default
rem =====================================================================================================================
echo off
rem =====================================================================================================================
echo +++ STEP-4 - Rebalance nodes
rem =====================================================================================================================
%CB_CLI%  rebalance   %CB_AUTH%
%CB_CLI%  server-list %CB_AUTH% 
rem =====================================================================================================================
echo +++ STEP-5 - Create data bucket with replication == 3
rem =====================================================================================================================
%CB_CLI% bucket-create %CB_AUTH% --bucket amsscache --bucket-type=couchbase --bucket-ramsize=200 --bucket-replica=3 --bucket-priority=high --bucket-eviction-policy=fullEviction --enable-flush=1 --wait
rem =====================================================================================================================
exit /b


:docker-create-xdcr
rem =======================================================================================================
rem configure create-xdcr from %1 -> %2
rem =======================================================================================================
echo off
echo ======================================== configure replication from %1 to %2 ======================
echo off
@for /f %%i in ('docker-machine ip master-%1') do set master_fr_ip=%%i
@for /f %%i in ('docker-machine ip master-%2') do set master_to_ip=%%i
docker-machine ssh master-%1 docker run --rm arungupta/couchbase couchbase-cli xdcr-setup --cluster=%master_fr_ip%:8091 --user Administrator --password password --create --xdcr-cluster-name=cluster%2 --xdcr-hostname=%master_to_ip%:8091 --xdcr-username=Administrator --xdcr-password=password --xdcr-demand-encryption=0
docker-machine ssh master-%1 docker run --rm arungupta/couchbase couchbase-cli xdcr-replicate --cluster=%master_fr_ip%:8091 --xdcr-cluster-name=cluster%2 --user Administrator --password password --create --xdcr-from-bucket=amsscache --xdcr-to-bucket=amsscache
rem =======================================================================================================
exit /b

:docker-set-machine
rem =======================================================================================================
rem configure docker environment for specific docker-machine
rem =======================================================================================================
@echo off
@for /f "tokens=*" %%i in ('docker-machine env --no-proxy %1') do @%%i
exit /b