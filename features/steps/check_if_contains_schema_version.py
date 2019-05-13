from behave import then
from pgmigrate import _is_initialized


@then("database contains schema_version")
def step_impl(context):
    cur = context.conn.cursor()
    assert _is_initialized(cur, schema='public'), 'Non-empty db should be initialized'


@then('database contains schema_version in schema "{schema}"')
def step_impl(context, schema):
    cur = context.conn.cursor()
    assert _is_initialized(cur, schema=schema), 'Non-empty db should be initialized'
