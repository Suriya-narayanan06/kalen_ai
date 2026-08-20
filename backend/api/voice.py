from fastapi import APIRouter

router = APIRouter(
    prefix="/voice",
    tags=["Voice"]
)

@router.get("/")
def voice_status():
    return {
        "status": "online",
        "module": "Voice"
    }

@router.post("/listen")
def listen():
    return {
        "message": "Voice module active"
    }