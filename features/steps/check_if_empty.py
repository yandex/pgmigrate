from behave import then
from pgmigrate import _is_initialized


@then("database has no schema_version table")
@then('database has no schema_version table in schema "{schema}"')
def step_impl(context, schema='public'):
    cur = context.conn.cursor()
    assert not _is_initialized(schema, cur), 'Database should be uninitialized'
