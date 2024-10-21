# vim:set ft=dockerfile:
FROM ubuntu:jammy

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -d /var/lib/postgresql -g postgres --uid=999 postgres

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y ca-certificates locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV DEBIAN_FRONTEND noninteractive

ENV PG_MAJOR 17

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list
RUN echo 'deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu/ jammy main' > /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa.list

RUN apt-get -o Acquire::AllowInsecureRepositories=true \
        -o Acquire::AllowDowngradeToInsecureRepositories=true update \
    && apt-get \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -o APT::Get::AllowUnauthenticated=true \
        install -y postgresql-common \
        sudo \
        libpq-dev \
        python2.7-dev \
        python3.11-dev \
        python3.11-lib2to3 \
        build-essential \
        curl \
        postgresql-$PG_MAJOR \
        postgresql-contrib-$PG_MAJOR \
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3.11 get-pip.py \
    && pip3.11 install tox

COPY ./ /dist

CMD ["/dist/run_test.sh"]
