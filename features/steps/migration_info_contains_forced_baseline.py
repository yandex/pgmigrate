from behave import then
from pgmigrate import _get_info


@then("migration info contains forced baseline={baseline}")
def step_impl(context, baseline):
    cur = context.conn.cursor()
    info = _get_info(context.migr_dir, 0, 1, cur)
    assert list(info.values())[0]['version'] == int(baseline)
    assert list(info.values())[0]['description'] == 'Forced baseline'
