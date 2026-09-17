class PermissionManager:

    def __init__(self):

        self.permissions = {
            "camera": False,
            "contacts": False,
            "location": False,
            "microphone": False,
            "storage": False,
            "phone": False,
            "notifications": False
        }

    def grant(self, permission):
        self.permissions[permission] = True

    def revoke(self, permission):
        self.permissions[permission] = False

    def allowed(self, permission):
        return self.permissions.get(permission, False)