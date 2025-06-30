#!/bin/bash

######################################################################
# @author      : Hung Nguyen Xuan Pham (hung0913208@gmail.com)
# @file        : release
# @created     : Tuesday Aug 13, 2024 22:19:39 +07
#
# @description :
######################################################################

function prepare() {
  if [ -f /etc/grafana-agent/config.yaml.shenv ]; then
    if ! envsubst < /etc/grafana-agent/config.yaml.shenv > /etc/grafana-agent/config.yaml; then
      echo "Error: failed to generate /etc/grafana-agent/config.yaml" >&2
      exit 1
    fi
  fi

  if [[ ${DISABLE_AUTO_INIT_DATABASE} = "true" ]]; then
    return
  fi

  for i in {0..30}; do
    if mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --silent; then
      break
    else
      echo "Waiting for MySQL to be ready..."
      sleep 1
    fi
  done

  if ! mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --silent; then
    echo "Error: MySQL is not ready" >&2
    mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" --password="$MYSQL_PASSWORD"
    exit 1
  fi

  for script_path in "$1"/*; do
    if [ -f "$script_path" ]; then
      if ! mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$script_path"; then
        echo "Error: Failed to execute $script_path" >&2
        exit 1
      fi
    fi
  done
}

function localtonet() {
  if [ -z "${DOTNET_SYSTEM_GLOBALIZATION_INVARIANT:-}" ]; then
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
  fi

  if [ -n "${LOCALTONET:-}" ]; then
    set -x
    screen -S "localtonet.pid" -dm localtonet authtoken $LOCALTONET
    set +x
  fi
}

function boot() {
  local cmd=$1

  sed -i "s/%%DB_NAME%%/$MYSQL_DATABASE/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_USER%%/$MYSQL_USER/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_PASSWORD%%/$MYSQL_PASSWORD/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_HOST%%/$MYSQL_HOST/g" /var/www/html/wp-config.php
  shift
  exec "$cmd" "$@"
}

CMD=$1
SQL=$2
PORT=$3

shift
shift
shift

prepare "$SQL"
localtonet "$PORT"
boot "$CMD" "$@"
exit $?
