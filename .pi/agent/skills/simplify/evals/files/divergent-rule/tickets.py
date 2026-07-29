def can_assign(ticket):
    return ticket["status"] not in ("closed", "archived")


def show_in_active_queue(ticket):
    return ticket["status"] != "closed"
