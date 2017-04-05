import io
import os

from behave import given


@given('migrations')  # noqa
def step_impl(context):
    migrations_path = os.path.join(context.migr_dir, 'migrations')
    for row in context.table:
        path = os.path.join(migrations_path, row['file'])
        with io.open(path, 'w', encoding='utf-8') as f:
            f.write(row['code'].replace('\\n', '\n'))


@given('migration dir "{dirname}"')  # noqa
def step_impl(context, dirname):
    migrations_path = os.path.join(context.migr_dir, 'migrations')
    path = os.path.join(migrations_path, dirname)
    os.mkdir(path)
