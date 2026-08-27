Feature: Ungrouped transactions

    Scenario: Callbacks are executed once with ungrouped transactions
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 2'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 2 --ungroup migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 2
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | Before each |
           | 5   | Migration 2 |
           | 6   | After each  |
           | 7   | After all   |

    Scenario: Earlier migrations are committed when later one fails
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__Transactional_migration.sql    | THIS_IS_ERROR                                        |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 2 --ungroup migrate"
        Then pgmigrate command "failed"
        And migrate command failed with THIS_IS_ERROR
        And database contains schema_version
        And query "SELECT version, description from schema_version;" equals
           | version | description             |
           | 1       | Transactional migration |
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |

    Scenario: Ungrouped transactions mixed with nontransactional migration
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
           | V3__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 3'); |
           | V4__Transactional_migration.sql    | THIS_IS_ERROR                                        |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t latest --ungroup migrate"
        Then pgmigrate command "failed"
        And migrate command failed with THIS_IS_ERROR
        And database contains schema_version
        And query "SELECT version, description from schema_version;" equals
           | version | description                |
           | 1       | Transactional migration    |
           | 2       | NONTRANSACTIONAL migration |
           | 3       | Transactional migration    |
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | Migration 2 |
           | 5   | Before each |
           | 6   | Migration 3 |
           | 7   | After each  |

    Scenario: Dry run with ungrouped transactions is nonsense
        Given migration dir
        And migrations
           | file                               | code      |
           | V1__Transactional_migration.sql    | SELECT 1; |
           | V2__Transactional_migration.sql    | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-t 2 --ungroup -n migrate"
        Then pgmigrate command "failed"
        And migrate command failed with Dry run for ungrouped migrations is nonsense
        And database has no schema_version table

    Scenario: Ungrouped migrations blocked by update pass
        Given migration dir
        And migrations
           | file                      | code                                   |
           | V1__Create_test_table.sql | CREATE TABLE test (id bigint);         |
           | V2__Insert_test_data.sql  | INSERT INTO test (id) VALUES (1);      |
           | V3__Alter_test_table.sql  | ALTER TABLE test ADD COLUMN test text; |
        And database and connection
        And successful pgmigrate run with "-t 2 migrate"
        And not committed query "UPDATE test SET id = 2 WHERE id = 1"
        When we run pgmigrate with "-l 0.1 -t 3 --ungroup migrate"
        Then pgmigrate command "succeeded"

    Scenario: Ungrouped transactions with schema restriction
        Given migration dir
        And migrations
           | file                      | code                                            |
           | V1__Single_migration.sql  | CREATE TABLE "test-schema".test (id bigint);    |
           | V2__Another_migration.sql | INSERT INTO "test-schema".test (id) VALUES (1); |
        And database and connection
        And successful pgmigrate run with "-t 2 -m test-schema --ungroup migrate"
        Then database contains schema_version in schema "test-schema"
