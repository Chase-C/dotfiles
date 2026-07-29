import unittest

from checkout import PaymentGateway, PaymentUnavailable, VendorTimeout, checkout


class RecordingVendor:
    def __init__(self, error=None):
        self.error = error
        self.calls = []

    def create_charge(self, **request):
        self.calls.append(request)
        if self.error:
            raise self.error
        return {"charge_id": "charge-1"}


class CheckoutTests(unittest.TestCase):
    def test_passes_checkout_id_as_idempotency_key(self):
        vendor = RecordingVendor()
        result = checkout(
            {"checkout_id": "checkout-1", "items": [{"price": 25}, {"price": 15}]},
            PaymentGateway(vendor),
        )
        self.assertEqual(result, {"charge_id": "charge-1"})
        self.assertEqual(vendor.calls, [{"amount": 40, "idempotency_key": "checkout-1"}])

    def test_translates_vendor_timeout_to_domain_error(self):
        gateway = PaymentGateway(RecordingVendor(VendorTimeout("timed out")))
        with self.assertRaisesRegex(PaymentUnavailable, "Payment service unavailable"):
            checkout({"checkout_id": "checkout-1", "items": []}, gateway)


if __name__ == "__main__":
    unittest.main()
