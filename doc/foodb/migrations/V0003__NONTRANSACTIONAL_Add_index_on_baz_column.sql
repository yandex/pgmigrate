CREATE INDEX CONCURRENTLY i_foo_baz ON foo.foo (baz);

INSERT INTO ops (op) VALUES ('migration V0003__NONTRANSACTIONAL_Add_index_on_baz_column.sql');
