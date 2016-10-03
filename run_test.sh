#!/bin/sh

set -e

chown -R postgres:postgres /dist
mkdir -p /var/log/pogsgresql
chown postgres:postgres /var/log/pogsgresql
sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl -D /etc/postgresql/9.6/main -l /var/log/pogsgresql/postgresql-9.6-main.log start
cd /dist
sudo -u postgres -i tox -c /dist/tox.ini
