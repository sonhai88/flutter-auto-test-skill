#!/bin/bash
# Tap on element by text or coordinates (via Maestro)
# Usage:
#   ./tap.sh "Đăng nhập"            # tap by text
#   ./tap.sh --xy 200 400           # tap by pixel coords
#   ./tap.sh --id "loginButton"     # tap by accessibility id

source "$(dirname "$0")/_common.sh"

MODE=""
TARGET=""

case "$1" in
  --xy)
    MODE=xy
    X="$2"; Y="$3"
    ;;
  --id)
    MODE=id
    TARGET="$2"
    ;;
  *)
    MODE=text
    TARGET="$1"
    ;;
esac

# Generate inline maestro flow
TMP_FLOW=$(timestamp_file "tap-flow" "yaml")

cat > "$TMP_FLOW" <<EOF
appId: "*"
---
EOF

case "$MODE" in
  text)
    cat >> "$TMP_FLOW" <<EOF
- tapOn: "$TARGET"
EOF
    ;;
  id)
    cat >> "$TMP_FLOW" <<EOF
- tapOn:
    id: "$TARGET"
EOF
    ;;
  xy)
    cat >> "$TMP_FLOW" <<EOF
- tapOn:
    point: "${X},${Y}"
EOF
    ;;
esac

log "👆 Tap mode=$MODE target=${TARGET:-${X},${Y}}"
maestro test "$TMP_FLOW" 2>&1 | tail -5
