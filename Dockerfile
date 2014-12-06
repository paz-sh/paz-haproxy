FROM ubuntu:14.04

RUN apt-get update -y && \
    apt-get install --no-install-recommends -qy curl wget build-essential ca-certificates git haproxy socat && \
    sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy

RUN wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.6.0-alpha3/confd-0.6.0-alpha3-linux-amd64
RUN chmod +x /usr/bin/confd
RUN mkdir -p /etc/confd/conf.d
RUN mkdir -p /etc/confd/templates
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD run.sh /usr/bin/run.sh
ADD adjust-weighting.sh /usr/bin/adjust-weighting.sh

EXPOSE 80
EXPOSE 1936
EXPOSE 443
EXPOSE 1996

CMD ["/usr/bin/run.sh"]
