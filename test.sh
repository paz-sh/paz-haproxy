#!/bin/bash -ex

ETCD_IP=192.168.59.103
ETCD_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps | grep etcd | awk '{print $1}'))

docker-compose stop
docker-compose build
docker-compose up -d
echo Waiting for haproxy to come up...
until ! $(docker-compose ps | grep haproxy_1 | grep " Up ") > /dev/null 2>&1; do sleep 1; done
echo docker-compose has brough haproxy up

etcdctl --peers=${ETCD_IP}:4001 mkdir /paz/condocker-compose
etcdctl --peers=${ETCD_IP}:4001 set /paz/condocker-compose/domain lukeb0nd.com
etcdctl --peers=${ETCD_IP}:4001 mkdir /paz/services/demo-api/1
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/paz-orchestrator ${ETCD_IP}:9010
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/paz-scheduler ${ETCD_IP}:9020
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/demo-api/1/1 ${ETCD_IP}:9000
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/demo-api/1/2 ${ETCD_IP}:9001
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/demo-api/1/3 ${ETCD_IP}:9002
etcdctl --peers=${ETCD_IP}:4001 mkdir /paz/services/web/1
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/1/1 ${ETCD_IP}:9003
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/1/2 ${ETCD_IP}:9004
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/1/3 ${ETCD_IP}:9005
etcdctl --peers=${ETCD_IP}:4001 mkdir /paz/services/web/2
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/2/1 ${ETCD_IP}:9006
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/2/2 ${ETCD_IP}:9007
etcdctl --peers=${ETCD_IP}:4001 set /paz/services/web/2/3 ${ETCD_IP}:9008
