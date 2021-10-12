FROM mysql:5.7

RUN mkdir -p /usr/local/bin
RUN mv docker-entrypoint.sh /usr/local/bin/docker-entrypoint-inner.sh

RUN apt-get update -y
RUN apt-get install curl -y

COPY /usr/bin/consul /usr/bin
COPY docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh
