from behave import then
from pgmigrate import MalformedMigration, _get_migrations_info_from_dir


@then('versions conflict with version={version}')
def step_impl(context, version):
    try:
        _get_migrations_info_from_dir(context.migr_dir)
    except MalformedMigration as e:
        assert 'migrations with same version: ' + str(version) in str(e)
        return
    raise RuntimeError('No failure on version conflict')
