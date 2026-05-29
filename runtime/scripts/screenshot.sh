#!/bin/bash
# Capture screenshot from booted device
# Usage: ./screenshot.sh [output_path] [--label some-label]
# Output: prints path to PNG file

source "$(dirname "$0")/_common.sh"

LABEL="${LABEL:-screen}"
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --label) LABEL="$2"; shift 2 ;;
    *) OUTPUT="$1"; shift ;;
  esac
done

[ -z "$OUTPUT" ] && OUTPUT=$(timestamp_file "$LABEL" "png")

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    log "📸 iOS screenshot: $UDID → $OUTPUT"
    xcrun simctl io "$UDID" screenshot "$OUTPUT" 2>&1 | grep -v "Detected file type" >&2
    ;;
  android)
    SERIAL=$(get_android_serial)
    log "📸 Android screenshot: $SERIAL → $OUTPUT"
    adb -s "$SERIAL" exec-out screencap -p > "$OUTPUT"
    ;;
  none)
    log "❌ No device/simulator booted"
    exit 1
    ;;
esac

echo "$OUTPUT"
