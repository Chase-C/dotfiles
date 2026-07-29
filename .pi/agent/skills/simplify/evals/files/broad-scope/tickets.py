from dataclasses import dataclass


@dataclass
class Ticket:
    id: str
    status: str
    is_closed: bool
    owner: str


def can_assign(ticket):
    return ticket.status not in ("closed", "archived")


def show_in_active_queue(ticket):
    return ticket.status not in ("closed", "archived")


def should_send_reminder(ticket):
    return ticket.status not in ("closed", "archived")


def normalize_owner(owner):
    return owner.strip()


def display_owner(ticket):
    return normalize_owner(ticket.owner)


def serialize_ticket(ticket):
    return {
        "id": ticket.id,
        "status": ticket.status,
        "is_closed": ticket.is_closed,
        "owner": ticket.owner,
    }
