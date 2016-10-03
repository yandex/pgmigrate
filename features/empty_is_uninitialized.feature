Feature: Empty database database has no schema_version table

    Scenario: Check uninitialized
        Given database and connection
        Then database has no schema_version table
