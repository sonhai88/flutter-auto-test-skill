#!/bin/bash
# Type text into focused input field
# Usage: ./type-text.sh "hello@example.com"

source "$(dirname "$0")/_common.sh"

TEXT="$1"
if [ -z "$TEXT" ]; then
  echo "Usage: $0 <text>" >&2
  exit 1
fi

TMP_FLOW=$(timestamp_file "type-flow" "yaml")
cat > "$TMP_FLOW" <<EOF
appId: "*"
---
- inputText: "$TEXT"
EOF

log "⌨️  Typing: $TEXT"
maestro test "$TMP_FLOW" 2>&1 | tail -5
