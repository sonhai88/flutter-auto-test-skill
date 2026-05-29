#!/bin/bash
# Send fake push notification to app (test foreground/background handling)
# Usage: ./push-notification.sh <bundle_id> <payload_json_file_or_inline>
# Example: ./push-notification.sh com.wssv.itg.dev /tmp/payload.json
# Inline:  ./push-notification.sh com.wssv.itg.dev '{"aps":{"alert":"New message"}}'

source "$(dirname "$0")/_common.sh"

BUNDLE_ID="$1"
PAYLOAD="$2"

if [ -z "$BUNDLE_ID" ] || [ -z "$PAYLOAD" ]; then
  cat <<EOF >&2
Usage: $0 <bundle_id> <payload_json_file_or_inline>

Examples:
  $0 com.wssv.itg.dev /tmp/notification.json
  $0 com.wssv.itg.dev '{"aps":{"alert":"Test"}}'

Sample payload:
  {
    "aps": {
      "alert": {
        "title": "New Message",
        "body": "You have a new message from user X"
      },
      "badge": 1,
      "sound": "default"
    },
    "custom_data": "anything"
  }
EOF
  exit 1
fi

# If PAYLOAD looks like JSON (starts with {), write to temp file
if [[ "$PAYLOAD" == "{"* ]]; then
  TMP_FILE=$(timestamp_file "push-payload" "json")
  echo "$PAYLOAD" > "$TMP_FILE"
  PAYLOAD="$TMP_FILE"
fi

PLATFORM=$(get_platform)
case "$PLATFORM" in
  ios)
    UDID=$(get_ios_udid)
    log "🔔 Sending push to $BUNDLE_ID on $UDID"
    xcrun simctl push "$UDID" "$BUNDLE_ID" "$PAYLOAD"
    ;;
  android)
    log "❌ Android push test cần Firebase CLI hoặc adb shell am broadcast — TODO"
    exit 1
    ;;
  *) log "❌ No device booted"; exit 1 ;;
esac
