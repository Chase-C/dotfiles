import importlib


def dispatch(module_name, handler_name, payload):
    module = importlib.import_module(module_name)
    handler = getattr(module, f"handle_{handler_name}")
    return handler(payload)
