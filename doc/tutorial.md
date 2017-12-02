# PGmigrate tutorial

We'll play around with example database `foodb`.

## Base directory structure of our example

Our [Example db](foodb) migrations dir structure looks like this:
```
foodb
├── callbacks # directory with sql callbacks
│   ├── afterAll # will be executed before commit and after last migration
│   ├── afterEach # will be executed after each migration
│   ├── beforeAll # will be executed after begin and before first migration
│   └── beforeEach # will be executed before each migration
├── grants # use this dir to set special callbacks for grants
├── migrations # migrations dir
├── migrations.yml # pgmigrate configuration
```
Every sql file has special operation on table `ops`.
This will help in understanding what is going on in each pgmigrate run.

## Migration file name pattern

All migration files should have versions and
names in the following format
```
V<version>__<description>.sql
```
Note: files not matching this pattern will be skipped.

## Creating `foo` user and `foodb`

We'll need dummy user and database for our experiments.
```
postgres=# CREATE ROLE foo WITH LOGIN PASSWORD 'foo';
CREATE ROLE
postgres=# CREATE DATABASE foodb;
CREATE DATABASE
```

## Getting migrations info before first migration

```
admin@localhost foodb $ pgmigrate -t 1 info
{
    "1": {
        "description": "Initial schema foo",
        "transactional": true,
        "version": 1,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    }
}
```
Here we see json description of migrations that will be applied if
we want to get to version 1.

Let's try to check steps to apply up to version 3 but ignoring version 1:
```
admin@localhost foodb $ pgmigrate -b 1 -t 3 info
{
    "2": {
        "description": "Add baz column to foo",
        "transactional": true,
        "version": 2,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    },
    "3": {
        "description": "NONTRANSACTIONAL Add index on baz column",
        "transactional": false,
        "version": 3,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    }
}
```

## Migrating to first version

```
admin@localhost foodb $ pgmigrate -t 1 migrate
admin@localhost foodb $ echo $?
0
```
Ok. Migration applied. Let's see what is in our db now.

```
admin@localhost foodb $ psql foodb
psql (9.5.4)
Type "help" for help.

foodb=# SELECT * FROM ops;
 seq |                   op
-----+-----------------------------------------
   1 | beforeAll 00_create_database_ops.sql
   2 | beforeEach 00_dummy_before_each.sql
   3 | migration V0001__Initial_schema_foo.sql
   4 | afterEach 00_dummy_after_each.sql
   5 | afterAll 00_dummy_after_all.sql
   6 | grants foo
(6 rows)

foodb=# \dt foo.foo
        List of relations
 Schema | Name | Type  | Owner
--------+------+-------+-------
 foo    | foo  | table | admin
(1 row)

foodb=# \dS+ foo.foo
                           Table "foo.foo"
 Column |  Type  | Modifiers | Storage  | Stats target | Description
--------+--------+-----------+----------+--------------+-------------
 id     | bigint | not null  | plain    |              |
 bar    | text   | not null  | extended |              |
Indexes:
    "foo_pkey" PRIMARY KEY, btree (id)
```

Let's check if `foo` user can really do something with our new table.
```
psql "dbname=foodb user=foo password=foo host=localhost"
psql (9.5.4)
Type "help" for help.

foodb=> SELECT * FROM foo.foo;
 id | bar
----+-----
(0 rows)
```

## Mixing transactional and nontransactional migrations
Let's try to go to version 3.
```
admin@localhost foodb $ pgmigrate -t 3 migrate
2016-09-29 00:14:35,402 ERROR   : Unable to mix transactional and nontransactional migrations
Traceback (most recent call last):
  File "/usr/local/bin/pgmigrate", line 9, in <module>
    load_entry_point('yandex-pgmigrate==1.0.0', 'console_scripts', 'pgmigrate')()
  File "/usr/local/lib/python2.7/dist-packages/pgmigrate.py", line 663, in _main
    COMMANDS[args.cmd](config)
  File "/usr/local/lib/python2.7/dist-packages/pgmigrate.py", line 549, in migrate
    raise MigrateError('Unable to mix transactional and '
pgmigrate.MigrateError: Unable to mix transactional and nontransactional migrations
```
Oops! It complained. But why? The main reason for this is quite simple:
Your production databases are likely larger than test ones.
And migration to version 3 could take a lot of time.
You definitely should stop on version 2, check that everything is working fine,
and then move to version 3.

