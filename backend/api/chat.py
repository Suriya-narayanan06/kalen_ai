from fastapi import APIRouter

router = APIRouter(
    prefix="/chat",
    tags=["Chat"]
)

@router.get("/")
def chat_status():
    return {
        "status": "online",
        "module": "Chat"
    }

@router.post("/send")
def send_message(message: str):
    return {
        "reply": f"KALEN AI received: {message}"
    }