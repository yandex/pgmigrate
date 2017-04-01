Feature: Getting migrations from dir

    Scenario: Empty dir gives empty migrations list
        Given migration dir
        Then migration list is empty

    Scenario: One migration in dir gives migration list with only this migration
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        Then migration list equals single transactional migration

    Scenario: Garbage migrations are properly ignored
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
           | kekekeke.sql             | SELECT 1; |
        And migration dir "V2__Dir_migration.sql"
        Then migration list equals single transactional migration

    Scenario: One migration in dir applies after migrate command
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And migration info contains single migration

    Scenario: Python format is ignored in migration text
        Given migration dir
        And migrations
           | file                     | code           |
           | V1__Single_migration.sql | SELECT '%02d'; |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And migration info contains single migration

    Scenario: 'latest' target migrates to latest version
        Given migration dir
        And migrations
           | file                      | code                                                 |
           | V1__Single_migration.sql  | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__Another_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
        And database and connection
        When we run pgmigrate with our callbacks and "-t latest migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op          |
           | 1   | Migration 1 |
           | 2   | Migration 2 |

    Scenario: Callbacks are executed in correct order
        Given migration dir
        And migrations
           | file                      | code                                                 |
           | V1__Single_migration.sql  | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__Another_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
        And callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 2 migrate"
        Then pgmigrate command "succeeded"
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

    Scenario: Callbacks are executed from dir
        Given migration dir
        And migrations
           | file                     | code                                                        |
           | V1__Single_migration.sql | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
       And callbacks
           | type     | file          | code                                               |
           | afterAll | after_all.sql | INSERT INTO mycooltable (op) values ('After all'); |
        And database and connection
        When we run pgmigrate with dir callbacks and type "afterAll" and "-t 2 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op        |
           | 1   | After all |
