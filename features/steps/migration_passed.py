from behave import then


@then('migrate command passed with {message}')
def step_impl(context, message):
    assert context.last_migrate_res['ret'] == 0, \
        'Failed with: ' + context.last_migrate_res['err']
    assert message in context.last_migrate_res['err'], \
        'Actual result: ' + context.last_migrate_res['err']
