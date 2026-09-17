import os
from pathlib import Path
from typing import Optional

from openai import OpenAI


class VoiceService:
    """
    KALEN Voice engine.

    Flow:
        audio -> Whisper STT -> transcript
        transcript -> existing KALEN LLM
        response -> OpenAI TTS -> audio
    """

    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")

        if not api_key:
            raise RuntimeError(
                "OPENAI_API_KEY is not configured."
            )

        self.client = OpenAI(api_key=api_key)

    def transcribe(self, audio_path: str) -> dict:
        with open(audio_path, "rb") as audio:
            result = self.client.audio.transcriptions.create(
                model=os.getenv(
                    "KALEN_STT_MODEL",
                    "whisper-1",
                ),
                file=audio,
                response_format="verbose_json",
            )

        language = getattr(result, "language", None)
        text = getattr(result, "text", "")

        return {
            "text": text.strip(),
            "language": language,
        }

    def synthesize(
        self,
        text: str,
        output_path: str,
        voice: Optional[str] = None,
    ) -> str:

        voice = voice or os.getenv(
            "KALEN_TTS_VOICE",
            "alloy",
        )

        response = self.client.audio.speech.create(
            model=os.getenv(
                "KALEN_TTS_MODEL",
                "gpt-4o-mini-tts",
            ),
            voice=voice,
            input=text,
            response_format="mp3",
        )

        response.write_to_file(output_path)

        return output_path
