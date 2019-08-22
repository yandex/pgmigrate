#!/bin/sh

set -e

chown -R postgres:postgres /dist
mkdir -p /var/log/pogsgresql
chown postgres:postgres /var/log/pogsgresql
sudo -u postgres /usr/lib/postgresql/${PG_MAJOR}/bin/pg_ctl -D \
    /etc/postgresql/${PG_MAJOR}/main -l \
    /var/log/pogsgresql/postgresql-${PG_MAJOR}-main.log start
cd /dist
sudo -u postgres -i tox -c /dist/tox.ini
