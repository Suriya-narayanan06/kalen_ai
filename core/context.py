from collections import deque
from datetime import datetime

class ContextEngine:

    def __init__(self, max_history=20):
        self.history = deque(maxlen=max_history)
        self.current_topic = None
        self.last_intent = None
        self.last_module = None

    def update(self, user_message, ai_response,
               intent=None,
               module=None):

        self.history.append({
            "time": datetime.now().isoformat(),
            "user": user_message,
            "assistant": ai_response
        })

        if intent:
            self.last_intent = intent

        if module:
            self.last_module = module

        self.current_topic = user_message

    def previous(self):

        if len(self.history) == 0:
            return None

        return self.history[-1]

    def last_module_used(self):
        return self.last_module

    def last_intent_used(self):
        return self.last_intent

    def conversation(self):
        return list(self.history)

    def clear(self):
        self.history.clear()
        self.current_topic = None
        self.last_module = None
        self.last_intent = None