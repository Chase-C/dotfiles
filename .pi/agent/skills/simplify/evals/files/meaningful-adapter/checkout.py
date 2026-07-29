class VendorTimeout(Exception):
    pass


class PaymentUnavailable(Exception):
    pass


class PaymentGateway:
    def __init__(self, vendor_client):
        self.vendor_client = vendor_client

    def charge(self, amount, idempotency_key):
        try:
            return self.vendor_client.create_charge(
                amount=amount,
                idempotency_key=idempotency_key,
            )
        except VendorTimeout as error:
            raise PaymentUnavailable("Payment service unavailable") from error


def checkout(cart, payment_gateway):
    total = sum(item["price"] for item in cart["items"])
    return payment_gateway.charge(total, cart["checkout_id"])
