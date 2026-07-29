import unittest

from tickets import (
    Ticket,
    can_assign,
    display_owner,
    serialize_ticket,
    should_send_reminder,
    show_in_active_queue,
)


class TicketTests(unittest.TestCase):
    def test_activity_rules_agree(self):
        for status, expected in (("open", True), ("closed", False), ("archived", False)):
            ticket = Ticket("ticket-1", status, status == "closed", " Ada ")
            self.assertEqual(can_assign(ticket), expected)
            self.assertEqual(show_in_active_queue(ticket), expected)
            self.assertEqual(should_send_reminder(ticket), expected)

    def test_owner_display_is_trimmed(self):
        ticket = Ticket("ticket-1", "open", False, " Ada ")
        self.assertEqual(display_owner(ticket), "Ada")

    def test_serialized_shape_contains_legacy_closed_flag(self):
        ticket = Ticket("ticket-1", "closed", True, "Ada")
        self.assertEqual(
            serialize_ticket(ticket),
            {"id": "ticket-1", "status": "closed", "is_closed": True, "owner": "Ada"},
        )


if __name__ == "__main__":
    unittest.main()
