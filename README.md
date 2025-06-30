[![PyPI version](https://badge.fury.io/py/yandex-pgmigrate.svg)](https://badge.fury.io/py/yandex-pgmigrate)
![Build Status](https://github.com/yandex/pgmigrate/workflows/Test/badge.svg)

# PGmigrate

PostgreSQL migrations made easy

## Overview

PGmigrate is a database migration tool developed by Yandex.

PGmigrate has the following key-features:

* **Transactional and nontransactional migrations:** you can enjoy whole power
of PostgreSQL DDL
* **Callbacks:** you can run some DDL on specific steps of migration process
(e.g. drop some code before executing migrations, and create it back after
migrations were applied)
* **Online migrations:** you can execute series of transactional migrations
and callbacks in a single transaction (so, if something goes wrong simple
`ROLLBACK` will bring you in consistent state)

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

* 1.0.10 (2025-06-30)
    * Add option to allow mixing transactional and non-transactional migrations
* 1.0.9 (2024-07-06)
    * Add an option to show only unapplied migrations in info
* 1.0.8 (2024-03-08)
    * Allow reordering setting schema version and afterEach callback
* 1.0.7 (2022-02-02)
    * Skip unnecessary schema creation on init
    * Add file path to statement apply error log
    * Add version gaps check
* 1.0.6 (2020-10-29)
    * Make dsn manipulations more robust
    * Fix empty values-related bugs in config and args parsing
* 1.0.5 (2020-02-29)
    * Use application_name instead of backend pid for conflict termination
* 1.0.4 (2019-04-14)
    * Allow using subdirs in migrations folder
* 1.0.3 (2017-12-28)
    * Fix migration error with comment at the end of file
    * Add blocking pids termination
    * Some minor fixes and improvements
* 1.0.2 (2017-04-05)
    * Speed up get_info function a bit
    * Fix callbacks in transactional/nontransactional migrations mix on db init
* 1.0.1 (2017-04-01)
    * Fix bug with python format patterns in migration text
    * Sort info command output by version
    * Support 'latest' target version
    * Add option to override user in migration meta
    * Fix info command fail without target on initialized database
    * Add session setup option
* 1.0.0 (2016-10-03)
    * First opensource version

## License

Distributed under the PostgreSQL license. See [LICENSE](LICENSE) for more
information.
