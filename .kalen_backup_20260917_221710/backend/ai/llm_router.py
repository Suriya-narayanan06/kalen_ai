class LLMRouter:

    def select(self, task: str) -> str:
        if task in {
            "chat",
            "coding",
            "vision",
            "voice",
            "system",
            "security",
        }:
            return "Gemini"

        return "Gemini"
