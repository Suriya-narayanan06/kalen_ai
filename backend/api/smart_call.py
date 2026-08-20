from fastapi import APIRouter

router = APIRouter(
    prefix="/smart-call",
    tags=["Smart Call"]
)

@router.get("/")
def smart_call_status():
    return {
        "status": "online",
        "module": "Smart Call"
    }