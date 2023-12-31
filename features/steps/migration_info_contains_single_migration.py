from behave import then
from pgmigrate import _get_info


@then("migration info contains single migration")
@then('migration info contains single migration in schema "{schema}"')
def step_impl(context, schema='public'):
    cur = context.conn.cursor()
    info = _get_info(context.migr_dir, 0, 1, schema, cur)
    assert list(info.values())[0].meta['version'] == 1
    assert list(info.values())[0].meta['description'] == 'Single migration'
