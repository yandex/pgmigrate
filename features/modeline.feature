Feature: Modelines in migration/callback files

    Scenario: Migration with non-ascii symbols and modeline
        Given migration dir
        And migrations
           | file                     | code                                            |
           | V1__Single_migration.sql | /* pgmigrate-encoding: utf-8 */SELECT 'テスト'; |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "succeeded"
        And database contains schema_version
