from fastapi import APIRouter

router = APIRouter(
    prefix="/vision",
    tags=["Vision"]
)

@router.get("/")
def vision_status():
    return {
        "status": "online",
        "module": "Vision"
    }