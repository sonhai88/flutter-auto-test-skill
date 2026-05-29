<div align="center">

# 🔍 flutter-auto-test-skill

### AI auditor cho Flutter — thay thế 70% workload tester

**Verify Figma fidelity · Design system compliance · Architecture rules** — tất cả qua một Claude Code skill học từ feedback của anh và sắc bén hơn sau mỗi audit.

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-D97757?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/skills)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](#license)
[![Self-improving](https://img.shields.io/badge/self--improving-yes-success)](#-self-improvement-loop)

🌐 **[Tiếng Việt](./README.md)** · [English](./README.en.md)

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

## 📋 Tester làm gì thật sự — 26 việc bóc tách

Trước khi build skill, em bóc tách workload tester mobile thành **26 đầu việc cụ thể**. Mỗi việc đánh giá mức AI thay được + công cụ cần.

> **Số liệu thật**: AI thay được **~70% workload tổng**, KHÔNG phải 100%. 30% còn lại = exploratory + sign-off + compliance + real device quirks → vẫn cần người.

### 🧠 Knowledge & Documentation (việc 1-4)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 1 | Đọc spec / requirement, hiểu feature | ✅ 100% | LLM |
| 2 | Viết test case từ spec (Excel/TestRail) | ✅ 90% | LLM |
| 3 | Verify UI khớp Figma | ✅ 95% | LLM + Figma MCP |
| 4 | Check spec compliance (feature có làm đủ không) | ✅ 80% | LLM + spec markdown |

### 🏗️ Code Quality & Architecture (việc 5)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 5 | Architecture / code quality review | ✅ 90% | LLM + grep + codegraph |

### 🤖 Functional Testing (việc 6-7)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 6 | Chạy test case trên app build | ⚠️ 70% | Patrol / Maestro |
| 7 | Regression test trước release | ⚠️ 60% | E2E suite + golden |

### 📱 Platform & Device (việc 8)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 8 | Cross-device test (iPhone SE, tablet, Android cũ) | ⚠️ 80% | Firebase Test Lab / BrowserStack |

### 🎨 Visual Regression (việc 9)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 9 | Visual regression (1 button lệch 2px) | ✅ 95% | Golden + Percy / Applitools |

### 🔬 Edge Cases & Exploratory (việc 10-11)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 10 | Edge case: mất mạng, logout giữa flow, low memory | ⚠️ 50% | Chaos testing setup |
| 11 | Exploratory test — "thử cái lạ xem app vỡ không" | ❌ 20% | Human creativity |

### 📝 Reporting (việc 12)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 12 | Bug report (Jira/Trello) với reproduce steps | ✅ 95% | LLM + screenshot |

### ✋ Human-Only Responsibility (việc 13)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 13 | Sign-off release (chịu trách nhiệm) | ❌ 0% | Pháp lý / tổ chức |

---

### 🆕 Mở rộng — 13 việc bổ sung mà tester thật phải làm

Bảng cơ bản trên cover workflow chung. Nhưng release-ready mobile app còn cần 13 trục nữa — đa số bị bỏ sót trong audit truyền thống:

### ⚡ Performance (việc 14)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 14 | Performance test (60fps scroll, startup time, memory) | ⚠️ 70% | Flutter DevTools + Firebase Performance + timeline export |

### ♿ Accessibility (việc 15)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 15 | A11y audit (screen reader, contrast 4.5:1, touch target 48dp) | ✅ 80% | Skill [`accessibility-audit`](https://github.com/sonhai88/haiclaudeskill) |

### 🔐 Security (việc 16)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 16 | Security audit (secure storage, cert pinning, PII leak) | ⚠️ 60% | Skill [`vibe-scan`](https://github.com/sonhai88/haiclaudeskill) + static analysis |

### 🌍 Localization (việc 17)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 17 | Localization (RTL, text overflow ngôn ngữ khác, date format per locale) | ⚠️ 70% | LLM + i18n check + multi-locale screenshot |

### 🧭 Navigation & Deep Links (việc 18)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 18 | Deep link + navigation flow testing | ⚠️ 60% | Patrol E2E + Universal Links / App Links config |

### 🔔 Push Notifications (việc 19)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 19 | Push notification testing (foreground/background/killed state) | ❌ 30% | **Cần device thật** + Firebase Cloud Messaging |

### 📡 Network Resilience (việc 20)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 20 | Offline mode + network resilience (mất sóng giữa request) | ⚠️ 50% | Chaos testing + Dio interceptor mock |

### 🔄 Migration & Upgrade (việc 21)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 21 | App update / version migration (v1.0 → v2.0 data migration) | ❌ 30% | **Cần build prev version thật** + manual install upgrade |

### 💳 Payment / IAP (việc 22)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 22 | Payment / In-App Purchase flow (Stripe, Apple Pay, Google Pay) | ❌ 10% | **Sandbox account thủ công** + StoreKit testing |

### ⚖️ Compliance Regulatory (việc 23)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 23 | Compliance (GDPR consent, ATT iOS 14.5+, COPPA child safety) | ❌ 5% | **Luật sư** + risk assessment + DPA review |

### 📊 Analytics Tracking (việc 24)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 24 | Analytics event tracking verification (Mixpanel/Firebase Analytics) | ⚠️ 60% | Event schema check + debug view |

### 💥 Crash & ANR Monitoring (việc 25)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 25 | Crash / ANR monitoring & symbolication | ⚠️ 50% | Crashlytics integration + dSYM upload |

### 👋 Onboarding Flow (việc 26)

| # | Việc | AI thay được? | Cần gì |
|---|---|---|---|
| 26 | Onboarding flow regression (first-time user journey) | ✅ 70% | Patrol E2E + reset app state |

---

### 📊 Tổng kết — Roadmap thay tester

| Phân loại | Số việc | Avg AI thay được | Action plan |
|---|---|---|---|
| 🟢 **Skill này (v1.0) đã cover** | 5/26 | ~91% | Compliance check, code review, Figma fidelity |
| 🟡 **Skill v1.1+ sẽ cover** | 7/26 | ~70% | i18n, states coverage, performance, a11y, security |
| 🔵 **Cần tool ngoài** (Patrol, Firebase, Percy) | 8/26 | ~65% | E2E, visual regression, device matrix |
| 🔴 **Cần human KHÔNG thay được** | 6/26 | ~10% | Sign-off, compliance, exploratory, IAP, push noti, migration |

→ **Skill flutter-auto-test = bedrock layer**. Cặp với 2-3 tool ngoài → automate được ~70% workload. 30% còn lại vẫn cần tester thật (nhưng tập trung vào exploratory + sign-off, không phải chạy test case tay).

---

## 🆕 v1.2.0 — Runtime Audit Layer

Skill giờ **thao tác được trên iOS Simulator / Android Emulator** anh đang mở. Không chỉ đọc code — em **launch app, screenshot, tap, đọc log, test deep link, push notification, low-battery edge case**.

### Capabilities

| | Tool | Install? |
|---|---|---|
| 📸 Screenshot | `xcrun simctl` / `adb` | ❌ Built-in |
| 🚀 Launch / kill app | `xcrun simctl` | ❌ |
| 🌳 UI hierarchy | Maestro | ✅ 1 command |
| 👆 Tap / Swipe / Type | Maestro | ✅ |
| 🔗 Deep link test | `xcrun simctl openurl` | ❌ |
| 🔔 Push notification fake | `xcrun simctl push` | ❌ |
| 📋 Stream Flutter logs | `log stream` | ❌ |
| 🪫 Status bar override (low battery, bad signal) | `xcrun simctl status_bar` | ❌ |
| 🎥 Record video | `xcrun simctl io recordVideo` | ❌ |
| 🎭 Visual diff vs Figma | Claude vision + Figma MCP | ❌ |

### Setup

```bash
# 1. Install Maestro (1 lần)
curl -Ls "https://get.maestro.mobile.dev" | bash

# 2. Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# 3. Trigger runtime audit
/flutter-auto-test --runtime LoginPage
```

### Quick demo

```bash
cd ~/.claude/skills/flutter-auto-test/runtime/scripts

./device-list.sh                           # confirm sim booted
./status-bar.sh apple                      # clean 9:41 baseline
./launch-app.sh com.your.app --cold
./screenshot.sh --label initial            # capture state
./stream-logs.sh --seconds 30 --bundle com.your.app &
./deep-link.sh "yourapp://feature/123"     # test routing
./push-notification.sh com.your.app '{"aps":{"alert":"Test"}}'
./status-bar.sh low-battery                # edge case
./screenshot.sh --label low-battery
./status-bar.sh clear
```

### Real bug em đã catch trong demo trên itg-mobile

🔴 **Missing `CFBundleURLTypes` in Info.plist** → app KHÔNG handle deep link URL scheme. Static check không bao giờ catch được vì:
- Code Flutter có thể có deep link handler hoàn chỉnh
- Nhưng iOS native config thiếu → OS error khi user click link
- Marketing campaign / push noti routing silent fail

→ Đây là **value proposition** của runtime layer.

Xem [demo report đầy đủ](./reports/2026-05-28/itg-mobile/_runtime-demo.md).

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

### v1.0 ─ Foundation *(done)*
- [x] 3 core checks: tokens / architecture / icons
- [x] 4-gate anti-FP filtering
- [x] Multi-project config layering
- [x] FP database + per-screen quirks
- [x] Pattern lifecycle (PROPOSED → TESTING)
- [x] Manual feedback loop

### v1.2 ─ Runtime Layer *(hiện tại)* 🆕
- [x] iOS Simulator control (xcrun simctl)
- [x] Maestro integration (tap/swipe/UI hierarchy)
- [x] Screenshot + vision analysis
- [x] Deep link validation
- [x] Push notification fake
- [x] Status bar edge cases (low battery, bad signal)
- [x] Log streaming + exception parse
- [x] Visual Figma drift check
- [x] Real-world bug caught: Missing URL scheme in itg-mobile

### v1.3 ─ Figma + Coverage
- [ ] Figma fidelity check qua MCP (full automation)
- [ ] i18n check
- [ ] States coverage (loading/error/empty/success) — static + runtime
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
- 4+ Flutter projects (lme_ui, lsite-mobile, itg-mobile)
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
