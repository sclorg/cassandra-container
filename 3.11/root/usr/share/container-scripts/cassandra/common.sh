#!/bin/bash

set -o pipefail
set -ex

#CASSANDRA_CONF_DIR="/etc/cassandra/"
CASSANDRA_CONF_FILE="cassandra.yaml"

HOSTNAME=$(cat /proc/sys/kernel/hostname)
#IP_ADDRESS=$(cat /etc/hosts | grep $HOSTNAME | awk '{print $1}' | head -n 1)

# usage prints info about required enviromental variables
# if $1 is passed, prints error message containing $1
function usage() {
  if [ $# == 1 ]; then
    echo >&2 "error: $1"
  fi

  echo "
You must specify the following environment variables:
  CASSANDRA_ADMIN_PASSWORD"

  echo "
For more information see /usr/share/container-scripts/cassandra/README.md
within the container or visit https://github.com/sclorg/cassandra-container/."

  exit 1
}

# update cassandra config file (cassandra.yaml) based on the environment variables
# set by the user
function save_env_config_vars() {
  # check whether the user mounted in his own config file
  CONFIG_OWNER=$(ls -l "$CASSANDRA_CONF_DIR" | grep "$CASSANDRA_CONF_FILE" | awk '{print $3}')

  if [ "$CONFIG_OWNER" == "cassandra" ]; then
    # set the seeds for succesfull gossip initialization
    # if the seeds were not set as the environment variable
    if [ -z "$CASSANDRA_SEEDS" ]; then
      # get the ip-address that the cassandra server is going to run on
      #CASSANDRA_SEEDS=$(cassandra -f 2>/dev/null | grep :7000 | cut -d'/' -f2 | cut -d':' -f1)

      # get the hostname of the machine that the cassandra server is going to run on
      CASSANDRA_SEEDS="$HOSTNAME"
    fi

    # alter the seeds in the config file
    sed -ri 's/(- seeds:).*/\1 "'"$HOSTNAME,$CASSANDRA_SEEDS"'"/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"

    # alter the rpc_address to allow external CQL client connections
    sed -ri 's/(rpc_address:).*/\1 '"$HOSTNAME"'/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"

    # alter the listen_address to allow internode communication
    sed -ri 's/(listen_address:).*/\1 '"$HOSTNAME"'/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"

    for yaml in \
      cluster_name \
      disk_optimization_strategy \
      endpoint_snitch \
      num_tokens \
      rpc_address \
      key_cache_size_in_mb \
      concurrent_reads \
      concurrent_writes \
      memtable_allocation_type \
      memtable_cleanup_threshold \
      memtable_flush_writers \
      concurrent_compactors \
      compaction_throughput_mb_per_sec \
      counter_cache_size_in_mb \
      internode_compression \
      gc_warn_threshold_in_ms \
    ; do
      var="CASSANDRA_${yaml^^}"
      val="${!var}"
      if [ "$val" ]; then
        sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"
      fi
    done

    # hidden viariable (not originaly in config file)
    CASSANDRA_AUTO_BOOTSTRAP="${CASSANDRA_AUTO_BOOTSTRAP:-false}"

    echo "auto_bootstrap: ${CASSANDRA_AUTO_BOOTSTRAP}" >> "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"
  fi
}

# wait until the cassandra server accepts cqlsh connections
function wait_for_cql_listener_up() {
  PORT=$(cat "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE" | grep native_transport_port | head -1 | cut -d' ' -f2)
  while ! nc -z $HOSTNAME $PORT; do
    sleep 1
  done
}

# create an 'admin' user with password set by CASSANDRA_ADMIN_PASSWORD environmnet variable
function create_admin_user() {
  # change the config
  sed -ri 's/(^authenticator:).*/\1 PasswordAuthenticator/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"
#  echo config changed

  # start cassandra with authentication
  cassandra >/dev/null &
#  echo starting server

  # add admin super user with CASSANDRA_ADMIN_PASSWORD via the default super user
  while ! cqlsh $HOSTNAME -u cassandra -p cassandra <<< "CREATE ROLE admin WITH PASSWORD = '$CASSANDRA_ADMIN_PASSWORD' \
    AND SUPERUSER = true \
    AND LOGIN = true;" >/dev/null 2>/dev/null; do
      sleep 1
  done
#  echo admin super user created

  # login as admin and drop the default super user
  cqlsh $HOSTNAME -u admin -p "$CASSANDRA_ADMIN_PASSWORD" <<< "DROP ROLE cassandra;" >/dev/null
#  echo cassandra super user dropped

  # shut the cassandra down
  #nodetool stopdaemon #2>/dev/null
  pkill -f 'java.*cassandra'
  sleep 3
#  echo server stopped

  # optionaly create a cqlshrc file with the login information
  # NOT SUPPORTED YET
#  if [ ! -d "/var/lib/cassandra/.cassandra" ]; then
#    mkdir /var/lib/cassandra/.cassandra
#  fi
#  cat << 'EOF' >> /var/lib/cassandra/.cassandra/cqlshrc
#  [authentication]
#  username = admin
#  password = "$CASSANDRA_ADMIN_PASSWORD"
#  EOF
#  chmod 440 /var/lib/cassandra/.cassandra/cqlshrc
#  echo cqlshrc file with the credentials created

  # hide the admin password
  unset CASSANDRA_ADMIN_PASSWORD
#  echo password var dropped

}

# turn on the authorization
function turn_authorization_on() {
  # change the config
  sed -ri 's/(^authorizer:).*/\1 CassandraAuthorizer/' "$CASSANDRA_CONF_DIR$CASSANDRA_CONF_FILE"
#  echo config changed
}

# turn on the JMX authentication using Cassandra's internal authentication and authorization
function turn_on_jmx_authentication() {
  # disable JMX local
  JMX_LOCAL=no
  echo jmx_local: $JMX_LOCAL

# so far this is not working because cassandra-env.sh file is not modifiable (sits in scripts directory)
  # update the config file cassandra-env.sh
  sed -ri 's/^(.*jmxremote\.password)/#\1/' "/usr/share/cassandra/cassandra-env.sh"
  sed -ri 's/^#(.*config=CassandraLogin.*$)/\1/' "/usr/share/cassandra/cassandra-env.sh"
  sed -ri 's/^#(.*auth\.login.*$)/\1/' "/usr/share/cassandra/cassandra-env.sh"
  sed -ri 's/^#(.*AuthorizationProxy.*$)/\1/' "/usr/share/cassandra/cassandra-env.sh"
  echo config updated
}
