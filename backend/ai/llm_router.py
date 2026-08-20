class LLMRouter:

    def select(self, task):

        if task == "chat":
            return "Gemini"

        if task == "offline":
            return "Llama3"

        if task == "coding":
            return "Gemini"

        return "Gemini"