FREE_SHIPPING_MINIMUM = 100
MANUAL_REVIEW_MINIMUM = 100


def qualifies_for_free_shipping(order):
    return order["subtotal"] >= FREE_SHIPPING_MINIMUM


def requires_manual_review(order):
    return order["subtotal"] >= MANUAL_REVIEW_MINIMUM
