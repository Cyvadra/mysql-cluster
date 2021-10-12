#!/bin/bash

CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT} consul services register -address=mysql.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=mysql.npool.top -port=3306
if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ME TO CONSUL"
  exit 1
fi

echo "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" > /docker-entrypoint-initdb.d/init.sql
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;" >> /docker-entrypoint-initdb.d/init.sql
echo "FLUSH PRIVILEGES;" >> /docker-entrypoint-initdb.d/init.sql

/usr/local/bin/docker-entrypoint-inner.sh $@
