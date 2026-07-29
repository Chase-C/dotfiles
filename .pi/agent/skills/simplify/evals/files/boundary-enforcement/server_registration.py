class InvalidPassword(ValueError):
    pass


def register_user(email, password, repository):
    if len(password) < 12:
        raise InvalidPassword("Password must contain at least 12 characters")
    return repository.create(email=email, password=password)
