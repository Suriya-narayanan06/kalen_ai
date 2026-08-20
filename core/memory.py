from datetime import datetime

class MemoryEngine:
    def __init__(self):
        self.short_term = []
        self.long_term = {}

    def remember(self, key, value):
        self.long_term[key] = value

    def recall(self, key):
        return self.long_term.get(key)

    def add_conversation(self, user_message, ai_response):
        self.short_term.append({
            "time": datetime.now().isoformat(),
            "user": user_message,
            "assistant": ai_response
        })

        # Keep only the latest 20 exchanges in memory
        if len(self.short_term) > 20:
            self.short_term.pop(0)

    def history(self):
        return self.short_term

    def clear(self):
        self.short_term.clear()
        self.long_term.clear()