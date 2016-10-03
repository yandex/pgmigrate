ALTER TABLE foo.foo ADD COLUMN baz BIGINT NOT NULL DEFAULT 0;

INSERT INTO ops (op) VALUES ('migration V0002__Add_baz_column_to_foo.sql');
