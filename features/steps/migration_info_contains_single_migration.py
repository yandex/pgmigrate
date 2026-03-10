from behave import then
from pgmigrate import _get_info


@then("migration info contains single migration")
@then('migration info contains single migration in schema "{schema}"')
def step_impl(context, schema='public'):
    cur = context.conn.cursor()
    info = _get_info(context.migr_dir, 0, 1, schema, cur)
    assert next(iter(info.values())).meta['version'] == 1
    assert next(iter(info.values())).meta['description'] == 'Single migration'
