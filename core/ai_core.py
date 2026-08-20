from datetime import datetime

class KalenCore:

    def __init__(self):
        self.name = "KALEN"
        self.version = "3.0"
        self.status = "ONLINE"
        self.personality = "Jarvis"
        self.user = None

    def set_user(self, name):
        self.user = name

    def set_personality(self, mode):
        self.personality = mode

    def get_status(self):
        return {
            "name": self.name,
            "version": self.version,
            "status": self.status,
            "personality": self.personality,
            "time": datetime.now().strftime("%H:%M:%S")
        }

    def respond(self, text):

        text = text.lower()

        if "hello" in text:
            return f"Hello {self.user or 'User'}. How may I assist you?"

        if "status" in text:
            return str(self.get_status())

        if "time" in text:
            return datetime.now().strftime("%I:%M %p")

        return "Command received. AI module processing."