#!/bin/sh

set -e

chown -R postgres:postgres /dist
mkdir -p /var/log/postgresql
chown postgres:postgres /var/log/postgresql
sudo -u postgres /usr/lib/postgresql/${PG_MAJOR}/bin/pg_ctl -D \
    /etc/postgresql/${PG_MAJOR}/main -l \
    /var/log/postgresql/postgresql-${PG_MAJOR}-main.log start
cd /dist
sudo -u postgres -i tox -c /dist/tox.ini
