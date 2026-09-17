import os
import tempfile
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import FileResponse

router = APIRouter(
    prefix="/voice",
    tags=["Voice"],
)


@router.get("/health")
async def voice_health():
    return {
        "success": True,
        "module": "voice",
        "status": "online",
    }


@router.post("/transcribe")
async def transcribe_voice(
    audio: UploadFile = File(...),
):
    temp_path = None

    try:
        suffix = Path(audio.filename or ".wav").suffix or ".wav"

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=suffix,
        ) as temp:
            temp_path = temp.name
            temp.write(await audio.read())

        from backend.services.voice_service import VoiceService

        service = VoiceService()
        result = service.transcribe(temp_path)

        return {
            "success": True,
            "text": result.get("text", ""),
            "language": result.get("language", "unknown"),
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Speech-to-text failed: {exc}",
        )

    finally:
        if temp_path:
            try:
                os.unlink(temp_path)
            except Exception:
                pass


@router.post("/tts")
async def text_to_speech(payload: dict):
    text = str(payload.get("text", "")).strip()

    if not text:
        raise HTTPException(
            status_code=400,
            detail="text is required",
        )

    output_path = None

    try:
        output = tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".mp3",
        )
        output_path = output.name
        output.close()

        from backend.services.voice_service import VoiceService

        service = VoiceService()

        service.synthesize(
            text=text,
            output_path=output_path,
            voice=payload.get("voice"),
        )

        return FileResponse(
            output_path,
            media_type="audio/mpeg",
            filename="kalen_response.mp3",
        )

    except Exception as exc:
        if output_path:
            try:
                os.unlink(output_path)
            except Exception:
                pass

        raise HTTPException(
            status_code=500,
            detail=f"Text-to-speech failed: {exc}",
        )
