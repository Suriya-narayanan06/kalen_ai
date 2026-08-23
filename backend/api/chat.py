from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
)


class ChatRequest(BaseModel):
    message: str


@router.get("/")
def chat_status():
    return {
        "status": "online",
        "module": "Chat",
    }


@router.post("/send")
def send_message(request: ChatRequest):
    message = request.message.strip()

    if not message:
        return {
            "reply": "Please enter a message."
        }

    return {
        "reply": f"KALEN AI received: {message}"
    }
