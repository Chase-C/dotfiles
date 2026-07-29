import unittest

from tickets import can_assign, show_in_active_queue


class ExistingTicketBehaviorTests(unittest.TestCase):
    def test_archived_ticket_cannot_be_assigned_but_remains_visible(self):
        ticket = {"status": "archived"}
        self.assertFalse(can_assign(ticket))
        self.assertTrue(show_in_active_queue(ticket))

    def test_closed_ticket_is_neither_assignable_nor_visible(self):
        ticket = {"status": "closed"}
        self.assertFalse(can_assign(ticket))
        self.assertFalse(show_in_active_queue(ticket))


if __name__ == "__main__":
    unittest.main()
