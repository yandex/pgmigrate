Feature: Nontransactional migrations support

    Scenario: Callbacks are not executed on nontransactional migration
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        And successful pgmigrate run with our callbacks and "-t 1 migrate"
        When we run pgmigrate with our callbacks and "-t 2 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | After all   |
           | 5   | Migration 2 |

    Scenario: Callbacks are executed on nontransactional migration on empty database in correct order 1
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 2 migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 2
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | After all   |
           | 5   | Migration 2 |

    Scenario: Callbacks are executed on nontransactional migration on empty database in correct order 2
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
           | V3__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 3'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 3 migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 3
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | Migration 2 |
           | 5   | Before each |
           | 6   | Migration 3 |
           | 7   | After each  |
           | 8   | After all   |

    Scenario: Callbacks are executed on nontransactional migration on empty database in correct order 3
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
           | V3__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 3'); |
           | V4__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 4'); |
           | V5__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 5'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t latest migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 5
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before each |
           | 2   | Migration 1 |
           | 3   | After each  |
           | 4   | Migration 2 |
           | 5   | Before each |
           | 6   | Migration 3 |
           | 7   | After each  |
           | 8   | After all   |
           | 9   | Migration 4 |
           | 10  | Migration 5 |

    Scenario: Mix of transactional and nontransactional migrations with force
        Given migration dir
        And migrations
           | file                               | code                                                 |
           | V1__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
           | V3__Transactional_migration.sql    | INSERT INTO mycooltable (op) values ('Migration 3'); |
           | V4__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 4'); |
           | V5__NONTRANSACTIONAL_migration.sql | INSERT INTO mycooltable (op) values ('Migration 5'); |
        And callbacks
           | type       | file            | code                                                                                                                          |
           | beforeAll  | before_all.sql  | CREATE TABLE IF NOT EXISTS mycooltable (seq SERIAL PRIMARY KEY, op TEXT); INSERT INTO mycooltable (op) values ('Before all'); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');                                                                          |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');                                                                           |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');                                                                            |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 1 migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 1
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before all  |
           | 2   | Before each |
           | 3   | Migration 1 |
           | 4   | After each  |
           | 5   | After all   |
        When we run pgmigrate with our callbacks and "-t latest --force_mixed migrate"
        Then pgmigrate command "succeeded"
        And migrate command passed with Migrating to version 5
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Before all  |
           | 2   | Before each |
           | 3   | Migration 1 |
           | 4   | After each  |
           | 5   | After all   |
           | 6   | Migration 2 |
           | 7   | Before all  |
           | 8   | Before each |
           | 9   | Migration 3 |
           | 10  | After each  |
           | 11  | After all   |
           | 12  | Migration 4 |
           | 13  | Migration 5 |
