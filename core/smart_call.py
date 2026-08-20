from enum import Enum
from pathlib import Path

class VisionState(Enum):
    IDLE = "IDLE"
    CAMERA = "CAMERA"
    ANALYZING = "ANALYZING"

class VisionEngine:

    def __init__(self):
        self.state = VisionState.IDLE

    def open_camera(self):
        self.state = VisionState.CAMERA
        return {
            "success": True,
            "state": self.state.value
        }

    def analyze_image(self, image_path: str):

        self.state = VisionState.ANALYZING

        if not Path(image_path).exists():
            return {
                "success": False,
                "error": "Image not found"
            }

        return {
            "success": True,
            "type": "image",
            "file": image_path,
            "objects": [],
            "text": "",
            "faces": 0,
            "qr_codes": [],
            "description": "Ready for AI vision model."
        }

    def extract_text(self, image_path):

        return {
            "success": True,
            "text": ""
        }

    def scan_qr(self, image_path):

        return {
            "success": True,
            "data": None
        }

    def close(self):
        self.state = VisionState.IDLE

    def status(self):

        return {
            "state": self.state.value
        }