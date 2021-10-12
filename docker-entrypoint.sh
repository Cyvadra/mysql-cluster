#!/bin/bash

consul services register -address=${ENV_SERVICE_NAME}.${ENV_CLUSTER_NAMESPACE}.svc.cluster.local -name=mysql.npool.top -port=3306
if [ ! $? -eq 0 ]; then
  echo "FAIL TO REGISTER ME TO CONSUL"
  exit 1
fi

. /usr/local/bin/docker-entrypoint-inner.sh
