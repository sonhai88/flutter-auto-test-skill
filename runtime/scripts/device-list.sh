#!/bin/bash
# List booted iOS simulators + connected Android devices
# Usage: ./device-list.sh [--json]

source "$(dirname "$0")/_common.sh"

JSON_MODE=0
[[ "$1" == "--json" ]] && JSON_MODE=1

if [ $JSON_MODE -eq 1 ]; then
  echo '{'
  echo '  "ios": ['
  xcrun simctl list devices booted 2>/dev/null \
    | grep -E '^\s+[A-Za-z]' \
    | awk -F'(' '{
        name=$1; gsub(/^[ \t]+|[ \t]+$/,"",name);
        udid=$2; gsub(/\).*/,"",udid);
        print "    {\"name\":\"" name "\", \"udid\":\"" udid "\"},"
      }' \
    | sed '$ s/,$//'
  echo '  ],'
  echo '  "android": ['
  adb devices 2>/dev/null | grep -v "List of" | awk '/device$/ {print "    {\"serial\":\"" $1 "\"},"}' | sed '$ s/,$//'
  echo '  ]'
  echo '}'
else
  echo "📱 iOS Simulators (booted):"
  xcrun simctl list devices booted 2>/dev/null | grep -E '^\s+[A-Za-z]' || echo "  (none)"
  echo ""
  echo "🤖 Android devices:"
  adb devices 2>/dev/null | grep -v "List of" | grep -E "device$" || echo "  (none)"
fi
