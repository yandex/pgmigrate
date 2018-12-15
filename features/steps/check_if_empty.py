from behave import then
from pgmigrate import _is_initialized


@then("database has no schema_version table")
def step_impl(context):
    cur = context.conn.cursor()
    assert not _is_initialized(cur, schema='public'), 'Database should be uninitialized'


@then('database has no schema_version table in schema "{schema}"')
def step_impl(context, schema):
    cur = context.conn.cursor()
    assert not _is_initialized(cur, schema=schema), 'Database should be uninitialized'
