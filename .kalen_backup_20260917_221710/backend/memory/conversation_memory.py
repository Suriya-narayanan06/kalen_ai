from collections import defaultdict
from typing import Dict, List


class ConversationMemory:

    def __init__(self, max_messages: int = 20):
        self.max_messages = max_messages
        self._sessions: Dict[str, List[Dict[str, str]]] = defaultdict(list)

    def get(self, session_id: str) -> List[Dict[str, str]]:
        return list(self._sessions[session_id])

    def add_user(self, session_id: str, message: str) -> None:
        self._sessions[session_id].append({
            "role": "user",
            "content": message,
        })
        self._trim(session_id)

    def add_assistant(self, session_id: str, message: str) -> None:
        self._sessions[session_id].append({
            "role": "assistant",
            "content": message,
        })
        self._trim(session_id)

    def clear(self, session_id: str) -> None:
        self._sessions.pop(session_id, None)

    def _trim(self, session_id: str) -> None:
        messages = self._sessions[session_id]

        if len(messages) > self.max_messages:
            self._sessions[session_id] = messages[-self.max_messages:]
