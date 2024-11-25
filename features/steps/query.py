from behave import given, then


@given('not committed query "{query}"')  # noqa
def step_impl(context, query):
    cur = context.conn.cursor()
    cur.execute(query)


@given('query "{query}"')  # noqa
def step_impl(context, query):
    cur = context.conn.cursor()
    cur.execute(query)
    cur.execute('commit;')


@then('query "{query}" equals')  # noqa
def step_impl(context, query):
    cur = context.conn.cursor()
    cur.execute(query)
    r = cur.fetchall()
    formatted = ';'.join(map(lambda x: '|'.join(map(str, x)), r))
    res = []
    for row in context.table:
        res.append(row[0] + '|' + row[1])
    result = ';'.join(res)
    assert formatted == result, 'Unexpected result: ' + formatted
