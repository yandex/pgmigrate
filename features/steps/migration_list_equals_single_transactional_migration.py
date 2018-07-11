from behave import then
from pgmigrate import _get_migrations_info_from_dir


@then('migration list equals single transactional migration')
def step_impl(context):
    pattern = r'V(?P<version>\d+)__(?P<description>.+)\.sql$'
    assert len(_get_migrations_info_from_dir(context.migr_dir,
                                             pattern).keys()) == 1
    migration = list(_get_migrations_info_from_dir(context.migr_dir,
                                                   pattern).values())[0]
    assert migration.meta['version'] == 1
    assert migration.meta['description'] == 'Single migration'

@then('migration list with custom pattern equals couple transactional migrations')
def step_impl(context):
    pattern = r'(?P<description>.+)_ver(?P<version>\d+)\.sql$'
    assert len(_get_migrations_info_from_dir(context.migr_dir,
                                             pattern).keys()) == 2
