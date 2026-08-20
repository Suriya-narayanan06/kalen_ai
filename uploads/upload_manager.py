import os
from pathlib import Path

UPLOAD_DIR = Path("uploads")

IMAGE_DIR = UPLOAD_DIR / "images"
AUDIO_DIR = UPLOAD_DIR / "audio"
DOCUMENT_DIR = UPLOAD_DIR / "documents"
VIDEO_DIR = UPLOAD_DIR / "videos"

for folder in [IMAGE_DIR, AUDIO_DIR, DOCUMENT_DIR, VIDEO_DIR]:
    folder.mkdir(parents=True, exist_ok=True)


class UploadManager:

    @staticmethod
    def save(file, folder):
        filepath = folder / file.filename

        with open(filepath, "wb") as buffer:
            buffer.write(file.file.read())

        return str(filepath)