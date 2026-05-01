# vim:set ft=dockerfile:
FROM ubuntu:resolute

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -d /var/lib/postgresql -g postgres --uid=999 postgres

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y ca-certificates locales && \
    locale-gen en_US.UTF-8
ENV LANG=en_US.utf8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y postgresql-common

ENV PG_MAJOR=18

ENV YES=yes
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

RUN apt-get update \
    && apt-get \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        install -y \
        sudo \
        libpq-dev \
        python3-venv \
        python3-dev \
        build-essential \
        postgresql-$PG_MAJOR \
        postgresql-contrib-$PG_MAJOR \
    && python3 -m venv /venv \
    && /venv/bin/pip install tox \
    && ln -s /venv/bin/tox /usr/local/bin/tox

COPY ./ /dist

CMD ["/dist/run_test.sh"]
