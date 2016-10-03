CREATE TABLE IF NOT EXISTS ops (
    seq SERIAL PRIMARY KEY,
    op TEXT NOT NULL
);

INSERT INTO ops (op) VALUES ('beforeAll 00_create_database_ops.sql');
