def serialize_document(document):
    return {
        "id": document["id"],
        "status": document["status"],
        "is_draft": document["status"] == "draft",
    }


def save_document(document, store):
    payload = serialize_document(document)
    store.write(document["id"], payload)
    return payload
