#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/KALEN_AI"
cd "$ROOT"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        KALEN VOICE AUTO-INTEGRATOR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ------------------------------------------------------------
# 1. Detect Flutter frontend
# ------------------------------------------------------------
if [ -d "$ROOT/kalen_vet" ]; then
    FLUTTER="$ROOT/kalen_vet"
elif [ -d "$ROOT/kalen_flutter" ]; then
    FLUTTER="$ROOT/kalen_flutter"
else
    FLUTTER=""
fi

echo "[1/10] Project detection"

if [ -z "$FLUTTER" ]; then
    echo "ERROR: No Flutter frontend found."
    echo "Expected:"
    echo "  $ROOT/kalen_vet"
    echo "or"
    echo "  $ROOT/kalen_flutter"
    exit 1
fi

echo "Backend : $ROOT"
echo "Flutter : $FLUTTER"

# ------------------------------------------------------------
# 2. Backup
# ------------------------------------------------------------
echo "[2/10] Creating backup"

BACKUP="$ROOT/.kalen_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP"

cp -a "$ROOT/backend" "$BACKUP/backend" 2>/dev/null || true
cp -a "$FLUTTER/lib" "$BACKUP/flutter_lib" 2>/dev/null || true
cp "$ROOT/requirements.txt" "$BACKUP/" 2>/dev/null || true
cp "$FLUTTER/pubspec.yaml" "$BACKUP/" 2>/dev/null || true

echo "Backup: $BACKUP"

# ------------------------------------------------------------
# 3. Backend directories
# ------------------------------------------------------------
echo "[3/10] Preparing FastAPI voice layer"

mkdir -p "$ROOT/backend/services"

touch "$ROOT/backend/services/__init__.py"

# ------------------------------------------------------------
# 4. Speech service
# ------------------------------------------------------------
cat > "$ROOT/backend/services/voice_service.py" <<'PY'
import os
from pathlib import Path
from typing import Optional

from openai import OpenAI


class VoiceService:
    """
    KALEN Voice engine.

    Flow:
        audio -> Whisper STT -> transcript
        transcript -> existing KALEN LLM
        response -> OpenAI TTS -> audio
    """

    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")

        if not api_key:
            raise RuntimeError(
                "OPENAI_API_KEY is not configured."
            )

        self.client = OpenAI(api_key=api_key)

    def transcribe(self, audio_path: str) -> dict:
        with open(audio_path, "rb") as audio:
            result = self.client.audio.transcriptions.create(
                model=os.getenv(
                    "KALEN_STT_MODEL",
                    "whisper-1",
                ),
                file=audio,
                response_format="verbose_json",
            )

        language = getattr(result, "language", None)
        text = getattr(result, "text", "")

        return {
            "text": text.strip(),
            "language": language,
        }

    def synthesize(
        self,
        text: str,
        output_path: str,
        voice: Optional[str] = None,
    ) -> str:

        voice = voice or os.getenv(
            "KALEN_TTS_VOICE",
            "alloy",
        )

        response = self.client.audio.speech.create(
            model=os.getenv(
                "KALEN_TTS_MODEL",
                "gpt-4o-mini-tts",
            ),
            voice=voice,
            input=text,
            response_format="mp3",
        )

        response.write_to_file(output_path)

        return output_path
PY

# ------------------------------------------------------------
# 5. FastAPI voice endpoint
# ------------------------------------------------------------
cat > "$ROOT/backend/api/voice.py" <<'PY'
import os
import tempfile
from pathlib import Path

from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import FileResponse

from backend.services.voice_service import VoiceService


router = APIRouter(
    prefix="/voice",
    tags=["Voice"],
)


SYSTEM_PROMPT = """
You are KALEN, an intelligent multilingual AI assistant.

Detect the language of the user's latest message automatically.

Respond in the same language as the user unless the user explicitly
requests another language.

Do not translate the user's request unless translation was requested.

Keep the response natural and conversational for voice output.
Avoid unnecessary markdown, tables, code fences, or visual formatting
when answering through voice.
""".strip()


