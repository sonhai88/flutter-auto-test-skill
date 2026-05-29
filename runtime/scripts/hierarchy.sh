#!/bin/bash
# Dump UI hierarchy (accessibility tree) of current screen
# Usage: ./hierarchy.sh [--save] [--filter "text=login"]
# Output: JSON tree

source "$(dirname "$0")/_common.sh"

SAVE=0
FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --save) SAVE=1; shift ;;
    --filter) FILTER="$2"; shift 2 ;;
    *) shift ;;
  esac
done

log "🌳 Reading UI hierarchy via Maestro..."

if [ $SAVE -eq 1 ]; then
  OUTPUT=$(timestamp_file "hierarchy" "json")
  maestro hierarchy > "$OUTPUT" 2>/dev/null
  log "Saved → $OUTPUT"
  echo "$OUTPUT"
else
  maestro hierarchy 2>/dev/null
fi
