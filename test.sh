#!/bin/bash -e

echo PAZ_IP $PAZ_IP
if [[ -z ${DOCKER_HOST} ]]; then
  PAZ_IP=$(ip route get 1 | awk '{print $NF;exit}')
  sed -E "s/(ETCD_ADVERTISE_CLIENT_URLS)=.*/\1=http:\/\/${PAZ_IP}:2379/g" -i docker-compose-local.yml
else
  # DOCKER_HOST set so assume OSX
  PAZ_IP=$(echo $DOCKER_HOST | cut -d: -f2 | cut -d/ -f3)
  sed -e "s/(ETCD_ADVERTISE_CLIENT_URLS)=.*/\1=http:\/\/${PAZ_IP}:2379/g" -i'' docker-compose-local.yml
fi

docker-compose stop
docker-compose pull
docker-compose build
docker-compose up -d

echo Waiting for haproxy to come up...
until ! $(docker-compose ps | grep haproxy_1 | grep " Up ") > /dev/null 2>&1; do sleep 1; done
echo docker-compose is up

etcdctl --peers=$PAZ_IP:2379 mkdir /paz/condocker-compose
etcdctl --peers=$PAZ_IP:2379 set /paz/condocker-compose/domain lukeb0nd.com
etcdctl --peers=$PAZ_IP:2379 mkdir /paz/services/demo-api/1
etcdctl --peers=$PAZ_IP:2379 set /paz/services/paz-orchestrator 192.168.1.14:9010
etcdctl --peers=$PAZ_IP:2379 set /paz/services/paz-scheduler 192.168.1.14:9020
etcdctl --peers=$PAZ_IP:2379 set /paz/services/demo-api/1/1 192.168.1.14:9000
etcdctl --peers=$PAZ_IP:2379 set /paz/services/demo-api/1/2 192.168.1.14:9001
etcdctl --peers=$PAZ_IP:2379 set /paz/services/demo-api/1/3 192.168.1.14:9002
etcdctl --peers=$PAZ_IP:2379 mkdir /paz/services/web/1
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/1/1 192.168.1.14:9003
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/1/2 192.168.1.14:9004
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/1/3 192.168.1.14:9005
etcdctl --peers=$PAZ_IP:2379 mkdir /paz/services/web/2
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/2/1 192.168.1.14:9006
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/2/2 192.168.1.14:9007
etcdctl --peers=$PAZ_IP:2379 set /paz/services/web/2/3 192.168.1.14:9008
