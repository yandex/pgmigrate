Feature: Clean

    Scenario: Cleaning database makes it uninitialized
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "clean"
        Then pgmigrate command "succeeded"
        And database has no schema_version table

    Scenario: Cleaning custom schema in database makes it uninitialized
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And schema "custom"
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "clean"
        Then pgmigrate command "succeeded"
        And database has no schema_version table in schema "custom"
