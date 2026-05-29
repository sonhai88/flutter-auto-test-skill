#!/bin/bash
# Launch app on booted simulator/device
# Usage: ./launch-app.sh <bundle_id> [--cold] [--terminate-first]
# Example: ./launch-app.sh com.wssv.itg.dev --cold

source "$(dirname "$0")/_common.sh"

BUNDLE_ID="$1"
shift

COLD=0
TERMINATE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cold) COLD=1; shift ;;
    --terminate-first) TERMINATE=1; shift ;;
    *) shift ;;
  esac
done

if [ -z "$BUNDLE_ID" ]; then
  echo "Usage: $0 <bundle_id> [--cold] [--terminate-first]" >&2
  exit 1
fi

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    if [ $TERMINATE -eq 1 ] || [ $COLD -eq 1 ]; then
      log "🛑 Terminating $BUNDLE_ID"
      xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null
      sleep 0.5
    fi
    log "🚀 Launching $BUNDLE_ID on $UDID"
    xcrun simctl launch "$UDID" "$BUNDLE_ID"
    ;;
  android)
    SERIAL=$(get_android_serial)
    if [ $TERMINATE -eq 1 ] || [ $COLD -eq 1 ]; then
      log "🛑 Force-stopping $BUNDLE_ID"
      adb -s "$SERIAL" shell am force-stop "$BUNDLE_ID"
    fi
    log "🚀 Launching $BUNDLE_ID on $SERIAL"
    adb -s "$SERIAL" shell monkey -p "$BUNDLE_ID" -c android.intent.category.LAUNCHER 1 2>&1 | tail -2
    ;;
  *) log "❌ No device booted"; exit 1 ;;
esac
