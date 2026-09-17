import os
from typing import List, Dict

import httpx


class DeepSeekProvider:
    def __init__(self):
        self.api_key = os.getenv("DEEPSEEK_API_KEY")
        self.base_url = "https://api.deepseek.com/chat/completions"
        self.model = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")

    def generate(
        self,
        prompt: str,
        history: List[Dict[str, str]] | None = None,
    ) -> str:

        if not self.api_key:
            raise RuntimeError("DEEPSEEK_API_KEY is not configured.")

        messages = [
            {
                "role": "system",
                "content": (
                    "You are KALEN, a helpful futuristic AI assistant. "
                    "Be concise, accurate, practical, and context-aware."
                ),
            }
        ]

        if history:
            messages.extend(history)

        messages.append({
            "role": "user",
            "content": prompt,
        })

        payload = {
            "model": self.model,
            "messages": messages,
            "stream": False,
        }

        response = httpx.post(
            self.base_url,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
            json=payload,
            timeout=60.0,
        )

        response.raise_for_status()

        data = response.json()

        return data["choices"][0]["message"]["content"]
