Feature: Getting info from config

    Scenario: Empty config
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And empty config
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Empty callbacks in config
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And config
        """
        callbacks:
        """
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Empty callbacks lists in config
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And config
        """
        callbacks:
            beforeAll:
            beforeEach:
            afterEach:
            afterAll:
        """
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Empty callbacks lists in args
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-a ,,,, -t 1 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Callbacks from config are executed in correct order
        Given migration dir
        And migrations
           | file                      | code                                                 |
           | V1__Single_migration.sql  | INSERT INTO mycooltable (op) values ('Migration 1'); |
           | V2__Another_migration.sql | INSERT INTO mycooltable (op) values ('Migration 2'); |
       And config callbacks
           | type       | file            | code                                                        |
           | beforeAll  | before_all.sql  | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
           | beforeEach | before_each.sql | INSERT INTO mycooltable (op) values ('Before each');        |
           | afterEach  | after_each.sql  | INSERT INTO mycooltable (op) values ('After each');         |
           | afterAll   | after_all.sql   | INSERT INTO mycooltable (op) values ('After all');          |
        And database and connection
        When we run pgmigrate with "-t 2 migrate"
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

    Scenario: Callbacks from config are executed from dir
        Given migration dir
        And migrations
           | file                     | code                                                        |
           | V1__Single_migration.sql | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
       And config callbacks
           | type     | dir       | file         | code                                               |
           | afterAll | after_all | callback.sql | INSERT INTO mycooltable (op) values ('After all'); |
        And database and connection
        When we run pgmigrate with "-t 2 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op        |
           | 1   | After all |

    Scenario: Callbacks from config are overrided by args
        Given migration dir
        And migrations
           | file                     | code                                                        |
           | V1__Single_migration.sql | CREATE TABLE mycooltable (seq SERIAL PRIMARY KEY, op TEXT); |
       And config callbacks
           | type    | file         | code      |
           | INVALID | callback.sql | SELECT 1; |
       And callbacks
           | type     | file          | code                                               |
           | afterAll | after_all.sql | INSERT INTO mycooltable (op) values ('After all'); |
        And database and connection
        When we run pgmigrate with our callbacks and "-t 2 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT * from mycooltable order by seq;" equals
           | seq | op        |
           | 1   | After all |

    Scenario: User from config is saved in migration metadata
        Given migration dir
        And migrations
           | file                      | code      |
           | V1__Single_migration.sql  | SELECT 1; |
           | V2__Another_migration.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        And we run pgmigrate with "-u test_user -t 2 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And query "SELECT version, installed_by from schema_version;" equals
           | version | installed_by |
           | 1       | postgres     |
           | 2       | test_user    |

