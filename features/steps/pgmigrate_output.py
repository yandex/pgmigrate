import json

from behave import then


@then('migrate command output matches json')  # noqa
def step_impl(context):
    ref_data = json.loads(context.text)
    out_data = json.loads(context.last_migrate_res['out'])
    assert json.dumps(ref_data) == json.dumps(out_data), \
            'Actual result: ' + context.last_migrate_res['out']
