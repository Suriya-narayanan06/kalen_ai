from fastapi import APIRouter

router = APIRouter(
    prefix="/creator",
    tags=["Creator"]
)

@router.get("/")
def creator_status():
    return {
        "status": "online",
        "module": "Creator"
    }