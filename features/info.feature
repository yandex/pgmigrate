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

    Scenario: Info filters out applied migrations
        Given migration dir
        And migrations
           | file                        | code      |
           | V1__Applied_migration.sql   | SELECT 1; |
           | V2__Unapplied_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "-o info"
        Then migrate command output matches json
        """
        {
            "2": {
                "version": 2,
                "type": "auto",
                "installed_by": null,
                "installed_on": null,
                "description": "Unapplied migration",
                "transactional": true
            }
        }
        """
