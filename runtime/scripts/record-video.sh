#!/bin/bash
# Record video of simulator screen
# Usage: ./record-video.sh [output.mp4] [--seconds N]

source "$(dirname "$0")/_common.sh"

OUTPUT=""
SECS=15

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds) SECS="$2"; shift 2 ;;
    *) OUTPUT="$1"; shift ;;
  esac
done

[ -z "$OUTPUT" ] && OUTPUT=$(timestamp_file "video" "mp4")

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    log "🎥 Recording ${SECS}s → $OUTPUT"
    # simctl recordVideo runs until SIGINT
    xcrun simctl io "$UDID" recordVideo --codec=h264 "$OUTPUT" &
    PID=$!
    sleep "$SECS"
    kill -INT $PID
    wait $PID 2>/dev/null
    log "Saved: $OUTPUT"
    echo "$OUTPUT"
    ;;
  android)
    SERIAL=$(get_android_serial)
    REMOTE_PATH="/sdcard/screenrecord-$$.mp4"
    log "🎥 Recording ${SECS}s Android"
    adb -s "$SERIAL" shell screenrecord --time-limit "$SECS" "$REMOTE_PATH"
    adb -s "$SERIAL" pull "$REMOTE_PATH" "$OUTPUT"
    adb -s "$SERIAL" shell rm "$REMOTE_PATH"
    echo "$OUTPUT"
    ;;
  *) log "❌ No device booted"; exit 1 ;;
esac
