#!/bin/bash
# Common helpers for runtime audit scripts
# Source this from other scripts: source "$(dirname "$0")/_common.sh"

# Ensure Maestro is in PATH
export PATH="$HOME/.maestro/bin:$PATH"
export MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true

# Artifacts folder (gitignored)
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$HOME/.flutter-auto-test/artifacts/$(date +%Y-%m-%d)}"
mkdir -p "$ARTIFACTS_DIR"

# Detect booted iOS simulator (first one)
get_ios_udid() {
  xcrun simctl list devices booted 2>/dev/null \
    | grep -oE '\([A-F0-9-]{36}\)' \
    | head -1 \
    | tr -d '()'
}

# Detect connected Android device (first one)
get_android_serial() {
  adb devices 2>/dev/null | grep -v "List of" | awk '/device$/ {print $1; exit}'
}

# Detect which platform is available (prefer iOS)
get_platform() {
  if [ -n "$(get_ios_udid)" ]; then
    echo "ios"
  elif [ -n "$(get_android_serial)" ]; then
    echo "android"
  else
    echo "none"
  fi
}

# Timestamped filename
timestamp_file() {
  local prefix="${1:-out}"
  local ext="${2:-txt}"
  echo "$ARTIFACTS_DIR/${prefix}-$(date +%H%M%S).${ext}"
}

# Log to stderr (so stdout is clean for parseable output)
log() {
  echo "[$(date +%H:%M:%S)] $*" >&2
}
