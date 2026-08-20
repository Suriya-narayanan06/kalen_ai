import socket
import ipaddress
from datetime import datetime

class OSINTEngine:

    def __init__(self):
        self.history = []

    def _log(self, target, scan_type):

        self.history.append({
            "time": datetime.now().isoformat(),
            "target": target,
            "type": scan_type
        })

    def domain_lookup(self, domain):

        self._log(domain, "DOMAIN")

        try:
            ip = socket.gethostbyname(domain)

            return {
                "domain": domain,
                "ip": ip,
                "status": "ONLINE"
            }

        except Exception:

            return {
                "domain": domain,
                "status": "UNREACHABLE"
            }

    def ip_lookup(self, ip):

        self._log(ip, "IP")

        try:

            obj = ipaddress.ip_address(ip)

            return {
                "ip": str(obj),
                "version": obj.version,
                "private": obj.is_private
            }

        except ValueError:

            return {
                "error": "Invalid IP"
            }

    def email_lookup(self, email):

        self._log(email, "EMAIL")

        domain = email.split("@")[-1]

        return {
            "email": email,
            "domain": domain
        }

    def username_lookup(self, username):

        self._log(username, "USERNAME")

        return {
            "username": username,
            "status": "Ready for public platform checks"
        }

    def history(self):

        return self.history