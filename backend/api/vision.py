from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from backend.vision.detector import VisionDetector

router = APIRouter(prefix="/vision", tags=["Vision"])
detector = VisionDetector()


@router.get("/health")
def vision_health():
    return {
        "status": "ONLINE",
        "module": "KALEN MACHINE VISION",
        "model": detector.model_name,
        "real_model_loaded": detector.real_model_loaded,
    }


@router.post("/detect")
async def detect(
    image: UploadFile = File(...),
    mode: str = Form("object_detect"),
    confidence_threshold: float = Form(0.50),
):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=415, detail="Only image uploads are supported.")

    data = await image.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty image.")

    try:
        return detector.detect(
            image_bytes=data,
            mode=mode,
            confidence_threshold=max(0.05, min(confidence_threshold, 0.99)),
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Vision inference failed: {exc}") from exc


@router.post("/analyze")
async def analyze(
    class_name: str = Form(...),
    confidence: float = Form(...),
):
    return {
        "class": class_name,
        "confidence": confidence,
        "summary": (
            f"KALEN detected {class_name} with "
            f"{confidence * 100:.1f}% confidence."
        ),
        "actions": ["track", "measure", "describe", "save"],
    }
