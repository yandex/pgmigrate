Feature: Baseline

    Scenario: Setting baseline leaves only one migration
        Given migration dir
        And migrations
           | file                      | code      |
           | V1__Single_migration.sql  | SELECT 1; |
           | V2__Another_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 2 migrate"
        When we run pgmigrate with "-b 3 baseline"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And migration info contains forced baseline=3

    Scenario: Setting baseline on noninitialized database
        Given migration dir
        And database and connection
        When we run pgmigrate with "-b 1 baseline"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And migration info contains forced baseline=1
