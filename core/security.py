import hashlib
import secrets
from datetime import datetime

class SecurityEngine:

    def __init__(self):
        self.permissions = {}
        self.audit_log = []
        self.session_token = None

    def hash_passkey(self, passkey: str):
        return hashlib.sha256(passkey.encode()).hexdigest()

    def create_session(self):
        self.session_token = secrets.token_hex(32)
        return self.session_token

    def validate_session(self, token):
        return token == self.session_token

    def grant_permission(self, module):
        self.permissions[module] = True

    def revoke_permission(self, module):
        self.permissions[module] = False

    def has_permission(self, module):
        return self.permissions.get(module, False)

    def audit(self, module, action):
        self.audit_log.append({
            "time": datetime.now().isoformat(),
            "module": module,
            "action": action
        })

    def logs(self):
        return self.audit_log