Feature: Handling migration errors

    Scenario: Conflicting migration versions
        Given migration dir
        And migrations
           | file                      | code      |
           | V1__Single_migration.sql  | SELECT 1; |
           | V1__Another_migration.sql | SELECT 1; |
        Then versions conflict with version=1

    Scenario: Migration with bad sql
        Given migration dir
        And migrations
           | file                     | code          |
           | V1__Single_migration.sql | THIS_IS_ERROR |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with THIS_IS_ERROR

    Scenario: Migration without target
        Given migration dir
        And database and connection
        When we run pgmigrate with "migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Unknown target

    Scenario: Missing migrations subdir
        Given migration dir
        And removed migrations subdir
        When we run pgmigrate with "-t 1 migrate"
        Then migrate command failed with Migrations dir not found

    Scenario: Wrong schema_version structure
        Given migration dir
        And database and connection
        And query "CREATE TABLE public.schema_version (bla text, blabla text);"
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And migrate command failed with unexpected structure

    Scenario: Migration with non-ascii symbols
        Given migration dir
        And migrations
           | file                     | code   |
           | V1__Single_migration.sql | テスト |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Non ascii symbols in file

    Scenario: Mix of transactional and nontransactional migrations
        Given migration dir
        And migrations
           | file                               | code      |
           | V1__Transactional_migration.sql    | SELECT 1; |
           | V2__NONTRANSACTIONAL_migration.sql | SELECT 1; |
           | V3__Transactional_migration.sql    | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "-t 3 migrate"
        Then pgmigrate command "failed"
        And database contains schema_version
        And migrate command failed with Unable to mix

    Scenario: Empty user name
        Given migration dir
        And migrations
           | file                        | code      |
           | V1__Single_migration.sql    | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-u  -t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Empty user name

    Scenario: Baseline on applied version
        Given migration dir
        And migrations
           | file                     | code      |
           | V1__Single_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "-b 1 baseline"
        Then pgmigrate command "failed"
        And database contains schema_version
        And migrate command failed with already applied

    Scenario: Invalid callback types
        Given migration dir
        And database and connection
        When we run pgmigrate with "-a INVALID -t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Unexpected callback type

    Scenario: Invalid callback types from config
        Given migration dir
        And database and connection
        And config callbacks
           | type    | file         | code      |
           | INVALID | callback.sql | SELECT 1; |
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Unexpected callback type

    Scenario: Missing callback files
        Given migration dir
        And database and connection
        When we run pgmigrate with "-a afterAll:missing.sql -t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Path unavailable

    Scenario: Invalid callback types from config
        Given migration dir
        And database and connection
        And config callbacks
           | type     | file         |
           | afterAll | callback.sql |
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And database has no schema_version table
        And migrate command failed with Path unavailable

    Scenario: Dry run for nontransactional migrations
        Given migration dir
        And migrations
           | file                               | code      |
           | V1__Transactional_migration.sql    | SELECT 1; |
           | V2__NONTRANSACTIONAL_migration.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "-t 1 migrate"
        When we run pgmigrate with "-n -t 2 migrate"
        Then pgmigrate command "failed"
        And database contains schema_version
        And migrate command failed with is nonsence

    Scenario: Nontransactional migration on empty database
        Given migration dir
        And migrations
           | file                               | code      |
           | V1__NONTRANSACTIONAL_migration.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "-t 1 migrate"
        Then pgmigrate command "failed"
        And migrate command failed with First migration MUST be transactional
        And database has no schema_version table

    Scenario: Version gaps
        Given migration dir
        And migrations
           | file               | code      |
           | V2__migration1.sql | SELECT 1; |
           | V5__migration2.sql | SELECT 1; |
        And database and connection
        When we run pgmigrate with "--check_serial_versions -t 5 migrate"
        Then pgmigrate command "failed"
        And migrate command failed with missing versions 3, 4
        And database has no schema_version table

    Scenario: Version gaps with applied migration
        Given migration dir
        And migrations
           | file               | code      |
           | V2__migration1.sql | SELECT 1; |
           | V5__migration2.sql | SELECT 1; |
        And database and connection
        And successful pgmigrate run with "--check_serial_versions -t 2 migrate"
        When we run pgmigrate with "--check_serial_versions -t 5 migrate"
        Then pgmigrate command "failed"
        And migrate command failed with missing versions 3, 4
