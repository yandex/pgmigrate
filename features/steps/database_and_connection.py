import psycopg2

from behave import given


@given('database and connection')
def step_impl(context):
    context.conn = None
    conn = psycopg2.connect('dbname=postgres')
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("select pg_terminate_backend(pid) " +
                "from pg_stat_activity where datname='pgmigratetest'")
    cur.execute('drop database if exists pgmigratetest')
    cur.execute('create database pgmigratetest')
    context.conn = psycopg2.connect('dbname=pgmigratetest')
