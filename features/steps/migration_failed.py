from behave import then


@then('migrate command failed with {error}')
def step_impl(context, error):
    assert context.last_migrate_res['ret'] != 0, \
        'Not failed with: ' + context.last_migrate_res['err'].decode('utf-8',
                                                                     'ignore')
    assert error in context.last_migrate_res['err'], \
        'Actual result: ' + context.last_migrate_res['err'].decode('utf-8',
                                                                   'ignore')
