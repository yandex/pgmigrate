Feature: Info

    Scenario: Info prints applied migration
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "info"
        Then migrate command passed with Single migration
