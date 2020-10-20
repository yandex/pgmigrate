import yaml

from behave import given


@given('config')
def step_impl(context):
    data = yaml.safe_load(context.text)
    context.migrate_config = data
