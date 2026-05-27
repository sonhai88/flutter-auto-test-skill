# flutter-auto-test-skill

AI auditor cho Flutter project — Claude Code skill thay thế ~70% workload tester. Self-improving qua memory + pattern lifecycle.

## Tính năng

- ✅ **Figma fidelity** — code khớp design không
- ✅ **Design system compliance** — LmeColors, LmeTypography, LmeSpacing
- ✅ **Architecture rules** — Riverpod + Dio + GoRouter 7 rule cứng
- ✅ **Icons compliance** — LmeIcons mandatory, cấm Material Icons
- ✅ **i18n check** — text tiếng Việt có dấu, không hardcode
- ✅ **States coverage** — loading / error / empty / success

**Self-improving**:
- False-positive database (đã sai 1 lần, KHÔNG sai lần 2)
- Per-screen memory (skip rule có context hợp lý)
- Multi-project config (cùng rule, project khác xử lý khác)
- Pattern lifecycle (PROPOSED → TESTING → ACTIVE → DEPRECATED)
- Git mining cron (extract bug pattern từ fix commit)

## Install

```bash
cd ~/code/projects/flutter-auto-test-skill
./scripts/install.sh
```

Script tạo symlink: `~/.claude/skills/flutter-auto-test/` → repo này.

## Sử dụng

Trong Claude Code:

```
/flutter-auto-test lib/features/auth/login_screen.dart
/flutter-auto-test lib/features/auth/login_screen.dart --figma https://figma.com/design/ABC/?node-id=63-121
/flutter-auto-test --project itg-mobile --all-screens
```

## Cấu trúc

```
core/         Universal rules (immutable per version)
projects/     Per-project config (rule overrides)
memory/       Learning data (FP db, patterns, per-screen)
reports/      Audit history (gitignored)
scripts/      Automation (install, sync, mining)
prompts/      LLM prompts
```

## Feedback Loop

Sau mỗi audit, anh có thể reply:

```
FP: states-coverage.missing-loading ở LoginScreen.dart:42 — dùng AsyncValue.when
Bug pattern mới: thấy ai cũng quên dispose controller
Quirk: LoginScreen line 42-45 skip tokens.no-hardcode (legacy migrate sprint 12)
```

Skill auto-parse → update memory → propose commit.

## Sync Obsidian

```bash
./scripts/sync-obsidian.sh
```

Mirror learnings + reports vào `/Volumes/hai/Notes/2.0 Projects/flutter-auto-test-skill/`.

## Versioning

Semantic: `1.MINOR.PATCH`
- MAJOR = breaking schema change
- MINOR = new rule added / rule promoted
- PATCH = bug fix, FP suppression, tuning

Bump version khi commit:
- Add rule → MINOR
- Promote pattern PROPOSED → ACTIVE → MINOR
- FP suppression added → PATCH
