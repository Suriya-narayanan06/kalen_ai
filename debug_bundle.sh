#!/usr/bin/env bash
set -u

OUT="debug_bundle_$(date +%Y%m%d_%H%M%S).txt"

{
    echo "===== KALEN AI DEBUG BUNDLE ====="
    echo "Date: $(date)"
    echo

    echo "===== PROJECT ====="
    pwd
    echo

    echo "===== GIT STATUS ====="
    git status --short 2>&1
    echo

    echo "===== PYTHON ====="
    python3 --version 2>&1
    echo

    echo "===== FASTAPI / UVICORN ====="
    python3 -m pip show fastapi uvicorn pydantic 2>&1
    echo

    echo "===== BACKEND TREE ====="
    find backend -maxdepth 3 -type f \
        \( -name "*.py" -o -name "*.json" -o -name "*.toml" \) \
        -print 2>/dev/null
    echo

    echo "===== PYTHON SOURCE ====="
    while IFS= read -r file; do
        echo
        echo "========== $file =========="
        sed -n '1,300p' "$file"
    done < <(find backend -type f -name "*.py" | sort)

    echo
    echo "===== RECENT LOGS ====="
    if [ -f backend.log ]; then
        tail -n 200 backend.log
    fi

    echo
    echo "===== FLUTTER ====="
    flutter --version 2>&1 | head -n 5
    echo

    if [ -d kalen_flutter ]; then
        echo "===== FLUTTER ANALYZE ====="
        cd kalen_flutter
        flutter analyze 2>&1
    fi

} > "$OUT"

echo "Debug bundle created:"
echo "$OUT"
echo
echo "Send/upload this file to ChatGPT."
