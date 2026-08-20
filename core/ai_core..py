from core.memory import MemoryEngine
from core.personality import PersonalityEngine
from core.reasoning import ReasoningEngine

class KalenCore:

    def __init__(self):
        self.memory = MemoryEngine()
        self.personality = PersonalityEngine()
        self.reasoning = ReasoningEngine()

    def process(self, message):

        decision = self.reasoning.analyze(message)

        reply = self.personality.reply(
            f"Routing request to {decision['module']} module."
        )

        self.memory.add_conversation(message, reply)

        return {
            "response": reply,
            "decision": decision
        }