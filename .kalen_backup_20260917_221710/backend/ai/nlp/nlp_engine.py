import re
from dataclasses import dataclass
from typing import List


@dataclass
class NLPResult:
    intent: str
    entities: List[str]
    confidence: float


class NLPEngine:
    """
    Lightweight NLP layer for KALEN.

    It performs deterministic intent detection and
    basic entity extraction before the request reaches
    the LLM.
    """

    INTENTS = {
        "chat": (
            "hello",
            "hi",
            "hey",
            "explain",
            "what",
            "why",
            "how",
            "tell",
        ),
        "coding": (
            "code",
            "python",
            "flutter",
            "dart",
            "javascript",
            "program",
            "debug",
            "error",
            "function",
        ),
        "vision": (
            "image",
            "photo",
            "picture",
            "camera",
            "identify",
            "scan",
        ),
        "voice": (
            "voice",
            "speak",
            "listen",
            "microphone",
        ),
        "system": (
            "system",
            "cpu",
            "ram",
            "storage",
            "battery",
            "process",
        ),
        "security": (
            "security",
            "secure",
            "threat",
            "malware",
            "vulnerability",
        ),
    }

    def analyze(self, text: str) -> NLPResult:
        normalized = text.lower().strip()

        if not normalized:
            return NLPResult(
                intent="chat",
                entities=[],
                confidence=0.0,
            )

        scores = {}

        for intent, keywords in self.INTENTS.items():
            scores[intent] = sum(
                1 for keyword in keywords
                if keyword in normalized
            )

        best_intent = max(scores, key=scores.get)
        best_score = scores[best_intent]

        if best_score == 0:
            best_intent = "chat"
            confidence = 0.5
        else:
            confidence = min(0.5 + (best_score * 0.1), 0.95)

        entities = self._extract_entities(text)

        return NLPResult(
            intent=best_intent,
            entities=entities,
            confidence=confidence,
        )

    def _extract_entities(self, text: str) -> List[str]:
        entities = []

        urls = re.findall(
            r"https?://\\S+",
            text,
            flags=re.IGNORECASE,
        )

        entities.extend(urls)

        return entities
