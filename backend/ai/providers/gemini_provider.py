import os

from dotenv import load_dotenv
from google import genai


load_dotenv()


class GeminiProvider:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")

        if not api_key:
            raise RuntimeError(
                "GEMINI_API_KEY is not configured."
            )

        self.client = genai.Client(api_key=api_key)
        self.model = "gemini-3.6-flash"

    def generate(self, prompt: str) -> str:
        interaction = self.client.interactions.create(
            model=self.model,
            input=prompt,
        )

        if not interaction.output_text:
            raise RuntimeError(
                "Gemini returned an empty response."
            )

        return interaction.output_text.strip()
