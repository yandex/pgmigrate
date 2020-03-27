Feature: Schema restriction

    Scenario: Transactional migration restricted to schema pass
        Given migration dir
        And migrations
           | file                     | code                                         |
           | V1__Single_migration.sql | CREATE TABLE "test-schema".test (id bigint); |
        And database and connection
        And successful pgmigrate run with "-t 1 -m test-schema migrate"
        Then database contains schema_version in schema "test-schema"
        And migration info contains single migration in schema "test-schema"

    Scenario: Nontransactional migration restricted to schema fails
        Given migration dir
        And migrations
           | file                                | code                                         |
           | V1__NONTRANSACTIONAL_migration.sql  | CREATE TABLE "test-schema".test (id bigint); |
        And database and connection
        When we run pgmigrate with "-t 1 -m test-schema migrate"
        Then migrate command failed with Schema check is not available for nontransactional migrations

    Scenario: Nontransactional migration with disabled schema restriction passes
        Given migration dir
        And migrations
           | file                               | code                                            |
           | V1__Create_test_table.sql          | CREATE TABLE "test-schema".test (id bigint);    |
           | V2__NONTRANSACTIONAL_migration.sql | INSERT INTO "test-schema".test (id) VALUES (1); |
        And database and connection
        And successful pgmigrate run with "-t 2 -m test-schema --disable_schema_check migrate"
        Then database contains schema_version in schema "test-schema"

    Scenario: Transactional migration with restriction violation fails
        Given migration dir
        And migrations
           | file                        | code                                  |
           | V1__Create_public_table.sql | CREATE TABLE public.test (id bigint); |
        And database and connection
        When we run pgmigrate with "-t 1 -m test-schema migrate"
        Then migrate command failed with Unexpected relations used in migrations: public.test
