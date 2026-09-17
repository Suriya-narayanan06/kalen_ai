from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from uuid import uuid4

from core.ai_core import KalenCore


router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)

kalen = KalenCore()


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None


@router.get("/")
async def chat_status():
    return {
        "status": "online",
        "module": "Chat",
    }


@router.post("/send")
async def send_message(request: ChatRequest):
    message = request.message.strip()
    session_id = request.session_id or str(uuid4())

    if not message:
        return {
            "reply": "Please enter a message.",
            "session_id": session_id,
        }

    try:
        reply = kalen.respond(
            message,
            session_id=session_id,
        )

        return {
            "reply": reply,
            "session_id": session_id,
        }

    except Exception as exc:
        return {
            "error": str(exc),
            "session_id": session_id,
        }
