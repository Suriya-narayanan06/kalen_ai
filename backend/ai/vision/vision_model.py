from abc import ABC, abstractmethod


class VisionModel(ABC):
    """Interface for all KALEN vision models."""

    @abstractmethod
    def analyze(
        self,
        image_data: bytes,
        prompt: str,
    ) -> str:
        raise NotImplementedError


class PlaceholderVisionModel(VisionModel):
    """
    Temporary adapter.

    Replace this implementation with a real VLM provider
    without changing the Vision API.
    """

    def analyze(
        self,
        image_data: bytes,
        prompt: str,
    ) -> str:
        if not image_data:
            raise ValueError("Image data is empty.")

        return (
            "Vision model is not connected yet. "
            "The image was received successfully."
        )
