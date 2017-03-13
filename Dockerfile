# vim:set ft=dockerfile:
FROM python:3.6

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update \
    && apt-get install -y postgresql-common \
        libpq-dev \
        python2.7-dev \
    && pip install tox

COPY ./ /dist
WORKDIR /dist

CMD ["/dist/run_test.sh"]
