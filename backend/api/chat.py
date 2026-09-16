from fastapi import APIRouter
from pydantic import BaseModel

from core.ai_core import KalenCore


router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)

kalen = KalenCore()


class ChatRequest(BaseModel):
    message: str
    session_id: str = "default"


@router.get("/")
async def chat_status():
    return {
        "status": "online",
        "module": "Chat",
    }


@router.post("/send")
async def send_message(request: ChatRequest):
    message = request.message.strip()

    if not message:
        return {
            "reply": "Please enter a message."
        }

    try:
        reply = kalen.respond(
            message,
            session_id=request.session_id,
        )

        return {
            "reply": reply,
            "session_id": request.session_id,
        }

    except Exception as exc:
        return {
            "error": str(exc),
            "session_id": request.session_id,
        }
