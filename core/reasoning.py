from typing import Dict

class ReasoningEngine:

    def __init__(self):
        self.modules = {
            "call": "SmartCall",
            "camera": "Vision",
            "photo": "Vision",
            "image": "Vision",
            "document": "Document",
            "osint": "OSINT",
            "email": "OSINT",
            "phone": "SmartCall",
            "wifi": "SystemControl",
            "bluetooth": "SystemControl",
            "music": "Media",
            "calendar": "Calendar",
            "alarm": "Calendar",
            "settings": "Settings"
        }

    def analyze(self, text: str) -> Dict:
        command = text.lower()

        for keyword, module in self.modules.items():
            if keyword in command:
                return {
                    "module": module,
                    "intent": keyword,
                    "command": text,
                    "confidence": 0.95
                }

        return {
            "module": "AIChat",
            "intent": "conversation",
            "command": text,
            "confidence": 0.60
        }