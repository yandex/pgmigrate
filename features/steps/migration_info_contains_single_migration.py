from behave import then
from pgmigrate import _get_info


@then("migration info contains single migration")
def step_impl(context):
    cur = context.conn.cursor()
    info = _get_info(context.migr_dir, 0, 1, cur)
    assert list(info.values())[0]['version'] == 1
    assert list(info.values())[0]['description'] == 'Single migration'
