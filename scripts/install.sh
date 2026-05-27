#!/bin/bash
# Install script — tạo symlink ~/.claude/skills/flutter-auto-test/ → repo này

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$HOME/.claude/skills/flutter-auto-test"

echo "📦 Installing flutter-auto-test skill..."
echo "  Repo:  $REPO_DIR"
echo "  Skill: $SKILL_DIR"

if [ -L "$SKILL_DIR" ]; then
  echo "  ✓ Symlink đã tồn tại — re-link"
  rm "$SKILL_DIR"
elif [ -d "$SKILL_DIR" ]; then
  echo "  ⚠️  $SKILL_DIR là folder thật, không phải symlink"
  echo "     Backup → ${SKILL_DIR}.backup-$(date +%Y%m%d)"
  mv "$SKILL_DIR" "${SKILL_DIR}.backup-$(date +%Y%m%d)"
fi

ln -s "$REPO_DIR" "$SKILL_DIR"
echo "  ✓ Symlinked"

# Verify SKILL.md accessible
if [ -f "$SKILL_DIR/SKILL.md" ]; then
  echo "  ✓ SKILL.md found"
else
  echo "  ❌ SKILL.md not found!"
  exit 1
fi

# Create auto-memory pointer
AUTO_MEM_FILE="$HOME/.claude/projects/-Users-macos/memory/project_flutter_auto_test_skill.md"
mkdir -p "$(dirname "$AUTO_MEM_FILE")"

cat > "$AUTO_MEM_FILE" <<EOF
---
name: flutter-auto-test-skill
description: AI auditor skill cho Flutter project. Repo $REPO_DIR, symlinked vào ~/.claude/skills/flutter-auto-test/. Self-improving qua FP database + pattern lifecycle + per-screen memory.
metadata:
  type: project
---

# Flutter Auto Test Skill

**Repo**: $REPO_DIR
**Symlink**: ~/.claude/skills/flutter-auto-test/
**Obsidian mirror**: /Volumes/hai/Notes/2.0 Projects/flutter-auto-test-skill/
**Installed**: $(date +%Y-%m-%d)
**Version**: $(cat "$REPO_DIR/VERSION")

## Mục đích

Thay thế ~70% workload tester thật cho Flutter — verify Figma fidelity, design system compliance, architecture rules.

## Khi nào kích hoạt

- User gõ \`/flutter-auto-test <screen>\`
- User nói "audit screen X", "kiểm tra UI Y khớp Figma chưa", "test compliance Z"
- Trước commit feature Flutter

## Quy trình 7 step

1. Bootstrap: detect project, load configs
2. Pre-flight: read files, fetch Figma nếu có
3. Run checks (parallel): tokens / architecture / icons
4. Anti-FP filter qua 4 gates (FP db → quirks → exceptions → confidence)
5. Generate report markdown
6. Update memory (per-screen, history)
7. Prompt feedback từ anh → parse → learn

## Self-Learning

- FP confirmed → append memory/false-positives.yaml
- Pattern mới → propose memory/new-patterns.yaml
- Quirk → append memory/per-project/<p>/screens/<s>.yaml
- Lifecycle: PROPOSED → TESTING (14 ngày) → VALIDATED → ACTIVE → DEPRECATED
- Manual approve mọi state transition (KHÔNG auto)

## Projects covered

- itg-mobile (placeholder config, chưa scan thật)

## Reference

- Related skills: lme-flutter, flutter-architecture, mobile-design
- Git mining cron: scripts/mine-git-history.sh (chưa setup)
- Obsidian sync: scripts/sync-obsidian.sh
EOF

echo "  ✓ Auto-memory pointer created: $AUTO_MEM_FILE"

# Update MEMORY.md index nếu entry chưa có
MEMORY_INDEX="$HOME/.claude/projects/-Users-macos/memory/MEMORY.md"
if [ -f "$MEMORY_INDEX" ]; then
  if ! grep -q "project_flutter_auto_test_skill" "$MEMORY_INDEX"; then
    echo "- [flutter-auto-test-skill](project_flutter_auto_test_skill.md) — AI auditor skill cho Flutter, self-improving, thay 70% workload tester" >> "$MEMORY_INDEX"
    echo "  ✓ MEMORY.md index updated"
  else
    echo "  ✓ MEMORY.md index entry already exists"
  fi
fi

echo ""
echo "✅ Install complete!"
echo ""
echo "Test bằng cách restart Claude Code → gõ:"
echo "  /flutter-auto-test <path-to-flutter-screen>"
echo ""
echo "Hoặc nói tự nhiên:"
echo "  audit cho anh màn hình lib/features/auth/login_screen.dart"
