from datetime import datetime

from backend.ai.llm_router import LLMRouter
from backend.ai.nlp import NLPEngine
from backend.ai.providers.gemini_provider import GeminiProvider


class KalenCore:

    def __init__(self):
        self.name = "KALEN"
        self.version = "4.0"
        self.status = "ONLINE"
        self.personality = "Jarvis"
        self.user = None

        self.nlp = NLPEngine()
        self.router = LLMRouter()
        self.gemini = GeminiProvider()

        self.sessions = {}

    def set_user(self, name: str):
        self.user = name

    def set_personality(self, mode: str):
        self.personality = mode

    def get_status(self):
        return {
            "name": self.name,
            "version": self.version,
            "status": self.status,
            "personality": self.personality,
            "time": datetime.now().strftime("%H:%M:%S"),
        }

    def respond(
        self,
        text: str,
        session_id: str | None = None,
    ) -> str:

        text = text.strip()

        if not text:
            return "Please enter a message."

        if session_id:
            self.sessions.setdefault(session_id, [])

        nlp_result = self.nlp.analyze(text)

        task = nlp_result.intent
        provider = self.router.select(task)

        if provider == "Gemini":

            history = self.sessions.get(session_id, [])

            prompt = (
                f"You are KALEN, a futuristic AI assistant.\n"
                f"Personality: {self.personality}\n"
                f"Intent: {task}\n"
                f"Confidence: {nlp_result.confidence:.2f}\n"
                f"Entities: {nlp_result.entities}\n\n"
            )

            if history:
                prompt += "Previous conversation:\n"

                for item in history[-10:]:
                    prompt += (
                        f"User: {item['user']}\n"
                        f"KALEN: {item['assistant']}\n"
                    )

                prompt += "\n"

            prompt += f"Current user request:\n{text}"

            reply = self.gemini.generate(prompt)

            if session_id:
                self.sessions[session_id].append({
                    "user": text,
                    "assistant": reply,
                })

                self.sessions[session_id] = \
                    self.sessions[session_id][-20:]

            return reply

        return f"KALEN could not route the task: {task}"
