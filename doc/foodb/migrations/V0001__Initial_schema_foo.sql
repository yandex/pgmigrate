CREATE SCHEMA foo;

CREATE TABLE foo.foo (
    id BIGINT PRIMARY KEY,
    bar TEXT NOT NULL
);

INSERT INTO ops (op) VALUES ('migration V0001__Initial_schema_foo.sql');
