# Deployment boundaries

`client_validation.py` is bundled into a browser application. `server_registration.py` runs in a separately deployed API that also serves mobile and third-party clients. Requests can reach the API without running browser validation.
