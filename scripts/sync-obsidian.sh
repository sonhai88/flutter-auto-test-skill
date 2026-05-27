#!/bin/bash
# Sync learnings + reports vào Obsidian vault
# Chạy manual hoặc cron weekly

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OBSIDIAN_DIR="/Volumes/hai/Notes/2.0 Projects/flutter-auto-test-skill"

echo "🔄 Syncing → Obsidian..."

mkdir -p "$OBSIDIAN_DIR"

# Copy readable parts (KHÔNG sync data binary)
cp "$REPO_DIR/README.md"       "$OBSIDIAN_DIR/README.md"
cp "$REPO_DIR/CHANGELOG.md"    "$OBSIDIAN_DIR/CHANGELOG.md"
cp "$REPO_DIR/VERSION"          "$OBSIDIAN_DIR/VERSION.md"
cp "$REPO_DIR/memory/tuning-history.md" "$OBSIDIAN_DIR/tuning-history.md"

# Symlink memory folder (anh đọc Obsidian = reflect git latest)
if [ ! -L "$OBSIDIAN_DIR/memory" ]; then
  rm -rf "$OBSIDIAN_DIR/memory"
  ln -s "$REPO_DIR/memory" "$OBSIDIAN_DIR/memory"
  echo "  ✓ memory/ symlinked"
fi

# Symlink reports folder (nếu có)
if [ -d "$REPO_DIR/reports" ] && [ ! -L "$OBSIDIAN_DIR/reports" ]; then
  ln -s "$REPO_DIR/reports" "$OBSIDIAN_DIR/reports"
  echo "  ✓ reports/ symlinked"
fi

# Generate weekly summary
WEEK_FILE="$OBSIDIAN_DIR/weekly-$(date +%Y-W%V).md"
if [ ! -f "$WEEK_FILE" ]; then
  cat > "$WEEK_FILE" <<EOF
# Week $(date +%Y-W%V) Summary

## New FPs

$(grep -A 3 "status: active" "$REPO_DIR/memory/false-positives.yaml" 2>/dev/null | head -20 || echo "(none)")

## New Patterns Proposed

$(grep -A 2 "status: PROPOSED" "$REPO_DIR/memory/new-patterns.yaml" 2>/dev/null | head -20 || echo "(none)")

## Audits This Week

$(ls "$REPO_DIR/reports/$(date +%Y-%m-%d)/" 2>/dev/null | head -10 || echo "(none yet)")

## Action Items for Anh

- [ ] Review proposed patterns
- [ ] Confirm/reject FPs
- [ ] Update project configs nếu cần

EOF
  echo "  ✓ Created $WEEK_FILE"
fi

echo "✅ Sync complete!"
echo "   Open: $OBSIDIAN_DIR"
