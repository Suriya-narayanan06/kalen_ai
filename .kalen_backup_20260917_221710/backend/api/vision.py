from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from services.vision_service import VisionService


router = APIRouter(
    prefix="/vision",
    tags=["Vision"],
)

vision_service = VisionService()


@router.get("/")
async def vision_status():
    return {
        "status": "online",
        "module": "Vision",
        "service": "KALEN Vision API",
        "model": vision_service.model_name,
    }


@router.post("/analyze")
async def analyze_image(
    file: Annotated[UploadFile, File()],
    prompt: Annotated[str, Form()] = "Describe this image.",
):
    if not file.content_type:
        raise HTTPException(
            status_code=400,
            detail="File content type is missing.",
        )

    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=415,
            detail="Only image files are supported.",
        )

    image_data = await file.read()

    if not image_data:
        raise HTTPException(
            status_code=400,
            detail="Uploaded image is empty.",
        )

    prompt = prompt.strip() or "Describe this image."

    try:
        result = vision_service.analyze(
            image_data=image_data,
            filename=file.filename,
            content_type=file.content_type,
            prompt=prompt,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        ) from exc

    return result
