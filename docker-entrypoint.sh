#!/bin/bash

export CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}
touch ~/.my.cnf
echo "[client]
user=root
password=$MYSQL_ROOT_PASSWORD" > ~/.my.cnf
chmod 600 ~/.my.cnf

do_registry () {
  if [[ "$1"=="0" ]]; then
    register_address="mysql-main.$ENV_CLUSTER_NAMESPACE.svc.cluster.local"
  else
    register_address="mysql-ro.$ENV_CLUSTER_NAMESPACE.svc.cluster.local"
  fi
  echo $register_address
  consul services deregister -address=$register_address -name=mysql.npool.top -port=3306 || true
  consul services register -address=$register_address -name=mysql.npool.top -port=3306
}

prev_state=-1

while true; do
  address_is_ro=$(mysql -e "SELECT @@global.super_read_only;" | tail -n1)
  if [[ ! $address_is_ro -eq $prev_state ]]; then
    do_registry $address_is_ro
    if [ ! $? -eq 0 ]; then
      echo "\nFAIL TO REGISTER ME TO CONSUL\n"
    fi
    prev_state=$address_is_ro
  fi
  echo $address_is_ro
  sleep 1
done




/usr/local/bin/docker-entrypoint-inner.sh $@
