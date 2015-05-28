#!/bin/bash -e
docker-compose stop
docker-compose build
docker-compose up -d
echo Waiting for haproxy to come up...
until ! $(docker-compose ps | grep haproxy_1 | grep " Up ") > /dev/null 2>&1; do sleep 1; done
echo Fig is up
etcdctl --peers=192.168.59.103:4001 mkdir /paz/condocker-compose
etcdctl --peers=192.168.59.103:4001 set /paz/condocker-compose/domain lukeb0nd.com
etcdctl --peers=192.168.59.103:4001 mkdir /paz/services/demo-api/1
etcdctl --peers=192.168.59.103:4001 set /paz/services/paz-orchestrator 192.168.59.103:9010
etcdctl --peers=192.168.59.103:4001 set /paz/services/paz-scheduler 192.168.59.103:9020
etcdctl --peers=192.168.59.103:4001 set /paz/services/demo-api/1/1 192.168.59.103:9000
etcdctl --peers=192.168.59.103:4001 set /paz/services/demo-api/1/2 192.168.59.103:9001
etcdctl --peers=192.168.59.103:4001 set /paz/services/demo-api/1/3 192.168.59.103:9002
etcdctl --peers=192.168.59.103:4001 mkdir /paz/services/web/1
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/1/1 192.168.59.103:9003
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/1/2 192.168.59.103:9004
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/1/3 192.168.59.103:9005
etcdctl --peers=192.168.59.103:4001 mkdir /paz/services/web/2
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/2/1 192.168.59.103:9006
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/2/2 192.168.59.103:9007
etcdctl --peers=192.168.59.103:4001 set /paz/services/web/2/3 192.168.59.103:9008
