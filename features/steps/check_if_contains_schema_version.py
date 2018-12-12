from behave import then
from pgmigrate import _is_initialized


@then("database contains schema_version")
def step_impl(context):
    cur = context.conn.cursor()
    assert _is_initialized(cur, schema='public'), 'Non-empty db should be initialized'
