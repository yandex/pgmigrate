#!/bin/sh

set -e

chown -R postgres:postgres /dist
mkdir -p /var/log/pogsgresql
chown postgres:postgres /var/log/pogsgresql
sudo -u postgres /usr/lib/postgresql/10/bin/pg_ctl -D /etc/postgresql/10/main -l /var/log/pogsgresql/postgresql-10-main.log start
cd /dist
sudo -u postgres -i tox -c /dist/tox.ini
