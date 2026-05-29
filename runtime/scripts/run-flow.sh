#!/bin/bash
# Run a Maestro flow YAML file with screenshot at each step
# Usage: ./run-flow.sh <flow.yaml> [--screenshots-dir DIR]

source "$(dirname "$0")/_common.sh"

FLOW="$1"
shift

SCREENSHOTS_DIR="$ARTIFACTS_DIR/flow-$(basename "$FLOW" .yaml)-$(date +%H%M%S)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --screenshots-dir) SCREENSHOTS_DIR="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [ -z "$FLOW" ] || [ ! -f "$FLOW" ]; then
  echo "Usage: $0 <flow.yaml>" >&2
  exit 1
fi

mkdir -p "$SCREENSHOTS_DIR"
log "▶️  Running flow: $FLOW"
log "📸 Screenshots → $SCREENSHOTS_DIR"

# Maestro saves screenshots into current directory via takeScreenshot command,
# so cd into screenshots dir to keep them organized
( cd "$SCREENSHOTS_DIR" && maestro test "$FLOW" )

EXIT_CODE=$?
log "Flow done (exit=$EXIT_CODE)"
log "Screenshots: $SCREENSHOTS_DIR"
echo "$SCREENSHOTS_DIR"
exit $EXIT_CODE
