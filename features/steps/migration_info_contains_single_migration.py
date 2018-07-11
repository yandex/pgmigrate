from behave import then
from pgmigrate import _get_info, DEFAULT_MIGRATION_RE


@then("migration info contains single migration")
def step_impl(context):
    context.cursor = context.conn.cursor()
    context.base_dir = context.migr_dir
    context.target = 1
    context.pattern = DEFAULT_MIGRATION_RE
    info = _get_info(context, 0)
    assert list(info.values())[0]['version'] == 1
    assert list(info.values())[0]['description'] == 'Single migration'
