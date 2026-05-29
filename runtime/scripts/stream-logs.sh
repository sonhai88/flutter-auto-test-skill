#!/bin/bash
# Stream Flutter/native logs from booted device
# Usage: ./stream-logs.sh [--seconds N] [--filter PATTERN] [--bundle BUNDLE_ID]
# Output: log lines, parseable

source "$(dirname "$0")/_common.sh"

SECONDS_LIMIT=10
FILTER=""
BUNDLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --seconds) SECONDS_LIMIT="$2"; shift 2 ;;
    --filter) FILTER="$2"; shift 2 ;;
    --bundle) BUNDLE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    OUTPUT=$(timestamp_file "logs" "txt")
    log "📋 Streaming logs ${SECONDS_LIMIT}s from $UDID → $OUTPUT"

    # macOS doesn't have `timeout` by default — use background + kill pattern
    if [ -n "$BUNDLE" ]; then
      xcrun simctl spawn "$UDID" log stream --level=debug --predicate "process == \"${BUNDLE##*.}\"" > "$OUTPUT" 2>/dev/null &
    else
      xcrun simctl spawn "$UDID" log stream --level=debug > "$OUTPUT" 2>/dev/null &
    fi
    LOG_PID=$!
    sleep "$SECONDS_LIMIT"
    kill -TERM $LOG_PID 2>/dev/null
    wait $LOG_PID 2>/dev/null

    if [ -n "$FILTER" ]; then
      grep -E "$FILTER" "$OUTPUT" | head -50
    else
      # Default: extract Flutter errors + exceptions
      grep -iE "(exception|error|flutter:|EXCEPTION CAUGHT|PlatformException|Unhandled)" "$OUTPUT" | head -30
    fi

    log "Full log: $OUTPUT"
    ;;
  android)
    SERIAL=$(get_android_serial)
    OUTPUT=$(timestamp_file "logs-android" "txt")
    log "📋 Streaming Android logs ${SECONDS_LIMIT}s"
    adb -s "$SERIAL" logcat > "$OUTPUT" 2>/dev/null &
    LOG_PID=$!
    sleep "$SECONDS_LIMIT"
    kill -TERM $LOG_PID 2>/dev/null
    wait $LOG_PID 2>/dev/null
    grep -iE "(flutter|exception|error)" "$OUTPUT" | head -50
    ;;
  *) log "❌ No device booted"; exit 1 ;;
esac
