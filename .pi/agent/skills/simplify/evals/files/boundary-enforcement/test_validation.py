import unittest

from client_validation import password_is_valid
from server_registration import InvalidPassword, register_user


class Repository:
    def create(self, **user):
        return user


class PasswordValidationTests(unittest.TestCase):
    def test_client_rejects_short_password(self):
        self.assertFalse(password_is_valid("short"))

    def test_server_rejects_clients_that_bypass_client_validation(self):
        with self.assertRaisesRegex(InvalidPassword, "at least 12 characters"):
            register_user("user@example.com", "short", Repository())

    def test_server_accepts_valid_password(self):
        user = register_user("user@example.com", "long-enough-password", Repository())
        self.assertEqual(user["email"], "user@example.com")


if __name__ == "__main__":
    unittest.main()
