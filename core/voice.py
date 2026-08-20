from enum import Enum

class VoiceState(Enum):
    IDLE = "IDLE"
    LISTENING = "LISTENING"
    THINKING = "THINKING"
    SPEAKING = "SPEAKING"

class VoiceEngine:

    def __init__(self):
        self.state = VoiceState.IDLE
        self.wake_words = [
            "hey kalen",
            "hi kalen",
            "kalen"
        ]

        self.voice = "Jarvis"
        self.language = "en-US"

    def set_voice(self, voice):
        self.voice = voice

    def set_language(self, language):
        self.language = language

    def detect_wake_word(self, text):

        command = text.lower()

        return any(
            wake in command
            for wake in self.wake_words
        )

    def start_listening(self):
        self.state = VoiceState.LISTENING

    def start_thinking(self):
        self.state = VoiceState.THINKING

    def start_speaking(self):
        self.state = VoiceState.SPEAKING

    def stop(self):
        self.state = VoiceState.IDLE

    def status(self):
        return {
            "state": self.state.value,
            "voice": self.voice,
            "language": self.language
        }

    def speech_to_text(self, transcript):
        return transcript

    def text_to_speech(self, text):
        return {
            "voice": self.voice,
            "text": text
        }