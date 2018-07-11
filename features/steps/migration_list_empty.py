from behave import then
from pgmigrate import _get_migrations_info_from_dir


@then('migration list is empty')
def step_impl(context):
    pattern = r'V(?P<version>\d+)__(?P<description>.+)\.sql$'
    assert len(_get_migrations_info_from_dir(context.migr_dir,
                                             pattern).keys()) == 0
