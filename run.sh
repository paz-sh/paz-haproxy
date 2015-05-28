#!/bin/sh -ex

NODE=$ETCD

function cleanup {
  /etc/init.d/haproxy stop
  /etc/init.d/rsyslog stop
  pkill confd
  exit 0
}

cat >/etc/confd/conf.d/haproxy.toml <<EOF
[template]
keys = [
  "/paz/services",
  "/paz/config/domain"
]
owner = "root"
mode = "0644"
src = "haproxy.cfg.tmpl"
dest = "/etc/haproxy/haproxy.cfg"
check_cmd = "/usr/sbin/haproxy -c -f {{ .src }}"
reload_cmd = "cat /etc/haproxy/haproxy.cfg; /etc/init.d/haproxy reload"
EOF

cat >/etc/confd/templates/haproxy.cfg.tmpl <<EOF
global
    log 127.0.0.1 local0 notice
    maxconn 256
    stats socket /tmp/haproxy.sock

defaults
    log global
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    default-server weight 1

frontend http-in
    bind *:80{{ range \$serviceName := lsdir "/paz/services" }}
    acl subdom_{{ \$serviceName }} hdr(host) -i {{ \$serviceName }}.paz{{ with \$domain := getv "/paz/config/domain" }} hdr(host) -i {{ \$serviceName }}.{{ \$domain }}{{ end }}
    use_backend backend-{{ . }} if subdom_{{ . }}{{ end }}{{ range \$path := gets "/paz/services/*" }}
    acl subdom_{{ base \$path.Key }} hdr(host) -i {{ base \$path.Key }}.paz{{ with \$domain := getv "/paz/config/domain" }} hdr(host) -i {{ base \$path.Key }}.{{ \$domain }}{{ end }}
    use_backend backend-{{ base .Key }} if subdom_{{ base .Key }}{{ end }}
{{ range \$serviceName := lsdir "/paz/services" }}
backend backend-{{ \$serviceName }}
    balance roundrobin{{ \$svcpath := (printf "/paz/services/%s" \$serviceName) }}{{ range \$version := lsdir \$svcpath }}{{ \$versionpath := (printf "%s/%s" \$svcpath \$version) }}{{ range \$instance := ls \$versionpath }}{{ \$finalpath := (printf "%s/%s" \$versionpath \$instance) }}
    server {{ \$serviceName }}-v{{ \$version }}-{{ \$instance }} {{ getv \$finalpath }}{{ end }}{{ end }}
{{ end }}
{{ range gets "/paz/services/*" }}
backend backend-{{ base .Key }}
    server {{ base .Key }} {{ .Value }}
{{ end }}
listen stats :1936
    mode http
    stats enable
    stats uri /
EOF


# sometimes it can take a while to 'find' etcd
while [[ $(curl -s $NODE/v2/keys/ -o /dev/null) -ne 0 ]];
do
  sleep 1
done

# start haproxy in bg and tail logs out to stdout
/usr/sbin/service rsyslog start
/etc/init.d/haproxy start
tail -f /var/log/syslog &

exec /usr/bin/confd -interval 5 -node $NODE -debug &

trap cleanup SIGTERM SIGINT

# Expose the unix domain socket to the outside world
socat TCP-LISTEN:1996,reuseaddr,fork UNIX-CLIENT:/tmp/haproxy.sock > /dev/null&

while true; do # Iterate to keep job running.
  sleep 1 # Don't sleep too long as signals will not be handled during sleep.
done
