import os
import shutil
import tempfile

from behave import given


@given('migration dir')
def step_migrations_dir(context):
    try:
        shutil.rmtree(context.migr_dir)
    except Exception:
        pass
    context.migr_dir = tempfile.mkdtemp()
    os.mkdir(os.path.join(context.migr_dir, 'migrations'))
    os.mkdir(os.path.join(context.migr_dir, 'callbacks'))


@given('removed migrations subdir')
def step_removed_subdir(context):
    shutil.rmtree(os.path.join(context.migr_dir, 'migrations'))
