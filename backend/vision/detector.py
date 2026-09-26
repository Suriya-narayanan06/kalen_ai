import os
import urllib.request
import time
from pathlib import Path
from pathlib import Path
from typing import Any

import cv2
import numpy as np


DEFAULT_CLASSES = [
    "person", "bicycle", "car", "motorcycle", "airplane", "bus", "train",
    "truck", "boat", "traffic light", "fire hydrant", "stop sign",
    "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep",
    "cow", "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella",
    "handbag", "tie", "suitcase", "frisbee", "skis", "snowboard",
    "sports ball", "kite", "baseball bat", "baseball glove", "skateboard",
    "surfboard", "tennis racket", "bottle", "wine glass", "cup", "fork",
    "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange",
    "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair",
    "couch", "potted plant", "bed", "dining table", "toilet", "tv",
    "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave",
    "oven", "toaster", "sink", "refrigerator", "book", "clock", "vase",
    "scissors", "teddy bear", "hair drier", "toothbrush",
]




YOLOV4_WEIGHTS_URL = os.getenv(
    "KALEN_YOLO_WEIGHTS_URL",
    "https://github.com/AlexeyAB/darknet/releases/download/"
    "darknet_yolo_v3_optimal/yolov4.weights",
)


def _ensure_yolov4_weights(weights_path: str) -> bool:
    """Ensure YOLOv4 weights exist before OpenCV loads the network."""
    path = Path(weights_path)

    if path.exists() and path.stat().st_size > 200_000_000:
        return True

    try:
        path.parent.mkdir(parents=True, exist_ok=True)

        tmp = path.with_suffix(".weights.download")

        if tmp.exists():
            tmp.unlink()

        print("[KALEN VISION] Downloading YOLOv4 weights...")
        urllib.request.urlretrieve(YOLOV4_WEIGHTS_URL, tmp)

        if not tmp.exists() or tmp.stat().st_size < 200_000_000:
            if tmp.exists():
                tmp.unlink()
            print("[KALEN VISION] Invalid YOLOv4 weights download.")
            return False

        tmp.replace(path)
        print(
            f"[KALEN VISION] YOLOv4 weights ready: "
            f"{path.stat().st_size / 1024 / 1024:.1f} MB"
        )
        return True

    except Exception as exc:
        print(f"[KALEN VISION] Weight provisioning failed: {exc}")
        return False

class VisionDetector:
    """
    YOLOv4 adapter.

    Set these environment variables for real inference:
      KALEN_YOLO_CFG=/absolute/path/yolov4.cfg
      KALEN_YOLO_WEIGHTS=/absolute/path/yolov4.weights
      KALEN_YOLO_NAMES=/absolute/path/coco.names

    Without model files the API returns an empty result instead of pretending
    that detections are real.
    """

    def __init__(self) -> None:
        self.cfg = os.getenv("KALEN_YOLO_CFG") or str(Path(__file__).resolve().parent / "models" / "yolov4.cfg")
        self.weights = os.getenv("KALEN_YOLO_WEIGHTS") or str(Path(__file__).resolve().parent / "models" / "yolov4.weights")
        self.names = os.getenv("KALEN_YOLO_NAMES") or str(Path(__file__).resolve().parent / "models" / "coco.names")
        self.net = None
        self.classes = self._load_classes()
        self.model_name = "YOLOv4"
        self.real_model_loaded = False
        self._load_model()

    def _load_classes(self) -> list[str]:
        if self.names and Path(self.names).exists():
            return [
                line.strip()
                for line in Path(self.names).read_text().splitlines()
                if line.strip()
            ]
        return DEFAULT_CLASSES

    def _load_model(self) -> None:
        if not self.cfg or not self.weights:
            return
        if not Path(self.cfg).exists() or not Path(self.weights).exists():
            return

        self.net = cv2.dnn.readNetFromDarknet(self.cfg, self.weights)
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCV)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)
        self.real_model_loaded = True
        print("[KALEN VISION] REAL YOLOv4 MODEL LOADED")

    def detect(
        self,
        image_bytes: bytes,
        mode: str,
        confidence_threshold: float,
    ) -> dict[str, Any]:
        image = cv2.imdecode(np.frombuffer(image_bytes, np.uint8), cv2.IMREAD_COLOR)
        if image is None:
            raise ValueError("Could not decode image.")

        height, width = image.shape[:2]

        if not self.real_model_loaded or self.net is None:
            return {
                "model": self.model_name,
                "image_width": width,
                "image_height": height,
                "objects": [],
                "mode": mode,
                "message": "YOLOv4 model files are not configured.",
            }

        blob = cv2.dnn.blobFromImage(
            image,
            1 / 255.0,
            (416, 416),
            swapRB=True,
            crop=False,
        )
        self.net.setInput(blob)

        layer_names = self.net.getLayerNames()
        output_layers = [
            layer_names[i - 1]
            for i in self.net.getUnconnectedOutLayers().flatten()
        ]
        outputs = self.net.forward(output_layers)

        boxes: list[list[int]] = []
        scores: list[float] = []
        class_ids: list[int] = []

        for output in outputs:
            for detection in output:
                objectness = float(detection[4])
                scores_raw = detection[5:]
                class_id = int(np.argmax(scores_raw))
                confidence = objectness * float(scores_raw[class_id])

                if confidence < confidence_threshold:
                    continue

                center_x = int(detection[0] * width)
                center_y = int(detection[1] * height)
                box_w = int(detection[2] * width)
                box_h = int(detection[3] * height)

                x = max(0, int(center_x - box_w / 2))
                y = max(0, int(center_y - box_h / 2))

                boxes.append([x, y, box_w, box_h])
                scores.append(confidence)
                class_ids.append(class_id)

        indices = cv2.dnn.NMSBoxes(
            boxes,
            scores,
            confidence_threshold,
            0.45,
        )

        objects = []
        for result_id, raw_index in enumerate(np.array(indices).flatten()):
            x, y, box_w, box_h = boxes[int(raw_index)]
            class_id = class_ids[int(raw_index)]

            objects.append(
                {
                    "id": result_id,
                    "class": (
                        self.classes[class_id]
                        if class_id < len(self.classes)
                        else f"class_{class_id}"
                    ),
                    "confidence": scores[int(raw_index)],
                    "bbox": {
                        "x": x,
                        "y": y,
                        "width": box_w,
                        "height": box_h,
                    },
                    "track_id": None,
                }
            )

        return {
            "model": self.model_name,
            "image_width": width,
            "image_height": height,
            "objects": objects,
            "mode": mode,
        }
