def handle_invoice(payload):
    return {"kind": "invoice", "id": payload["id"]}


def handle_legacy(payload):
    return {"kind": "legacy", "id": payload["id"]}
