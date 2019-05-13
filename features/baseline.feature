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

    Scenario: Setting baseline in custom schema leaves only one migration
        Given migration dir
        And migrations
           | file                      | code      |
           | V1__Single_migration.sql  | SELECT 1; |
           | V2__Another_migration.sql | SELECT 1; |
        And schema "custom"
        And database and connection
        And successful pgmigrate run with "-t 2 migrate"
        When we run pgmigrate with "-b 3 baseline"
        Then pgmigrate command "succeeded"
        And database contains schema_version in schema "custom"
        And migration info in schema "custom" contains forced baseline=3

    Scenario: Setting baseline on noninitalized database
        Given migration dir
        And database and connection
        When we run pgmigrate with "-b 1 baseline"
        Then pgmigrate command "succeeded"
        And database contains schema_version
        And migration info contains forced baseline=1

    Scenario: Setting baseline in custom schema on noninitalized database
        Given migration dir
        And schema "custom"
        And database and connection
        When we run pgmigrate with "-b 1 baseline"
        Then pgmigrate command "succeeded"
        And database contains schema_version in schema "custom"
        And migration info in schema "custom" contains forced baseline=1
