import unittest

from documents import save_document, serialize_document


class Store:
    def __init__(self):
        self.records = {}

    def write(self, key, value):
        self.records[key] = value


class DocumentSerializationTests(unittest.TestCase):
    def test_serialized_shape_is_stable(self):
        document = {"id": "doc-1", "status": "draft"}
        self.assertEqual(
            serialize_document(document),
            {"id": "doc-1", "status": "draft", "is_draft": True},
        )

    def test_persists_the_public_shape(self):
        store = Store()
        payload = save_document({"id": "doc-1", "status": "published"}, store)
        self.assertEqual(store.records["doc-1"], payload)


if __name__ == "__main__":
    unittest.main()
