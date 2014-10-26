#!/bin/bash

set -e
source $(dirname $0)/provision-config.sh

if [ ! -f "/var/salt-vagrant-setup" ]; then
  mkdir -p /etc/salt/minion.d
  echo "master: $MASTER_NAME" > /etc/salt/minion.d/master.conf

  cat <<EOF >/etc/salt/minion.d/grains.conf
grains:
  master_ip: $MASTER_IP
  minion_ips: $MINION_IPS
  roles:
    - salt-master
EOF

  # Configure the salt-master
  # Auto accept all keys from minions that try to join
  mkdir -p /etc/salt/master.d
  cat <<EOF >/etc/salt/master.d/auto-accept.conf
open_mode: True
auto_accept: True
EOF

  cat <<EOF >/etc/salt/master.d/fileserver.conf
fileserver_backend:
  - roots
EOF

  cat <<EOF >/etc/salt/master.d/reactor.conf
# React to new minions starting by running highstate on them.
reactor:
  - 'salt/minion/*/start':
    - /srv/reactor/start.sls
EOF

  curl -sS -L https://bootstrap.saltstack.com | sh -s -- -M
  
  # a file we touch to state that base-setup is done
  echo "Salt configured" > /var/salt-vagrant-setup
  salt-call state.highstate
fi
