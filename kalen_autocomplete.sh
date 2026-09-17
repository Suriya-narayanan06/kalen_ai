#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/KALEN_AI"
FLUTTER="$ROOT/kalen_vet"
BACKEND="$ROOT/backend"
VENV="$ROOT/venv"

LOG_DIR="$ROOT/.kalen_automation"
LOG="$LOG_DIR/run.log"
mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG") 2>&1

echo "============================================================"
echo " KALEN VET AI — AUTONOMOUS COMPLETION ENGINE"
echo "============================================================"
echo "Started: $(date)"
echo "Root:    $ROOT"
echo

cd "$ROOT"

# ------------------------------------------------------------
# SAFETY: verify expected project structure
# ------------------------------------------------------------

if [[ ! -d "$FLUTTER" ]]; then
    echo "ERROR: Flutter project not found: $FLUTTER"
    exit 1
fi

if [[ ! -d "$BACKEND" ]]; then
    echo "ERROR: Backend directory not found: $BACKEND"
    exit 1
fi

# ------------------------------------------------------------
# Git checkpoint
# ------------------------------------------------------------

echo "[1/10] Git inspection"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git status --short || true

    if [[ -n "$(git status --porcelain)" ]]; then
        echo
        echo "Existing changes detected."
        echo "Creating safety checkpoint..."
        git add -A
        git commit -m "kalen-autocomplete checkpoint $(date +%Y%m%d-%H%M%S)" \
            || echo "Checkpoint commit skipped."
    fi
fi

# ------------------------------------------------------------
# Inventory
# ------------------------------------------------------------

echo
echo "[2/10] Inspecting project"

echo "--- Flutter ---"
find "$FLUTTER/lib" -maxdepth 4 -type f 2>/dev/null | sort || true

echo
echo "--- Backend ---"
find "$BACKEND" -maxdepth 4 -type f 2>/dev/null | sort || true

echo
echo "--- Configuration ---"
printf '%s\n' \
    "$FLUTTER/pubspec.yaml" \
    "$FLUTTER/android/app/build.gradle" \
    "$FLUTTER/android/app/src/main/AndroidManifest.xml" \
    "$FLUTTER/linux/CMakeLists.txt" \
    "$BACKEND/main.py" \
    "$ROOT/requirements.txt" \
    "$ROOT/.gitignore"

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

echo
echo "[3/10] Environment"

flutter --version || true
dart --version || true
python3 --version || true
cmake --version | head -1 || true

if [[ -f "$VENV/bin/activate" ]]; then
    # shellcheck disable=SC1091
    source "$VENV/bin/activate"
fi

python --version || true

# ------------------------------------------------------------
# Flutter dependencies
# ------------------------------------------------------------

echo
echo "[4/10] Flutter dependency validation"

cd "$FLUTTER"

flutter pub get

# ------------------------------------------------------------
# Format
# ------------------------------------------------------------

echo
echo "[5/10] Formatting Dart"

dart format lib

# ------------------------------------------------------------
# Static analysis
# ------------------------------------------------------------

echo
echo "[6/10] Flutter analyzer"

ANALYZE_LOG="$LOG_DIR/flutter_analyze.log"

if ! flutter analyze 2>&1 | tee "$ANALYZE_LOG"; then
    echo
    echo "Flutter analyzer reported errors."
    echo "Automatic source repair is intentionally conservative."
    echo "The exact analyzer output is stored at:"
    echo "$ANALYZE_LOG"
fi

# ------------------------------------------------------------
# Backend validation
# ------------------------------------------------------------

echo
echo "[7/10] Backend validation"

cd "$ROOT"

if [[ -d "$BACKEND" ]]; then

    echo "--- Python compilation ---"

    find "$BACKEND" -name "*.py" -print0 |
        xargs -0 -r python -m py_compile

    echo
    echo "--- FastAPI import ---"

    python - <<'PY'
import importlib

try:
    module = importlib.import_module("backend.main")
    app = getattr(module, "app", None)

    if app is None:
        raise RuntimeError("backend.main does not expose FastAPI app")

    print("FastAPI import: OK")
    print("Application:", app)

except Exception as exc:
    print("FastAPI import failed:")
    print(type(exc).__name__ + ":", exc)
    raise
PY

    echo
    echo "--- OpenAPI registration ---"

    python - <<'PY'
from backend.main import app

routes = sorted(
    (getattr(r, "methods", set()), getattr(r, "path", ""))
    for r in app.routes
)

for methods, path in routes:
    print(",".join(sorted(methods)), path)

print()
print("Registered routes:", len(routes))
PY

fi

# ------------------------------------------------------------
# Linux dependency diagnosis
# ------------------------------------------------------------

echo
echo "[8/10] Linux dependency/build validation"

cd "$FLUTTER"

LINUX_LOG="$LOG_DIR/linux_build.log"

if flutter build linux --debug 2>&1 | tee "$LINUX_LOG"; then
    echo "Linux debug build: PASS"
else
    echo
    echo "Linux build failed."
    echo "Inspecting dependency requirements..."

    AUDIO_CMAKE="$HOME/.pub-cache"

    if [[ -d "$AUDIO_CMAKE" ]]; then
        grep -RniE \
            'pkg_check_modules|find_package|REQUIRED|gio|glib|gstreamer|pulse|alsa' \
            "$AUDIO_CMAKE/hosted/pub.dev/audioplayers_linux"* \
            2>/dev/null | head -100 || true
    fi

    echo
    echo "Linux build remains pending root-cause diagnosis."
fi

# ------------------------------------------------------------
# Android debug build
# ------------------------------------------------------------

echo
echo "[9/10] Android validation"

ANDROID_LOG="$LOG_DIR/android_build.log"

if flutter build apk --debug 2>&1 | tee "$ANDROID_LOG"; then
    echo "Android debug build: PASS"

    echo
    echo "Attempting release build..."

    if flutter build apk --release 2>&1 | tee "$LOG_DIR/android_release.log"; then
        echo "Android release build: PASS"
    else
        echo "Android release build failed."
    fi
else
    echo "Android debug build failed."
fi

# ------------------------------------------------------------
# Final recheck
# ------------------------------------------------------------

echo
echo "[10/10] Final recheck"

flutter analyze 2>&1 | tee "$LOG_DIR/final_analyze.log" || true

echo
echo "============================================================"
echo " KALEN AUTONOMOUS RUN COMPLETE"
echo "============================================================"
echo
echo "Logs:"
echo "  $LOG"
echo "  $LOG_DIR/"
echo

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Git status:"
    git status --short || true
fi

echo
echo "IMPORTANT:"
echo "This runner does NOT blindly overwrite existing source."
echo "It does NOT delete modules."
echo "It does NOT replace the project."
echo "It validates first and preserves a Git rollback point."
echo
echo "Finished: $(date)"
