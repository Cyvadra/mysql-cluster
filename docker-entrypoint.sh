#!/bin/bash

echo "INSIDE docker-entrypoint.sh ----"

export CONSUL_HTTP_ADDR=${ENV_CONSUL_HOST}:${ENV_CONSUL_PORT}
touch ~/.my.cnf
echo "[client]
user=root
password=$MYSQL_ROOT_PASSWORD" > ~/.my.cnf
chmod 600 ~/.my.cnf

register_address="mysql.$ENV_CLUSTER_NAMESPACE.svc.cluster.local"

loop_registry () {
  prev_state=-1
  echo "."
  while true; do
    address_is_ro=$(mysql --defaults-extra-file=~/.my.cnf -e "SELECT @@global.super_read_only;" | tail -n1)
    if [ ! $? -eq 0 ]; then
      echo "didn't register"
      exit 1
    fi
    if [[ ! $address_is_ro -eq $prev_state ]]; then
      if [[ $address_is_ro -eq 1 ]]; then
        echo "\n -- register as ro \n"
        consul services register -address=$register_address -name="mysql-ro.npool.top" -port=3306
      else
        echo "\n -- register as main \n"
        consul services register -address=$register_address -name="mysql.npool.top" -port=3306
      fi
      if [ ! $? -eq 0 ]; then
        echo "\nFAIL TO REGISTER ME TO CONSUL\n"
        exit 1
      fi
      prev_state=$address_is_ro
    fi
    sleep 2
  done
}


loop_registry&
/usr/local/bin/docker-entrypoint-inner.sh $@
