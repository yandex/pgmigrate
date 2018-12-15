from behave import given


@given('schema "{schema}"')
def step_impl(context, schema):
    context.migrate_config['schema'] = schema
