from behave import then
from pgmigrate import _get_migrations_info_from_dir


@then('migration list equals single transactional migration')
def step_impl(context):
    assert len(_get_migrations_info_from_dir(context.migr_dir).keys()) == 1
    migration = list(_get_migrations_info_from_dir(
        context.migr_dir).values())[0]
    assert migration.meta['version'] == 1
    assert migration.meta['description'] == 'Single migration'
