Feature: Conflicting pids termination

    Scenario: Transactional migration blocked by update passes
        Given migration dir
        And migrations
           | file                      | code                                   |
           | V1__Create_test_table.sql | CREATE TABLE test (id bigint);         |
           | V2__Insert_test_data.sql  | INSERT INTO test (id) VALUES (1);      |
           | V3__Alter_test_table.sql  | ALTER TABLE test ADD COLUMN test text; |
        And database and connection
        And successful pgmigrate run with "-t 2 migrate"
        And not committed query "UPDATE test SET id = 2 WHERE id = 1"
        When we run pgmigrate with "-l 0.1 -t 3 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Nontransactional migration blocked by update passes
        Given migration dir
        And migrations
           | file                                | code                                   |
           | V1__Create_test_table.sql           | CREATE TABLE test (id bigint);         |
           | V2__Insert_test_data.sql            | INSERT INTO test (id) VALUES (1);      |
           | V3__NONTRANSACTIONAL_migration.sql  | ALTER TABLE test ADD COLUMN test text; |
        And database and connection
        And successful pgmigrate run with "-t 2 migrate"
        And not committed query "UPDATE test SET id = 2 WHERE id = 1"
        When we run pgmigrate with "-l 0.1 -t 3 migrate"
        Then pgmigrate command "succeeded"

    Scenario: Mixed transactional and nontransactional migrations blocked by update pass
        Given migration dir
        And migrations
           | file                                | code                                    |
           | V1__Transactional_migration.sql     | ALTER TABLE test ADD COLUMN test text;  |
           | V2__NONTRANSACTIONAL_migration.sql  | ALTER TABLE test ADD COLUMN test2 text; |
        And database and connection
        And query "CREATE TABLE test (id bigint)"
        And query "INSERT INTO test (id) VALUES (1)"
        And not committed query "UPDATE test SET id = 2 WHERE id = 1"
        When we run pgmigrate with "-l 0.1 -t 2 migrate"
        Then pgmigrate command "succeeded"
