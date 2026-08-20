from enum import Enum

class DeviceState(Enum):
    READY = "READY"
    BUSY = "BUSY"

class SystemControl:

    def __init__(self):
        self.state = DeviceState.READY

    def open_app(self, package_name):

        return {
            "action": "OPEN_APP",
            "package": package_name
        }

    def make_call(self, number):

        return {
            "action": "CALL",
            "number": number
        }

    def send_sms(self, number, message):

        return {
            "action": "SMS",
            "number": number,
            "message": message
        }

    def open_camera(self):

        return {
            "action": "CAMERA"
        }

    def flashlight(self, enabled):

        return {
            "action": "FLASHLIGHT",
            "enabled": enabled
        }

    def bluetooth(self):

        return {
            "action": "BLUETOOTH"
        }

    def wifi(self):

        return {
            "action": "WIFI"
        }

    def volume(self, level):

        return {
            "action": "VOLUME",
            "level": level
        }

    def brightness(self, value):

        return {
            "action": "BRIGHTNESS",
            "value": value
        }

    def location(self):

        return {
            "action": "GPS"
        }

    def notifications(self):

        return {
            "action": "NOTIFICATIONS"
        }

    def battery(self):

        return {
            "action": "BATTERY"
        }

    def storage(self):

        return {
            "action": "STORAGE"
        }

    def contacts(self):

        return {
            "action": "CONTACTS"
        }