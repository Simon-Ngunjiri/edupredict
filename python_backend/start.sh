#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# start.sh  —  Launch EduPredict API with Gunicorn (Linux / macOS)
# ─────────────────────────────────────────────────────────────────────────────
# Usage:
#   chmod +x start.sh
#   ./start.sh
#
# Optional env overrides:
#   PORT=8000 ./start.sh
#   WEB_CONCURRENCY=2 ./start.sh
#   LOG_LEVEL=debug ./start.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check that model files exist
if [ ! -f "logistic_model.joblib" ] || [ ! -f "scaler.joblib" ]; then
  echo ""
  echo "  ⚠  Model files not found!"
  echo "  Run this first:  python train_model.py"
  echo ""
  exit 1
fi

# Check that gunicorn is installed
if ! command -v gunicorn &> /dev/null; then
  echo ""
  echo "  ⚠  Gunicorn not found!"
  echo "  Run this first:  pip install -r requirements.txt"
  echo ""
  exit 1
fi

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║      EduPredict API — Gunicorn       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  Binding  →  0.0.0.0:${PORT:-5000}"
echo "  Workers  →  ${WEB_CONCURRENCY:-auto}"
echo "  Config   →  gunicorn.conf.py"
echo ""

gunicorn --config gunicorn.conf.py app:app
