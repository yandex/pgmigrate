# PGmigrate

PostgreSQL migrations made easy

## Install

```
pip install yandex-pgmigrate
```

## Running tests

Tests require running PostgreSQL instance with superuser (to create/drop dbs).
You could setup this yourself and use [tox](https://pypi.python.org/pypi/tox)
to start tests:
```
tox
```
Second option is to use [docker](https://www.docker.com) and make:
```
make test
```

## How to use

Complete manual is [here](doc/tutorial.md).

## Release history

* 1.0.0 (2016-10-03)
    * First opensource version

## License

Distributed under the PostgreSQL license. See [LICENSE](LICENSE) for more
information.
