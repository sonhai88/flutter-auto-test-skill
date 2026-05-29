#!/bin/bash
# Override status bar for clean screenshots / edge case tests
# Usage: ./status-bar.sh apple              # Apple marketing standard
#        ./status-bar.sh low-battery        # Low battery edge case
#        ./status-bar.sh bad-signal         # Bad signal edge case
#        ./status-bar.sh clear              # Reset

source "$(dirname "$0")/_common.sh"

MODE="${1:-apple}"

PLATFORM=$(get_platform)
if [ "$PLATFORM" != "ios" ]; then
  log "❌ Status bar override iOS-only"
  exit 1
fi

UDID=$(get_ios_udid)

case "$MODE" in
  apple)
    # Apple marketing default: 9:41, full signal, full battery, wifi
    log "🍎 Apple marketing status bar"
    xcrun simctl status_bar "$UDID" override \
      --time "9:41" \
      --dataNetwork wifi \
      --wifiMode active \
      --wifiBars 3 \
      --cellularMode active \
      --cellularBars 4 \
      --batteryState charged \
      --batteryLevel 100
    ;;
  low-battery)
    log "🪫 Low battery edge case"
    xcrun simctl status_bar "$UDID" override \
      --time "9:41" \
      --batteryState discharging \
      --batteryLevel 5
    ;;
  bad-signal)
    log "📶 Bad signal edge case"
    xcrun simctl status_bar "$UDID" override \
      --time "9:41" \
      --dataNetwork lte \
      --cellularMode active \
      --cellularBars 1 \
      --wifiMode searching
    ;;
  no-signal)
    log "✈️ No signal / airplane edge case"
    xcrun simctl status_bar "$UDID" override \
      --time "9:41" \
      --dataNetwork hide \
      --wifiMode failed \
      --cellularMode notSupported
    ;;
  clear|reset)
    log "🔄 Clear status bar override"
    xcrun simctl status_bar "$UDID" clear
    ;;
  *)
    log "❌ Unknown mode: $MODE"
    log "Available: apple | low-battery | bad-signal | no-signal | clear"
    exit 1
    ;;
esac
