#!/bin/bash
# Open deep link / universal link on booted device
# Usage: ./deep-link.sh <url>
# Example: ./deep-link.sh "itg://message/123"

source "$(dirname "$0")/_common.sh"

URL="$1"
if [ -z "$URL" ]; then
  echo "Usage: $0 <url>" >&2
  exit 1
fi

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    log "🔗 Opening URL on iOS sim: $URL"
    xcrun simctl openurl "$UDID" "$URL"
    ;;
  android)
    SERIAL=$(get_android_serial)
    log "🔗 Opening URL on Android: $URL"
    adb -s "$SERIAL" shell am start -a android.intent.action.VIEW -d "$URL"
    ;;
  *) log "❌ No device booted"; exit 1 ;;
esac
