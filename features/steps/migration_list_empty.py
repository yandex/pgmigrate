from behave import then
from pgmigrate import _get_migrations_info_from_dir, DEFAULT_MIGRATION_RE


@then('migration list is empty')
def step_impl(context):
    pattern = DEFAULT_MIGRATION_RE
    assert len(_get_migrations_info_from_dir(context.migr_dir,
                                             pattern).keys()) == 0
