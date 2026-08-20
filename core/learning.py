from collections import Counter
from datetime import datetime

class LearningEngine:

    def __init__(self):
        self.preferences = {}
        self.command_counter = Counter()
        self.module_counter = Counter()
        self.history = []

    def learn_command(self, command, module):

        self.command_counter[command] += 1
        self.module_counter[module] += 1

        self.history.append({
            "time": datetime.now().isoformat(),
            "command": command,
            "module": module
        })

    def set_preference(self, key, value):
        self.preferences[key] = value

    def get_preference(self, key):
        return self.preferences.get(key)

    def favorite_module(self):

        if not self.module_counter:
            return None

        return self.module_counter.most_common(1)[0]

    def favorite_command(self):

        if not self.command_counter:
            return None

        return self.command_counter.most_common(1)[0]

    def recommendations(self):

        suggestions = []

        if self.module_counter["SmartCall"] >= 10:
            suggestions.append(
                "Create a Smart Call automation."
            )

        if self.module_counter["Vision"] >= 10:
            suggestions.append(
                "Pin Camera AI to Home."
            )

        if self.module_counter["Creator"] >= 10:
            suggestions.append(
                "Enable Creator Quick Access."
            )

        return suggestions