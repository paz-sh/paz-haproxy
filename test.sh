#!/bin/bash -e
alias fig='docker-compose'

PAZ_IP=${DOCKER_HOST:-$(ip route get 1 | awk '{print $NF;exit}')}

echo PAZ_IP $PAZ_IP
sed -E "s/(ETCD_ADVERTISE_CLIENT_URLS)=.*/\1=http:\/\/${PAZ_IP}:2379/g" -i.bak fig.yml 

fig stop
fig build
fig up -d

echo Waiting for haproxy to come up...
until ! $(fig ps | grep haproxy_1 | grep " Up ") > /dev/null 2>&1; do sleep 1; done
echo Fig is up

etcdctl --peers=$PAZ_IP:2379 mkdir /paz/config
etcdctl --peers=$PAZ_IP:2379 set /paz/config/domain lukeb0nd.com
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

mv fig.yml.bak fig
