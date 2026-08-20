import hashlib
from datetime import datetime

class UpdateManager:

    def __init__(self):

        self.current_version = "2.0.0"

        self.latest_version = self.current_version

        self.modules = {}

        self.history = []

    def register_module(self, name, version):

        self.modules[name] = {
            "version": version,
            "updated": datetime.now().isoformat()
        }

    def check_update(self, latest):

        self.latest_version = latest

        return {
            "current": self.current_version,
            "latest": self.latest_version,
            "update": latest != self.current_version
        }

    def update_module(self, module, version):

        if module not in self.modules:

            return False

        self.history.append({
            "module": module,
            "old": self.modules[module]["version"],
            "new": version,
            "time": datetime.now().isoformat()
        })

        self.modules[module]["version"] = version

        self.modules[module]["updated"] = datetime.now().isoformat()

        return True

    def rollback(self, module, version):

        if module not in self.modules:
            return False

        self.modules[module]["version"] = version

        return True

    def checksum(self, text):

        return hashlib.sha256(
            text.encode()
        ).hexdigest()

    def modules_info(self):

        return self.modules

    def update_history(self):

        return self.history