## Migrating to second version
Ok. Now let's try version 2.
```
admin@localhost foodb $ pgmigrate -t 2 migrate
admin@localhost foodb $ echo $?
0
```
Looks good. But what is in db?
```
admin@localhost foodb $ psql foodb
psql (9.5.4)
Type "help" for help.

foodb=# SELECT * FROM ops;
 seq |                     op
-----+--------------------------------------------
   1 | beforeAll 00_create_database_ops.sql
   2 | beforeEach 00_dummy_before_each.sql
   3 | migration V0001__Initial_schema_foo.sql
   4 | afterEach 00_dummy_after_each.sql
   5 | afterAll 00_dummy_after_all.sql
   6 | grants foo
   7 | beforeAll 00_create_database_ops.sql
   8 | beforeEach 00_dummy_before_each.sql
   9 | migration V0002__Add_baz_column_to_foo.sql
  10 | afterEach 00_dummy_after_each.sql
  11 | afterAll 00_dummy_after_all.sql
  12 | grants foo
(12 rows)

foodb=# \dS+ foo.foo
                               Table "foo.foo"
 Column |  Type  |     Modifiers      | Storage  | Stats target | Description
--------+--------+--------------------+----------+--------------+-------------
 id     | bigint | not null           | plain    |              |
 bar    | text   | not null           | extended |              |
 baz    | bigint | not null default 0 | plain    |              |
Indexes:
    "foo_pkey" PRIMARY KEY, btree (id)
```
As we can see migration steps are almost the same as in version 1.

## Migrating to version 3 with nontransactional migration
```
admin@localhost foodb $ pgmigrate -t 3 migrate
admin@localhost foodb $ echo $?
0
```

In database:
```
admin@localhost foodb $ psql foodb
psql (9.5.4)
Type "help" for help.

foodb=# SELECT * FROM ops;
 seq |                              op
-----+---------------------------------------------------------------
   1 | beforeAll 00_create_database_ops.sql
   2 | beforeEach 00_dummy_before_each.sql
   3 | migration V0001__Initial_schema_foo.sql
   4 | afterEach 00_dummy_after_each.sql
   5 | afterAll 00_dummy_after_all.sql
   6 | grants foo
   7 | beforeAll 00_create_database_ops.sql
   8 | beforeEach 00_dummy_before_each.sql
   9 | migration V0002__Add_baz_column_to_foo.sql
  10 | afterEach 00_dummy_after_each.sql
  11 | afterAll 00_dummy_after_all.sql
  12 | grants foo
  13 | migration V0003__NONTRANSACTIONAL_Add_index_on_baz_column.sql
(13 rows)

foodb=# \dS+ foo.foo
                               Table "foo.foo"
 Column |  Type  |     Modifiers      | Storage  | Stats target | Description
--------+--------+--------------------+----------+--------------+-------------
 id     | bigint | not null           | plain    |              |
 bar    | text   | not null           | extended |              |
 baz    | bigint | not null default 0 | plain    |              |
Indexes:
    "foo_pkey" PRIMARY KEY, btree (id)
    "i_foo_baz" btree (baz)
```
No callbacks were applied this time (we are trying to run the absolute
minimum of operations outside of transactions).

## Baseline

Let's suppose that you already have a database with schema on version 3.
But you have already reached this state without using pgmigrate.
How should you migrate to version 4 and so on with it?

Let's remove schema_version info from our database
```
admin@localhost foodb $ pgmigrate clean
```

