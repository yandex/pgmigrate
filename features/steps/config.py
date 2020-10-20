import os

import yaml

from behave import given


@given('config')
def step_impl(context):
    data = yaml.safe_load(context.text)
    context.migrate_config = data


@given('empty config')  # noqa
def step_impl(context):
    open(os.path.join(context.migr_dir, 'migrations.yml'), 'w').close()