@router.post("/transcribe")
async def transcribe_voice(
    audio: UploadFile = File(...)
):
    suffix = Path(audio.filename or ".wav").suffix or ".wav"

    try:
        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=suffix,
        ) as temp:
            data = await audio.read()
            temp.write(data)
            temp_path = temp.name

        service = VoiceService()
        result = service.transcribe(temp_path)

        return {
            "success": True,
            "text": result["text"],
            "language": result["language"],
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Speech-to-text failed: {exc}",
        )

    finally:
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

    output = tempfile.NamedTemporaryFile(
        delete=False,
        suffix=".mp3",
    )
    output.close()

    try:
        service = VoiceService()

        service.synthesize(
            text=text,
            output_path=output.name,
            voice=payload.get("voice"),
        )

        return FileResponse(
            output.name,
            media_type="audio/mpeg",
            filename="kalen_response.mp3",
        )

    except Exception as exc:
        try:
            os.unlink(output.name)
        except Exception:
            pass

        raise HTTPException(
            status_code=500,
            detail=f"Text-to-speech failed: {exc}",
        )
PY

# ------------------------------------------------------------
# 6. Inject router into FastAPI main.py
# ------------------------------------------------------------
echo "[4/10] Connecting Voice router"

MAIN="$ROOT/backend/main.py"

python3 - "$MAIN" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

import_line = "from backend.api.voice import router as voice_router"

if import_line not in text:
    lines = text.splitlines()

    insert_at = 0

    for i, line in enumerate(lines):
        if line.startswith("from ") or line.startswith("import "):
            insert_at = i + 1

    lines.insert(insert_at, import_line)
    text = "\n".join(lines) + "\n"

include_line = "app.include_router(voice_router)"

if include_line not in text:
    text += f"\n{include_line}\n"

path.write_text(text)
PY

# ------------------------------------------------------------
# 7. Requirements
# ------------------------------------------------------------
echo "[5/10] Checking Python dependencies"

REQ="$ROOT/requirements.txt"

touch "$REQ"

grep -q '^openai' "$REQ" || echo "openai>=1.100.0" >> "$REQ"
grep -q '^python-multipart' "$REQ" || echo "python-multipart>=0.0.20" >> "$REQ"

if [ -x "$ROOT/venv/bin/pip" ]; then
    "$ROOT/venv/bin/pip" install -q \
        "openai>=1.100.0" \
        "python-multipart>=0.0.20"
else
    echo "WARNING: $ROOT/venv/bin/pip not found."
fi

# ------------------------------------------------------------
# 8. Flutter voice service
# ------------------------------------------------------------
echo "[6/10] Creating Flutter Voice service"

mkdir -p "$FLUTTER/lib/core/services"

cat > "$FLUTTER/lib/core/services/kalen_voice_service.dart" <<'DART'
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class KalenVoiceService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String baseUrl;

  KalenVoiceService({
    required this.baseUrl,
  });

  Future<bool> startRecording() async {
    final allowed = await _recorder.hasPermission();

    if (!allowed) {
      return false;
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: '',
    );

    return true;
  }

  Future<File?> stopRecording() async {
    final path = await _recorder.stop();

    if (path == null || path.isEmpty) {
      return null;
    }

    return File(path);
  }

  Future<Map<String, dynamic>> transcribe(File audio) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/voice/transcribe'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audio.path,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'KALEN STT HTTP ${response.statusCode}: $body',
      );
    }

    return {
      'raw': body,
    };
  }

  Future<void> playTts(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/voice/tts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: '{"text":${_jsonString(text)}}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'KALEN TTS HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final directory = await getTemporaryDirectory();

    final file = File(
      '${directory.path}/kalen_response.mp3',
    );

    await file.writeAsBytes(response.bodyBytes);

    await _player.play(
      DeviceFileSource(file.path),
    );
  }

  String _jsonString(String value) {
    return '"${value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')}"';
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
DART

# ------------------------------------------------------------
# 9. Flutter dependencies
# ------------------------------------------------------------
echo "[7/10] Updating Flutter dependencies"

