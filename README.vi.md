<div align="center">

# 🔍 flutter-auto-test-skill

### AI auditor cho Flutter — thay thế 70% workload tester

**Verify Figma fidelity · Design system compliance · Architecture rules** — tất cả qua một Claude Code skill học từ feedback của anh và sắc bén hơn sau mỗi audit.

[![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](./CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-D97757?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/skills)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](#license)
[![Self-improving](https://img.shields.io/badge/self--improving-yes-success)](#-self-improvement-loop)

🌐 [English](./README.md) · **[Tiếng Việt](./README.vi.md)**

</div>

---

## 💡 Tại sao có skill này

Mọi team Flutter sớm muộn cũng gặp QA cliff giống nhau:

```
Sprint 1:  3 màn hình, 1 tester, check tay vẫn ổn
Sprint 8:  40 màn hình, 1 tester, regression mỗi release
Sprint 12: 80 màn hình, thuê thêm 2 tester? hay automate?
```

Skill AI code review hiện có hay fail vì 1 trong 3 lý do:

| 🚫 Vấn đề | Chuyện gì xảy ra |
|---|---|
| **False positive lặp lại** | Session 1 báo `missing-loading`, anh correct: "đã có AsyncValue.when". Session 2 báo lại. Session 3 anh tắt skill. |
| **Không nhớ context project** | itg-mobile cho phép `Color.fromARGB` cho gradient, lsite-mobile cấm. Rule chung = noise = bị ignore. |
| **Không tích lũy pattern** | Tuần 1 anh tìm ra bug X. Tuần 3 dev khác viết lại bug X. Skill không học. |

**Skill này fix cả 3 ngay từ design.**

---

## ✨ Skill catch được gì

<table>
<tr>
<td width="50%">

### 🎨 Design System Compliance
- Hardcode color → đề xuất design token
- Spacing tùy ý → đề xuất scale `{4, 8, 12, 16, 24...}`
- Font size lệch type scale
- Border radius drift khỏi system

</td>
<td width="50%">

### 🏗️ Architecture Rules
- Riverpod pattern (autoDispose, không setState)
- Dio interceptor có chưa
- GoRouter type-safe + guards
- Repository pattern + Result type
- Không throw cross-layer

</td>
</tr>
<tr>
<td>

### 🎭 Figma Fidelity *(v1.1+)*
- Đọc Figma spec qua MCP
- So sánh fontSize/color/padding pixel-by-pixel
- Flag drift giữa code và design

</td>
<td>

### 🧩 Icons Compliance
- Material Icons → flag để thay bằng DS
- Cupertino Icons → flag
- Import `material.dart` không cần thiết

</td>
</tr>
<tr>
<td>

### 🌐 i18n Check *(v1.1+)*
- Hardcode chuỗi tiếng Việt/Nhật
- Thiếu key localization
- Fallback không nhất quán

</td>
<td>

### 🎬 States Coverage *(v1.1+)*
- Thiếu state `loading` / `error` / `empty` / `success`
- Suy từ notifier transitions

</td>
</tr>
</table>

---

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/sonhai88/flutter-auto-test-skill.git
cd flutter-auto-test-skill

# 2. Install (tạo symlink ~/.claude/skills/flutter-auto-test/)
./scripts/install.sh

# 3. Restart Claude Code, sau đó trong bất kỳ project Flutter nào:
```

```
/flutter-auto-test lib/features/auth/login_screen.dart
```

Hoặc gõ tự nhiên:
> *"audit cho anh màn hình LoginPage"*
> *"check compliance file home_page.dart"*
> *"xem code khớp Figma chưa, URL: figma.com/design/.../?node-id=63-121"*

---

## 🛡️ Cách skill tránh false positive — 4-gate filter

```
                       Phát hiện issue candidate
                                 │
                                 ▼
            ┌──────────────────────────────────────────┐
            │  GATE 1 ─ False-Positive Database        │
            │  memory/false-positives.yaml             │
            │  Match rule_id + pattern signature?      │
            │  ─────────────────────────────────────── │
            │  ✓ match → SUPPRESS (log "fp-001")       │
            └─────────────────┬────────────────────────┘
                              │ không match
                              ▼
            ┌──────────────────────────────────────────┐
            │  GATE 2 ─ Per-Screen Quirks              │
            │  memory/per-project/<p>/screens/<s>.yaml │
            │  Line trong exception range của screen?  │
            │  ─────────────────────────────────────── │
            │  ✓ match → SUPPRESS (có lý do)           │
            └─────────────────┬────────────────────────┘
                              │ không match
                              ▼
            ┌──────────────────────────────────────────┐
            │  GATE 3 ─ Project Exceptions             │
            │  projects/<project>.yaml                 │
            │  Rule có exception cho project này?      │
            │  ─────────────────────────────────────── │
            │  ✓ match → DOWNGRADE (error → warn)      │
            └─────────────────┬────────────────────────┘
                              │
                              ▼
            ┌──────────────────────────────────────────┐
            │  GATE 4 ─ Confidence Score               │
            │  confidence = AST_match × 0.7            │
            │             + context_match × 0.3        │
            │  ─────────────────────────────────────── │
            │  ≥0.9 → giữ severity                     │
            │  0.6-0.9 → downgrade thành WARN          │
            │  <0.6 → hạ xuống INFO (cần review tay)   │
            └─────────────────┬────────────────────────┘
                              │
                              ▼
                  ✅ FLAG với evidence + fix
```

**Mỗi issue được flag PHẢI có**:
- File + line number
- Code snippet (bằng chứng)
- Đề xuất fix
- Confidence score
- Lý do (vì sao rule này apply)

Không có output kiểu "looks correct overall". Không claim mơ hồ. Chỉ evidence.

---

## 🧠 Self-Improvement Loop

Skill **sắc bén hơn sau mỗi audit**. Ba cơ chế:

### 1. Feedback Parser

Sau mỗi report, anh có thể reply tự nhiên:

```
"FP: tokens-compliance.no-hardcode-color ở SplashPage.dart:175 — SystemUiOverlayStyle config"
"Bug pattern mới: dev hay quên dispose TextEditingController"
"Quirk: HomePage line 558-668 skip tokens.no-hardcode-color vì BottomNav legacy"
"OK fix nhé"
```

Skill parse → propose YAML update → bump version → commit memory change.

### 2. Pattern Lifecycle

Bug pattern KHÔNG được human nhập tay — chúng **mined từ git history** của anh và graduate qua các validation stages:

```
┌──────────┐    detect từ git log --grep="fix:"
│ DETECTED │    hoặc anh report tay
└────┬─────┘
     ▼
┌──────────┐    Auto-save vào memory/new-patterns.yaml
│ PROPOSED │    Chờ anh approve
└────┬─────┘
     ▼
┌──────────┐    Active trong MỘT project (testing window)
│ TESTING  │    Track tỷ lệ true/false positive
└────┬─────┘    Cần: ≥3 TP, ≤10% FP rate, ≥14 ngày
     ▼
┌──────────┐    Promote vào core/checks/
│ VALIDATED│    Apply cross TẤT CẢ projects
└────┬─────┘
     ▼
┌──────────┐    Live trong production rule set
│ ACTIVE   │
└────┬─────┘
     ▼
┌──────────┐    Nếu FP rate tăng vọt hoặc rule lỗi thời
│DEPRECATED│
└──────────┘
```

### 3. Multi-Project Config Layering

Cùng 1 rule, project khác nhau, xử lý khác nhau:

```yaml
# core/rules.yaml ─ universal defaults
tokens-compliance.no-hardcode-color:
  severity: error

                ↓ override per project
                
# projects/itg-mobile.yaml ─ legacy stack
tokens-compliance.no-hardcode-color:
  severity: warn        # downgrade — chưa có design system
  exceptions:
    - pattern: Color.fromARGB
      context: gradient_overlay

                ↓ override per screen
                
# memory/per-project/itg-mobile/screens/HomePage.yaml
quirks:
  - rule_id: tokens-compliance.no-hardcode-color
    line_range: [558, 668]
    reason: BottomNav legacy widget, package-locked colors
```

---

## 📊 Ví dụ thực tế

Audit **4 màn hình** của 1 app Flutter 170k dòng trong ngày đầu tiên:

| Màn hình | Lines | Score | Hardcode | print() debug |
|---|---|---|---|---|
| SplashPage | 207 | 88/100 | 3 | 11 |
| LoginPage | 309 | 38/100 | 19 | 3 |
| RegisterPage | 501 | 14/100 | 27 | 4 |
| HomePage | 811 | 11/100 | 28 | 23 |
| **Total** | **1,828** | **37.75 trung bình** | **77** | **41** |

**Findings ngày 1**:
- 77 hardcode colors → đề xuất extract `AppColors` (1 ngày work)
- 41 `print()` debug statements → đề xuất migrate logger
- Cross-screen pattern auto-promoted PROPOSED → TESTING (`pattern-2026-05-27-001`)
- 1 false positive identified và add vào global FP database (`fp-001` SystemUiOverlayStyle exempt)

**Expected sau khi fix Priority 1**: avg score 37.75 → **76.25** (+38.5 lift).

> [Full audit reports đây](./reports/2026-05-27/itg-mobile/) — bao gồm weekly summary và feedback demo.

---

## 📂 Cấu trúc Project

```
flutter-auto-test-skill/
├── SKILL.md                          # Entry point — Claude đọc trước
├── VERSION                           # Semantic version (1.0.1)
├── CHANGELOG.md
│
├── core/                             ┐
│   ├── rules.yaml                    │  KNOWLEDGE LAYER
│   ├── severity-matrix.yaml          │  Universal rules + thresholds
│   ├── confidence-thresholds.yaml    │  (immutable per skill version)
│   └── checks/                       │
│       ├── 02-tokens-compliance.md   │
│       ├── 03-architecture.md        │
│       └── 04-icons-compliance.md    ┘
│
├── projects/                         ┐
│   ├── _template.yaml                │  CONTEXT LAYER
│   ├── itg-mobile.yaml               │  Per-project config
│   └── lsite-mobile.yaml             │  (rule overrides, exceptions)
│                                     ┘
├── memory/                           ┐
│   ├── false-positives.yaml          │  LEARNING LAYER
│   ├── new-patterns.yaml             │  (FP db, proposed patterns,
│   ├── tuning-history.md             │   per-screen quirks)
│   ├── per-project/                  │
│   │   └── itg-mobile/               │
│   │       ├── overview.md           │
│   │       └── screens/              │
│   │           ├── LoginPage.yaml    │
│   │           ├── HomePage.yaml     │
│   │           └── _index.yaml       │
│   └── cross-project-patterns/       │
│       └── promoted.yaml             ┘
│
├── reports/                          ⚠ gitignored — local only
│   └── YYYY-MM-DD/
│       └── <project>/<screen>.md
│
├── prompts/                          ┐
│   ├── audit-screen.md               │  LLM PROMPTS
│   ├── feedback-parser.md            │  (tách rời với checks)
│   └── pattern-miner.md              ┘
│
└── scripts/                          ┐
    ├── install.sh                    │  AUTOMATION
    ├── sync-obsidian.sh              │
    ├── audit.sh                      │
    └── mine-git-history.sh           ┘
```

---

## ⚙️ Configuration

### 1. Tạo project config

```bash
cp projects/_template.yaml projects/my-app.yaml
```

### 2. Fill stack của anh

```yaml
project: my-app
root_path: /path/to/your/flutter/project

stack:
  flutter: 3.27.0
  riverpod: 2.5.0
  go_router: 14.0.0
  dio: 5.4.0
  design_system: lme_ui@2.1.0      # hoặc "custom" hoặc "none"

figma:
  file_key: ABC123XYZ              # lấy từ figma.com/design/<file_key>/

rules:
  tokens-compliance.no-hardcode-color:
    severity: error
    exceptions: []                  # add khi anh confirm

metrics:
  release_score_min: 85
  enabled_checks:
    - tokens-compliance
    - architecture
    - icons-compliance
```

### 3. (Optional) Notify Telegram weekly summary

```yaml
notify:
  telegram_chat_id: 123456
```

---

## 🗺️ Roadmap

### v1.0 ─ Foundation *(hiện tại)*
- [x] 3 core checks: tokens / architecture / icons
- [x] 4-gate anti-FP filtering
- [x] Multi-project config layering
- [x] FP database + per-screen quirks
- [x] Pattern lifecycle (PROPOSED → TESTING)
- [x] Manual feedback loop

### v1.1 ─ Figma + Coverage
- [ ] Figma fidelity check qua MCP
- [ ] i18n check
- [ ] States coverage (loading/error/empty/success)
- [ ] Git history mining cron
- [ ] CI integration qua GitHub Actions

### v1.2 ─ Spec & Contract
- [ ] Spec compliance (markdown → code trace)
- [ ] API contract check (OpenAPI → Dio calls)
- [ ] State machine validation
- [ ] Cross-file analysis

### v2.0 ─ Web Dashboard *(stretch)*
- [ ] React dashboard cho QA lead
- [ ] Trending qua các release
- [ ] Tích hợp Jira

---

## 🤝 Workflow Integration

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1 ─ Dev local (skill này)                              │
│ Dev code → /flutter-auto-test → fix → commit                 │
│ Cost: free (trong Claude Code subscription)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2 ─ Pre-commit hook (planned)                          │
│ git commit → fast tokens/icons check → block nếu có error    │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│ LAYER 3 ─ CI merge gate (v1.1)                               │
│ PR open → full audit changed screens → PR comment            │
│ Cost: API tokens per audit (~$0.20/PR)                       │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│ LAYER 4 ─ Nightly full scan (v1.1)                           │
│ Cron 3am → all screens → trend vs baseline → Telegram notify │
└─────────────────────────────────────────────────────────────┘
```

---

## ❌ Skill này KHÔNG phải gì

Honest matters:

- **❌ KHÔNG thay thế tester thật** — thay ~70% compliance work. Exploratory testing, UX feel, real-device quirks vẫn cần người.
- **❌ KHÔNG phải runtime test** — verify code structure, KHÔNG verify app behavior khi chạy. Cặp với [`patrol`](https://patrol.leancode.co) cho E2E.
- **❌ KHÔNG phải linter** — Dart analyzer + linter vẫn cần cho syntax/style. Skill này catch **semantic compliance** (design system, architecture, spec).
- **❌ KHÔNG perfect** — false positive vẫn xảy ra. Cả ý nghĩa của FP database là làm cho FP xảy ra **chỉ MỘT lần**.

---

## 🧑‍💻 Contributing

Đây là project solo dev tune cho Flutter stack cụ thể (lme_ui + Riverpod + Dio + GoRouter), nhưng PR welcome cho:

- Add project template mới (`projects/<your-stack>.yaml`)
- Đề xuất check mới (`core/checks/NN-<name>.md`)
- Cải thiện detection regex / AST pattern
- Documentation / examples

Fork → branch → PR. Chạy `./scripts/install.sh` local để test.

---

## 📚 Tools liên quan

| Tool | Mục đích | Khi nào dùng |
|---|---|---|
| [patrol](https://patrol.leancode.co) | E2E testing | Critical user flows |
| [golden_toolkit](https://pub.dev/packages/golden_toolkit) | Visual regression | Design system snapshots |
| [mocktail](https://pub.dev/packages/mocktail) | Unit test mocking | Business logic tests |
| [very_good_analysis](https://pub.dev/packages/very_good_analysis) | Linter rules | Syntax + style enforcement |
| **flutter-auto-test-skill** *(skill này)* | **Semantic compliance** | **Design / architecture / spec audit** |

---

## 📄 License

MIT — dùng tự do, adapt cho stack của anh.

---

## 🙏 Credits

Built by [@sonhai88](https://github.com/sonhai88) như một phần của Claude Code skill ecosystem cá nhân ([haiclaudeskill](https://github.com/sonhai88/haiclaudeskill)).

Distilled từ production pattern observe trên:
- 4+ Flutter projects (lme_ui, lsite-mobile, itg-mobile, sailo)
- 100+ commits của QA cycle pain
- 13 việc tester làm hàng ngày, bóc tách thành automatable vs human-only

---

<div align="center">

**[🐛 Report issue](https://github.com/sonhai88/flutter-auto-test-skill/issues)** ·
**[📖 Đọc SKILL.md](./SKILL.md)** ·
**[📋 Xem CHANGELOG](./CHANGELOG.md)** ·
**[📊 Xem audit thật](./reports/)**

Made with ❤️ cho các team Flutter chán cycle QA tay.

</div>