Now let's check how pgmigrate will bring us to version 3:
```
admin@localhost foodb $ pgmigrate -t 3 info
{
    "1": {
        "description": "Initial schema foo",
        "transactional": true,
        "version": 1,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    },
    "2": {
        "description": "Add baz column to foo",
        "transactional": true,
        "version": 2,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    },
    "3": {
        "description": "NONTRANSACTIONAL Add index on baz column",
        "transactional": false,
        "version": 3,
        "installed_by": null,
        "type": "auto",
        "installed_on": null
    }
}
```
This looks really bad. Our migration v1 will definitely fail
(because schema `foo` already exists).
Let's tell pgmigrate that our database is already on version 3.
```
admin@localhost foodb $ pgmigrate -b 3 baseline
admin@localhost foodb $ pgmigrate -t 3 info
{
    "3": {
        "description": "Forced baseline",
        "transactional": true,
        "version": 3,
        "installed_on": "2016-09-29 00:37:27",
        "type": "manual",
        "installed_by": "admin"
    }
}
```

## Migrations on empty database

When you have hundreds of migrations with some nontransactional ones
you really don't want to stop on each of them to get your empty database
to specific version (consider creating new database for some experiments).

PGmigrate is able to run such kind of migration in single command run
(but you should definitely know what are you doing).

Let's try it.
Drop and create empty `foodb`
```
postgres=# DROP DATABASE foodb;
DROP DATABASE
postgres=# CREATE DATABASE foodb;
CREATE DATABASE
```

Now migrate to latest available version
```
admin@localhost foodb $ pgmigrate -t latest migrate
```

Operations log will look like this:
```
admin@localhost foodb $ psql foodb
psql (9.5.4)
Type "help" for help.

foodb=# SELECT * FROM ops;
 seq |                              op
-----+---------------------------------------------------------------
   1 | beforeAll 00_create_database_ops.sql
   2 | beforeEach 00_dummy_before_each.sql
   3 | migration V0001__Initial_schema_foo.sql
   4 | afterEach 00_dummy_after_each.sql
   5 | beforeEach 00_dummy_before_each.sql
   6 | migration V0002__Add_baz_column_to_foo.sql
   7 | afterEach 00_dummy_after_each.sql
   8 | afterAll 00_dummy_after_all.sql
   9 | grants foo
  10 | migration V0003__NONTRANSACTIONAL_Add_index_on_baz_column.sql
(10 rows)
```

## UTF-8 Migrations

In most cases you should avoid non-ascii characters in your migrations.
So PGmigrate will complain about them with:
```
pgmigrate.MalformedStatement: Non ascii symbols in file
```

But sometimes there is no way to avoid migration with UTF-8
(imagine a case with inserting some initial data in your database).
You could insert modeline in migration file to disable
non-ascii characters check:
```
/* pgmigrate-encoding: utf-8 */
```

## Session setup

Sometimes you need to set some session options before migrate
(e.g. isolation level). It is possible with `-s` option or `session` in config.
For example to set `serializable` isolation level and
lock timeout to 30 seconds one could do something like this:
```
pgmigrate -s "SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE" \
    -s "SET lock_timeout = '30s'" ...
```

## Terminating blocking pids

On heavy loaded production environments running some migrations
could block queries by application backends.
Unfortunately if migration is blocked by some other query it could lead
to really slow database queries.
For example lock queue like this:
```
<lots of app backends>
<pgmigrate>
<stale backend in idle in transaction>
```
makes database almost unavailable for at least `idle_in_transaction_timeout`.
To mitigate such issues there is `-l <interval>` option in pgmigrate
which starts separate thread running `pg_terminate_backend(pid)` for
each pid blocking any of pgmigrate conn pids every `interval` seconds.
Of course pgmigrate should be able to terminate other pids so migration user
should be the app user or have `pg_signal_backend` grant. To terminate
superuser (e.g. `postgres`) pids one could run pgmigrate with superuser.

Note: this feature relays on `pg_blocking_pids()` function available since
PostgreSQL 9.6.
