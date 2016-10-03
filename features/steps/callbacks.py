import os

from behave import given, when


@given('callbacks')
def step_impl(context):
    for row in context.table:
        path = os.path.join('callbacks', row['file'])
        context.callbacks.append(row['type'] + ':' + path)
        if row.get('code', False):
            with open(os.path.join(context.migr_dir, path), 'w') as f:
                f.write(row['code'])


@given('config callbacks')  # noqa
def step_impl(context):
    for row in context.table:
        if row.get('dir', False):
            dir_path = os.path.join('callbacks', row['dir'])
            path = os.path.join(dir_path, row['file'])
        else:
            dir_path = None
            path = os.path.join('callbacks', row['file'])
        if 'callbacks' not in context.migrate_config:
            context.migrate_config['callbacks'] = {}
        if row['type'] not in context.migrate_config['callbacks']:
            context.migrate_config['callbacks'][row['type']] = []
        if dir_path:
            context.migrate_config['callbacks'][row['type']].append(dir_path)
            if not os.path.exists(os.path.join(context.migr_dir, dir_path)):
                os.mkdir(os.path.join(context.migr_dir, dir_path))
        else:
            context.migrate_config['callbacks'][row['type']].append(path)
        if row.get('code', False):
            with open(os.path.join(context.migr_dir, path), 'w') as f:
                f.write(row['code'])


@given('successful pgmigrate run with our callbacks and "{args}"')  # noqa
def step_impl(context, args):
    cbs = ','.join(context.callbacks)
    context.execute_steps('given successful pgmigrate run with ' +
                          '"%s"' % ('-a ' + cbs + ' ' + args,))


@when('we run pgmigrate with our callbacks and "{args}"')  # noqa
def step_impl(context, args):
    cbs = ','.join(context.callbacks)
    context.execute_steps('when we run pgmigrate with ' +
                          '"%s"' % ('-a ' + cbs + ' ' + args,))


@when('we run pgmigrate with dir callbacks and type "{cb_type}" and "{args}"')  # noqa
def step_impl(context, cb_type, args):
    p_args = '-a ' + cb_type + ':' + context.migr_dir + '/callbacks/ ' + args
    context.execute_steps('when we run pgmigrate with "%s"' % (p_args,))
