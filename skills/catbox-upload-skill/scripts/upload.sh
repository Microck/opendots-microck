#!/bin/bash
set -e

# Catbox/Litterbox File Uploader - Wrapper Script
# This script wraps the Python upload.py for use as an AI skill

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/upload.py"

# Check if Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
  echo "Error: upload.py not found at $PYTHON_SCRIPT" >&2
  exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
  echo "Error: python3 is not installed" >&2
  exit 1
fi

# Check if requests library is available
if ! python3 -c "import requests" 2>/dev/null; then
  echo "Error: requests library not found. Install with: pip install requests" >&2
  exit 1
fi

# Parse arguments
SERVICE="litterbox"
TIME="24h"
USERHASH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service)
      SERVICE="$2"
      shift 2
      ;;
    --time)
      TIME="$2"
      shift 2
      ;;
    --userhash)
      USERHASH="$2"
      shift 2
      ;;
    *)
      FILE_PATH="$1"
      shift
      ;;
  esac
done

# Check if file path is provided
if [ -z "$FILE_PATH" ]; then
  echo "Error: File path is required" >&2
  echo "Usage: $0 <file_path> [--service <service>] [--time <time>] [--userhash <hash>]" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  --service     Service to use: litterbox (default) or catbox" >&2
  echo "  --time        Litterbox expiration: 1h, 12h, 24h, 72h (default: 24h)" >&2
  echo "  --userhash    Catbox account hash (required for catbox service)" >&2
  echo "" >&2
  echo "Services and limits:" >&2
  echo "  Litterbox: 1GB, 1h-72h" >&2
  echo "  Catbox: 200MB, permanent" >&2
  exit 1
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH" >&2
  exit 1
fi

# Build Python command
PYTHON_CMD="python3 $PYTHON_SCRIPT $FILE_PATH"

if [ "$SERVICE" != "litterbox" ]; then
  PYTHON_CMD="$PYTHON_CMD --service $SERVICE"
fi

if [ "$TIME" != "24h" ]; then
  PYTHON_CMD="$PYTHON_CMD --time $TIME"
fi

if [ -n "$USERHASH" ]; then
  PYTHON_CMD="$PYTHON_CMD --userhash $USERHASH"
fi

# Execute Python script
$PYTHON_CMD
