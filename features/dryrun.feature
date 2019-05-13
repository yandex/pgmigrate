Feature: Dryrun

    Scenario: One migration in dir applies after migrate command
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-n -t 1 migrate"
        Then pgmigrate command "succeeded"
        And database has no schema_version table

    Scenario: One migration in dir applies after migrate command with custom schema
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And schema "custom"
        And database and connection
        When we run pgmigrate with "-n -t 1 migrate"
        Then pgmigrate command "succeeded"
        And database has no schema_version table in schema "custom"
