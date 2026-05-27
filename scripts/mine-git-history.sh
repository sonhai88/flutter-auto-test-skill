#!/bin/bash
# Git History Mining — extract bug patterns từ fix commits
# Chạy weekly: 0 2 * * 0 (mỗi Chủ nhật 2am)
#
# Usage:
#   ./mine-git-history.sh <project_repo_path> [--since "1 week ago"]

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_REPO="${1:-}"
SINCE="${2:-1 week ago}"

if [ -z "$PROJECT_REPO" ]; then
  echo "Usage: $0 <project_repo_path> [--since 'time']"
  echo "Example: $0 /Volumes/hai/itg-mobile --since '1 week ago'"
  exit 1
fi

if [ ! -d "$PROJECT_REPO/.git" ]; then
  echo "❌ Not a git repo: $PROJECT_REPO"
  exit 1
fi

echo "⛏  Mining git history..."
echo "  Project: $PROJECT_REPO"
echo "  Since:   $SINCE"

cd "$PROJECT_REPO"

# Lấy fix commits trong window
COMMITS=$(git log --since="$SINCE" --grep="^fix" -i --format="%H" 2>/dev/null)
COMMIT_COUNT=$(echo "$COMMITS" | grep -c . || echo "0")

if [ "$COMMIT_COUNT" -eq 0 ]; then
  echo "  ℹ  Không có fix commit nào trong window"
  exit 0
fi

echo "  Found $COMMIT_COUNT fix commits"

# Output buffer
PROPOSALS_FILE="/tmp/flutter-auto-test-proposals-$(date +%Y%m%d).md"
> "$PROPOSALS_FILE"

cat >> "$PROPOSALS_FILE" <<EOF
# Pattern Mining Proposals — $(date +%Y-%m-%d)

Project: $PROJECT_REPO
Window: $SINCE
Commits analyzed: $COMMIT_COUNT

## Commits

EOF

for COMMIT in $COMMITS; do
  echo "## $COMMIT" >> "$PROPOSALS_FILE"
  echo "" >> "$PROPOSALS_FILE"
  echo "Message:" >> "$PROPOSALS_FILE"
  echo '```' >> "$PROPOSALS_FILE"
  git log -1 --format="%s%n%n%b" "$COMMIT" >> "$PROPOSALS_FILE"
  echo '```' >> "$PROPOSALS_FILE"
  echo "" >> "$PROPOSALS_FILE"
  echo "Files changed:" >> "$PROPOSALS_FILE"
  echo '```' >> "$PROPOSALS_FILE"
  git show --stat --format="" "$COMMIT" | head -20 >> "$PROPOSALS_FILE"
  echo '```' >> "$PROPOSALS_FILE"
  echo "" >> "$PROPOSALS_FILE"
  echo "Diff (first 50 lines):" >> "$PROPOSALS_FILE"
  echo '```diff' >> "$PROPOSALS_FILE"
  git show --format="" "$COMMIT" | head -50 >> "$PROPOSALS_FILE"
  echo '```' >> "$PROPOSALS_FILE"
  echo "" >> "$PROPOSALS_FILE"
  echo "---" >> "$PROPOSALS_FILE"
  echo "" >> "$PROPOSALS_FILE"
done

echo "  ✓ Proposals dumped → $PROPOSALS_FILE"

# Send to Claude API (TODO: implement claude_analyze call)
# For now, output cho anh review manual
echo ""
echo "📋 Next step: review $PROPOSALS_FILE → cho Claude phân tích → append memory/new-patterns.yaml"
echo ""
echo "Hoặc mở Claude Code:"
echo "  /flutter-auto-test mine-from $PROPOSALS_FILE"

# Telegram notification (nếu có TG_BOT_TOKEN env)
if [ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
  curl -s -X POST "https://api.telegram.org/bot${TG_BOT_TOKEN}/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d text="📊 Pattern mining done — $COMMIT_COUNT commits. Review: $PROPOSALS_FILE" \
    > /dev/null
  echo "  ✓ Telegram notified"
fi
