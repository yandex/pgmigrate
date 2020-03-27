from behave import then
from pgmigrate import _is_initialized


@then("database contains schema_version")
@then('database contains schema_version in schema "{schema}"')
def step_impl(context, schema='public'):
    cur = context.conn.cursor()
    assert _is_initialized(schema, cur), 'Non-empty db should be initialized'
