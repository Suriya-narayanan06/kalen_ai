import os


class VisionConfig:
    """
    Configuration for the KALEN Vision engine.

    The model/provider can be changed through environment variables
    without modifying the application code.
    """

    provider = os.getenv("KALEN_VISION_PROVIDER", "placeholder")
    model = os.getenv("KALEN_VISION_MODEL", "none")
    enabled = os.getenv("KALEN_VISION_ENABLED", "false").lower() == "true"
