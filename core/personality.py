
class PersonalityEngine:

    def __init__(self):
        self.mode = "Jarvis"

    def set_mode(self, mode):

        modes = [
            "Jarvis",
            "Professional",
            "GenZ",
            "DarkAI",
            "Chill",
            "Custom"
        ]

        if mode in modes:
            self.mode = mode

    def current(self):
        return self.mode

    def reply(self, text):

        if self.mode == "Jarvis":
            return f"Certainly. {text}"

        elif self.mode == "Professional":
            return f"Task accepted. {text}"

        elif self.mode == "GenZ":
            return f"Yo! {text} "

        elif self.mode == "DarkAI":
            return f"Processing... {text}"

        elif self.mode == "Chill":
            return f"Sure  {text}"

        return text