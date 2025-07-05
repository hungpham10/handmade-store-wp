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
    if mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" -P "${MYSQL_PORT:-3306}" --password="$MYSQL_PASSWORD" --silent; then
      break
    else
      echo "Waiting for MySQL to be ready..."
      sleep 1
    fi
  done

  if ! mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" -P "${MYSQL_PORT:-3306}" --password="$MYSQL_PASSWORD" --silent; then
    echo "Error: MySQL is not ready" >&2
    mysqladmin ping -h "$MYSQL_HOST" -u "$MYSQL_USER" -P "${MYSQL_PORT:-3306}" --password="$MYSQL_PASSWORD"
    exit 1
  fi

  for script_path in "$1"/*; do
    if [ -f "$script_path" ]; then
      if ! mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -P "${MYSQL_PORT:-3306}" --password="$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$script_path"; then
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

  if ! echo "${ENABLE_REMOVING_REDIRECT_CANNONICAL}" | grep "true" &> /dev/null; then
    sed -i "/redirect_canonical/d" /var/www/html/wp-config.php
  fi

  if [ "${HTTP_PROTOCOL}" = "https" ]; then
    sed -i "s/%%FORCE_SSL_ADMIN%%/true/g" /var/www/html/wp-config.php
    sed -i "s/%%FORCE_SSL%%/on/g" /etc/nginx/conf.d/wordpress.conf
  else
    sed -i "s/%%FORCE_SSL_ADMIN%%/false/g" /var/www/html/wp-config.php
    sed -i '/HTTPS/d' /etc/nginx/conf.d/wordpress.conf
    sed -i '/HTTP_X_FORWARDED_PROTO/d' /etc/nginx/conf.d/wordpress.conf
    sed -i '/HTTP_X_FORWARDED_PORT/d' /etc/nginx/conf.d/wordpress.conf
    HTTP_PROTOCOL="http"
  fi
  sed -i "s/%%REDIS_HOST%%/$REDIS_HOST/g"  /var/www/html/wp-config.php
  sed -i "s/%%REDIS_PORT%%/$REDIS_PORT/g"  /var/www/html/wp-config.php
  sed -i "s/%%REDIS_PASSWORD%%/$REDIS_PASSWORD/g"  /var/www/html/wp-config.php
  sed -i "s/%%REDIS_TTL%%/${REDIS_TTL:-300}/g" /var/www/html/wp-config.php
  sed -i "s/%%HTTP_SERVER%%/$HTTP_SERVER/g" /etc/nginx/conf.d/wordpress.conf
  sed -i "s/%%HTTP_PORT%%/$HTTP_PORT/g" /var/www/html/wp-config.php
  sed -i "s/%%WP_HOME%%/${HTTP_PROTOCOL}:\/\/${HTTP_SERVER}:${HTTP_PORT}/g" /var/www/html/wp-config.php
  sed -i "s/%%WP_SITEURL%%/${HTTP_PROTOCOL}:\/\/${HTTP_SERVER}:${HTTP_PORT}/g" /var/www/html/wp-config.php

  sed -i "s/%%DB_NAME%%/$MYSQL_DATABASE/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_USER%%/$MYSQL_USER/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_PASSWORD%%/$MYSQL_PASSWORD/g" /var/www/html/wp-config.php
  sed -i "s/%%DB_HOST%%/$MYSQL_HOST:${MYSQL_PORT:-3306}/g" /var/www/html/wp-config.php
  sed -i "s/%%AUTH_KEY%%/$AUTH_KEY/g" /var/www/html/wp-config.php
  sed -i "s/%%SECURE_AUTH_KEY%%/$SECURE_AUTH_KEY/g" /var/www/html/wp-config.php
  sed -i "s/%%LOGGED_IN_KEY%%/$LOGGED_IN_KEY/g" /var/www/html/wp-config.php
  sed -i "s/%%NONCE_KEY%%/$NONCE_KEY/g" /var/www/html/wp-config.php
  sed -i "s/%%AUTH_SALT%%/$AUTH_SALT/g" /var/www/html/wp-config.php
  sed -i "s/%%SECURE_AUTH_SALT%%/SECURE_AUTH_SALT/g" /var/www/html/wp-config.php
  sed -i "s/%%LOGGED_IN_SALT%%/$LOGGED_IN_SALT/g" /var/www/html/wp-config.php
  sed -i "s/%%NONCE_SALT%%/$NONCE_SALT/g" /var/www/html/wp-config.php
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
