import unittest

from policies import qualifies_for_free_shipping, requires_manual_review


class PolicyTests(unittest.TestCase):
    def test_current_thresholds(self):
        self.assertFalse(qualifies_for_free_shipping({"subtotal": 99}))
        self.assertTrue(qualifies_for_free_shipping({"subtotal": 100}))
        self.assertFalse(requires_manual_review({"subtotal": 99}))
        self.assertTrue(requires_manual_review({"subtotal": 100}))


if __name__ == "__main__":
    unittest.main()
