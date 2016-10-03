import shutil


def before_scenario(context, scenario):
    try:
        context.last_migrate_res = {}
        context.callbacks = []
        context.migrate_config = {}
        shutil.rmtree(context.migr_dir)
    except Exception:
        pass


def after_all(context):
    try:
        context.last_migrate_res = {}
        context.callbacks = []
        context.migrate_config = {}
        shutil.rmtree(context.migr_dir)
    except Exception:
        pass
