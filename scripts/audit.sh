#!/bin/bash
# Audit CLI wrapper
# Convenience cho chạy ngoài Claude Code (CI, cron, manual scripting)
#
# Usage:
#   ./audit.sh <file_path> [--project <slug>] [--figma <url>]
#
# Note: hiện script này CHỈ generate prompt + path, không gọi Claude API trực tiếp.
# Future: tích hợp Claude API SDK.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE_PATH="${1:-}"
PROJECT=""
FIGMA_URL=""

if [ -z "$FILE_PATH" ]; then
  echo "Usage: $0 <file_path> [--project <slug>] [--figma <url>]"
  exit 1
fi

# Parse args
shift
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --figma)   FIGMA_URL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Auto-detect project nếu không pass
if [ -z "$PROJECT" ]; then
  # Walk up tìm pubspec.yaml
  CURRENT="$(dirname "$FILE_PATH")"
  while [ "$CURRENT" != "/" ]; do
    if [ -f "$CURRENT/pubspec.yaml" ]; then
      PROJECT_ROOT="$CURRENT"
      PROJECT="$(basename "$CURRENT")"
      break
    fi
    CURRENT="$(dirname "$CURRENT")"
  done
fi

if [ -z "$PROJECT" ]; then
  echo "❌ Cannot detect project. Pass --project <slug>"
  exit 1
fi

CONFIG_FILE="$REPO_DIR/projects/${PROJECT}.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "⚠️  No config for $PROJECT. Create from template:"
  echo "    cp $REPO_DIR/projects/_template.yaml $CONFIG_FILE"
  echo "    # then edit values"
  exit 1
fi

# For now, just print what would be audited
cat <<EOF
🔍 Audit Plan

  File:    $FILE_PATH
  Project: $PROJECT
  Config:  $CONFIG_FILE
  Figma:   ${FIGMA_URL:-(none)}

📋 Next step:

  Mở Claude Code và gõ:
    /flutter-auto-test $FILE_PATH${FIGMA_URL:+ --figma $FIGMA_URL}

  Hoặc tự nhiên:
    audit cho anh $FILE_PATH${FIGMA_URL:+ với Figma $FIGMA_URL}

📁 Output sẽ ghi vào:
  $REPO_DIR/reports/$(date +%Y-%m-%d)/$PROJECT/$(basename "$FILE_PATH" .dart).md

EOF
