from behave import then
from pgmigrate import MalformedMigration, _get_migrations_info_from_dir
from pgmigrate import DEFAULT_MIGRATION_RE


@then('versions conflict with version={version}')
def step_impl(context, version):
    pattern = DEFAULT_MIGRATION_RE
    try:
        _get_migrations_info_from_dir(context.migr_dir, pattern)
    except MalformedMigration as e:
        assert 'migrations with same version: ' + str(version) in str(e)
        return
    raise RuntimeError('No failure on version conflict')
