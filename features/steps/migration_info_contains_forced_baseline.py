from behave import then
from pgmigrate import _get_info, DEFAULT_MIGRATION_RE


@then("migration info contains forced baseline={baseline}")
def step_impl(context, baseline):
    context.cursor = context.conn.cursor()
    context.base_dir = context.migr_dir
    context.target = 1
    context.pattern = DEFAULT_MIGRATION_RE
    info = _get_info(context, baseline)
    assert list(info.values())[0]['version'] == int(baseline)
    assert list(info.values())[0]['description'] == 'Forced baseline'
