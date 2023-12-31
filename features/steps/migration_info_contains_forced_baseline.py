from behave import then
from pgmigrate import _get_info


@then("migration info contains forced baseline={baseline}")
@then(
    'migration info contains forced baseline={baseline} in schema "{schema}"',
)
def step_impl(context, baseline, schema='public'):
    cur = context.conn.cursor()
    info = _get_info(context.migr_dir, 0, 1, schema, cur)
    assert list(info.values())[0].meta['version'] == int(baseline)
    assert list(info.values())[0].meta['description'] == 'Forced baseline'