python3 - "$FLUTTER/pubspec.yaml" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

deps = {
    "http": "http: ^1.5.0",
    "record": "record: ^6.1.2",
    "audioplayers": "audioplayers: ^6.5.0",
    "path_provider": "path_provider: ^2.1.5",
}

for key, line in deps.items():
    if key not in text:
        marker = "dependencies:"
        if marker in text:
            text = text.replace(
                marker,
                marker + "\n  " + line,
                1,
            )

path.write_text(text)
PY

cd "$FLUTTER"

flutter pub get

# ------------------------------------------------------------
# 10. Android microphone permission
# ------------------------------------------------------------
echo "[8/10] Checking Android microphone permission"

MANIFEST="$FLUTTER/android/app/src/main/AndroidManifest.xml"

if [ -f "$MANIFEST" ]; then
    python3 - "$MANIFEST" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

permission = '<uses-permission android:name="android.permission.RECORD_AUDIO"/>'

if permission not in text:
    text = text.replace(
        "<manifest",
        "<manifest",
        1,
    )

    pos = text.find(">")

    if pos != -1:
        text = (
            text[:pos + 1]
            + "\n    "
            + permission
            + "\n"
            + text[pos + 1:]
        )

path.write_text(text)
PY
fi

# ------------------------------------------------------------
# Format Flutter
# ------------------------------------------------------------
echo "[9/10] Formatting and validating"

dart format "$FLUTTER/lib" >/dev/null 2>&1 || true

# Python compilation
cd "$ROOT"

if [ -x "$ROOT/venv/bin/python" ]; then
    "$ROOT/venv/bin/python" -m compileall -q backend || {
        echo "Python compilation failed."
        exit 1
    }
else
    python3 -m compileall -q backend || {
        echo "Python compilation failed."
        exit 1
    }
fi

# Flutter analysis
cd "$FLUTTER"

ANALYZE_LOG="$(mktemp)"

if ! flutter analyze >"$ANALYZE_LOG" 2>&1; then
    echo "Flutter analyzer found issues:"
    cat "$ANALYZE_LOG"

    echo
    echo "Attempting automatic Flutter repair..."

    flutter clean >/dev/null 2>&1 || true
    flutter pub get >/dev/null 2>&1 || true
    dart format lib >/dev/null 2>&1 || true

    if ! flutter analyze >/dev/null 2>&1; then
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "VOICE INTEGRATION INSTALLED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
        echo "Remaining Flutter errors require inspection."
        echo "Backup: $BACKUP"
        exit 2
    fi
fi

rm -f "$ANALYZE_LOG"

# ------------------------------------------------------------
# Backend route check
# ------------------------------------------------------------
echo "[10/10] Checking FastAPI application"

cd "$ROOT"

if [ -x "$ROOT/venv/bin/python" ]; then
    "$ROOT/venv/bin/python" - <<'PY'
from backend.main import app

routes = {
    getattr(route, "path", "")
    for route in app.routes
}

required = {
    "/voice/transcribe",
    "/voice/tts",
}

missing = required - routes

if missing:
    print("Missing routes:", missing)
    raise SystemExit(1)

print("FastAPI voice routes: OK")
for route in sorted(required):
    print("  ", route)
PY
else
    python3 - <<'PY'
from backend.main import app

routes = {
    getattr(route, "path", "")
    for route in app.routes
}

required = {
    "/voice/transcribe",
    "/voice/tts",
}

missing = required - routes

if missing:
    print("Missing routes:", missing)
    raise SystemExit(1)

print("FastAPI voice routes: OK")
PY
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          KALEN VOICE READY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Flutter : $FLUTTER"
echo "STT     : Whisper"
echo "Language: Automatic"
echo "TTS     : OpenAI"
echo "Routes  : /voice/transcribe"
echo "          /voice/tts"
echo
echo "Backup  : $BACKUP"
echo
echo "Required environment variable:"
echo "  OPENAI_API_KEY"
echo
echo "Example:"
echo "  export OPENAI_API_KEY='YOUR_KEY'"
echo
echo "Then start KALEN normally."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

