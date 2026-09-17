from typing import Any

from backend.ai.vision.config import VisionConfig
from backend.ai.vision.vision_model import (
    PlaceholderVisionModel,
    VisionModel,
)


class VisionService:
    """Central orchestration layer for KALEN Vision."""

    def __init__(self, model: VisionModel | None = None) -> None:
        self.config = VisionConfig()
        self.model = model or PlaceholderVisionModel()

    @property
    def model_name(self) -> str:
        return self.config.model

    @property
    def provider(self) -> str:
        return self.config.provider

    def analyze(
        self,
        image_data: bytes,
        filename: str | None = None,
        content_type: str | None = None,
        prompt: str = "Describe this image.",
    ) -> dict[str, Any]:

        if not image_data:
            raise ValueError("Image data is empty.")

        description = self.model.analyze(
            image_data=image_data,
            prompt=prompt,
        )

        return {
            "status": "success",
            "module": "Vision",
            "provider": self.provider,
            "model": self.model_name,
            "filename": filename,
            "content_type": content_type,
            "size_bytes": len(image_data),
            "analysis": {
                "description": description,
            },
        }
