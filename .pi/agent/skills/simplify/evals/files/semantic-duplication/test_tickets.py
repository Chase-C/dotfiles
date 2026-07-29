import unittest

from tickets import can_assign, should_send_stale_reminder, show_in_active_queue


class TicketActivityTests(unittest.TestCase):
    def test_open_ticket_is_active_everywhere(self):
        ticket = {"status": "open"}
        self.assertTrue(can_assign(ticket))
        self.assertTrue(show_in_active_queue(ticket))
        self.assertTrue(should_send_stale_reminder(ticket))

    def test_closed_and_archived_tickets_are_inactive_everywhere(self):
        for status in ("closed", "archived"):
            ticket = {"status": status}
            self.assertFalse(can_assign(ticket))
            self.assertFalse(show_in_active_queue(ticket))
            self.assertFalse(should_send_stale_reminder(ticket))


if __name__ == "__main__":
    unittest.main()
