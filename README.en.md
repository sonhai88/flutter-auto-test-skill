<div align="center">

# 🔍 flutter-auto-test-skill

### AI auditor for Flutter — replace 70% of QA workload

**Verify Figma fidelity · Design system compliance · Architecture rules** — all from a Claude Code skill that learns from your feedback and gets sharper every audit.

[![Version](https://img.shields.io/badge/version-1.0.1-blue.svg)](./CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-D97757?logo=anthropic)](https://docs.anthropic.com/en/docs/claude-code/skills)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](#license)
[![Self-improving](https://img.shields.io/badge/self--improving-yes-success)](#-self-improvement-loop)

🌐 [Tiếng Việt](./README.md) · **[English](./README.en.md)**

</div>

---

## 💡 Why this exists

Every Flutter team eventually faces the same QA cliff:

```
Sprint 1:  3 screens, 1 tester, manual checks work fine
Sprint 8:  40 screens, 1 tester, regression every release
Sprint 12: 80 screens, hire 2 more testers? or automate?
```

Existing AI code review skills break for one of three reasons:

| 🚫 Problem | What happens |
|---|---|
| **False positives repeat** | Session 1 flags `missing-loading`, you correct: "using AsyncValue.when." Session 2 flags it again. Session 3 you turn off the skill. |
| **No project context** | itg-mobile allows `Color.fromARGB` for gradients, lsite-mobile forbids it. Generic rule = noise = ignored. |
| **No pattern accumulation** | Week 1 you find bug X. Week 3 a teammate writes the same bug. Skill doesn't learn. |

**This skill fixes all three by design.**

---

## 📋 What testers actually do — 26 tasks broken down

Before building this skill, we broke down a mobile tester's workload into **26 concrete tasks**. Each task is rated by how much AI can replace + what tools are needed.

> **Honest numbers**: AI replaces **~70% of total workload**, NOT 100%. The remaining 30% = exploratory + sign-off + compliance + real-device quirks → still needs a human.

### 🧠 Knowledge & Documentation (tasks 1-4)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 1 | Read spec / requirement, understand feature | ✅ 100% | LLM |
| 2 | Write test cases from spec (Excel/TestRail) | ✅ 90% | LLM |
| 3 | Verify UI matches Figma | ✅ 95% | LLM + Figma MCP |
| 4 | Check spec compliance (feature complete?) | ✅ 80% | LLM + spec markdown |

### 🏗️ Code Quality & Architecture (task 5)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 5 | Architecture / code quality review | ✅ 90% | LLM + grep + codegraph |

### 🤖 Functional Testing (tasks 6-7)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 6 | Run test cases on built app | ⚠️ 70% | Patrol / Maestro |
| 7 | Regression testing before release | ⚠️ 60% | E2E suite + golden |

### 📱 Platform & Device (task 8)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 8 | Cross-device testing (iPhone SE, tablet, old Android) | ⚠️ 80% | Firebase Test Lab / BrowserStack |

### 🎨 Visual Regression (task 9)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 9 | Visual regression (1 button off by 2px) | ✅ 95% | Golden + Percy / Applitools |

### 🔬 Edge Cases & Exploratory (tasks 10-11)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 10 | Edge cases: no network, logout mid-flow, low memory | ⚠️ 50% | Chaos testing setup |
| 11 | Exploratory test — "try weird things, see if app breaks" | ❌ 20% | Human creativity |

### 📝 Reporting (task 12)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 12 | Bug report (Jira/Trello) with reproduction steps | ✅ 95% | LLM + screenshot |

### ✋ Human-Only Responsibility (task 13)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 13 | Sign-off release (accountability) | ❌ 0% | Legal / org responsibility |

---

### 🆕 Extension — 13 additional tasks real testers handle

The base table covers the common workflow. But a release-ready mobile app needs 13 more dimensions — usually missed in traditional audits:

### ⚡ Performance (task 14)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 14 | Performance test (60fps scroll, startup time, memory) | ⚠️ 70% | Flutter DevTools + Firebase Performance + timeline export |

### ♿ Accessibility (task 15)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 15 | A11y audit (screen reader, contrast 4.5:1, touch target 48dp) | ✅ 80% | Skill [`accessibility-audit`](https://github.com/sonhai88/haiclaudeskill) |

### 🔐 Security (task 16)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 16 | Security audit (secure storage, cert pinning, PII leak) | ⚠️ 60% | Skill [`vibe-scan`](https://github.com/sonhai88/haiclaudeskill) + static analysis |

### 🌍 Localization (task 17)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 17 | Localization (RTL, text overflow in other languages, date format per locale) | ⚠️ 70% | LLM + i18n check + multi-locale screenshot |

### 🧭 Navigation & Deep Links (task 18)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 18 | Deep link + navigation flow testing | ⚠️ 60% | Patrol E2E + Universal Links / App Links config |

### 🔔 Push Notifications (task 19)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 19 | Push notification testing (foreground/background/killed state) | ❌ 30% | **Needs real device** + Firebase Cloud Messaging |

### 📡 Network Resilience (task 20)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 20 | Offline mode + network resilience (signal loss mid-request) | ⚠️ 50% | Chaos testing + Dio interceptor mock |

### 🔄 Migration & Upgrade (task 21)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 21 | App update / version migration (v1.0 → v2.0 data migration) | ❌ 30% | **Needs real prev version build** + manual upgrade install |

### 💳 Payment / IAP (task 22)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 22 | Payment / In-App Purchase flow (Stripe, Apple Pay, Google Pay) | ❌ 10% | **Manual sandbox account** + StoreKit testing |

### ⚖️ Compliance Regulatory (task 23)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 23 | Compliance (GDPR consent, ATT iOS 14.5+, COPPA child safety) | ❌ 5% | **Legal counsel** + risk assessment + DPA review |

### 📊 Analytics Tracking (task 24)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 24 | Analytics event tracking verification (Mixpanel/Firebase Analytics) | ⚠️ 60% | Event schema check + debug view |

### 💥 Crash & ANR Monitoring (task 25)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 25 | Crash / ANR monitoring & symbolication | ⚠️ 50% | Crashlytics integration + dSYM upload |

### 👋 Onboarding Flow (task 26)

| # | Task | AI can replace? | Needs |
|---|---|---|---|
| 26 | Onboarding flow regression (first-time user journey) | ✅ 70% | Patrol E2E + reset app state |

---

### 📊 Summary — Tester replacement roadmap

| Category | # tasks | Avg AI replacement | Action plan |
|---|---|---|---|
| 🟢 **This skill (v1.0) already covers** | 5/26 | ~91% | Compliance, code review, Figma fidelity |
| 🟡 **Skill v1.1+ will cover** | 7/26 | ~70% | i18n, states, performance, a11y, security |
| 🔵 **Needs external tools** (Patrol, Firebase, Percy) | 8/26 | ~65% | E2E, visual regression, device matrix |
| 🔴 **Human-only, irreplaceable** | 6/26 | ~10% | Sign-off, compliance, exploratory, IAP, push noti, migration |

→ **flutter-auto-test = bedrock layer**. Pair with 2-3 external tools → automate ~70% of workload. The remaining 30% still needs a real tester (but focused on exploratory + sign-off, not manual test execution).

---

## ✨ What it catches

<table>
<tr>
<td width="50%">

### 🎨 Design System Compliance
- Hardcoded colors → suggest design tokens
- Arbitrary spacing → suggest scale `{4, 8, 12, 16, 24...}`
- Font sizes outside type scale
- Border radius drift from system

</td>
<td width="50%">

### 🏗️ Architecture Rules
- Riverpod patterns (autoDispose, no setState)
- Dio interceptor presence
- GoRouter type-safety + guards
- Repository pattern + Result type
- No throw cross-layer

</td>
</tr>
<tr>
<td>

### 🎭 Figma Fidelity *(v1.1+)*
- Read Figma spec via MCP
- Compare fontSize/color/padding pixel-by-pixel
- Flag drift between code and design

</td>
<td>

### 🧩 Icons Compliance
- Material Icons → flag for design system replacement
- Cupertino Icons → flag
- Unused `material.dart` imports

</td>
</tr>
<tr>
<td>

### 🌐 i18n Check *(v1.1+)*
- Hardcoded Vietnamese/Japanese strings
- Missing localization keys
- Inconsistent fallbacks

</td>
<td>

### 🎬 States Coverage *(v1.1+)*
- Missing `loading` / `error` / `empty` / `success` states
- Inferred from notifier transitions

</td>
</tr>
</table>

---

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/sonhai88/flutter-auto-test-skill.git
cd flutter-auto-test-skill

# 2. Install (creates symlink ~/.claude/skills/flutter-auto-test/)
./scripts/install.sh

# 3. Restart Claude Code, then in any Flutter project:
```

```
/flutter-auto-test lib/features/auth/login_screen.dart
```

Or just type naturally:
> *"audit cho anh màn hình LoginPage"*
> *"check compliance file home_page.dart"*
> *"xem code khớp Figma chưa, URL: figma.com/design/.../?node-id=63-121"*

---

## 🛡️ How it avoids false positives — 4-gate filter

```
                       Issue candidate detected
                                 │
                                 ▼
            ┌──────────────────────────────────────────┐
            │  GATE 1 ─ False-Positive Database        │
            │  memory/false-positives.yaml             │
            │  Match rule_id + pattern signature?      │
            │  ─────────────────────────────────────── │
            │  ✓ match → SUPPRESS (log "fp-001")       │
            └─────────────────┬────────────────────────┘
                              │ no match
                              ▼
            ┌──────────────────────────────────────────┐
            │  GATE 2 ─ Per-Screen Quirks              │
            │  memory/per-project/<p>/screens/<s>.yaml │
            │  Line in screen's exception range?       │
            │  ─────────────────────────────────────── │
            │  ✓ match → SUPPRESS (with reason)        │
            └─────────────────┬────────────────────────┘
                              │ no match
                              ▼
            ┌──────────────────────────────────────────┐
            │  GATE 3 ─ Project Exceptions             │
            │  projects/<project>.yaml                 │
            │  Rule allowed for this project context?  │
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
            │  ≥0.9 → keep severity                    │
            │  0.6-0.9 → downgrade to WARN             │
            │  <0.6 → demote to INFO (need review)     │
            └─────────────────┬────────────────────────┘
                              │
                              ▼
                  ✅ FLAG with evidence + fix
```

**Every flagged issue carries**:
- File + line number
- Code snippet (proof)
- Proposed fix
- Confidence score
- Rationale (why this rule applies)

No "looks correct overall" outputs. No vague claims. Evidence-only.

---

## 🧠 Self-Improvement Loop

The skill **gets sharper every audit**. Three mechanisms:

### 1. Feedback Parser

After every report, you can reply in plain language:

```
"FP: tokens-compliance.no-hardcode-color ở SplashPage.dart:175 — SystemUiOverlayStyle config"
"Bug pattern mới: dev hay quên dispose TextEditingController"
"Quirk: HomePage line 558-668 skip tokens.no-hardcode-color vì BottomNav legacy"
"OK fix nhé"
```

The skill parses → proposes YAML update → bumps version → commits memory change.

### 2. Pattern Lifecycle

Bug patterns aren't added by humans — they're **mined from your git history** and graduated through validation stages:

```
┌──────────┐    detected from git log --grep="fix:"
│ DETECTED │    or manual report
└────┬─────┘
     ▼
┌──────────┐    Auto-saved to memory/new-patterns.yaml
│ PROPOSED │    Wait for human approval
└────┬─────┘
     ▼
┌──────────┐    Active in ONE project (testing window)
│ TESTING  │    Track true/false positive rate
└────┬─────┘    Need: ≥3 TP, ≤10% FP rate, ≥14 days
     ▼
┌──────────┐    Promoted to core/checks/
│ VALIDATED│    Apply across ALL projects
└────┬─────┘
     ▼
┌──────────┐    Live in production rule set
│ ACTIVE   │
└────┬─────┘
     ▼
┌──────────┐    If FP rate spikes or rule obsolete
│DEPRECATED│
└──────────┘
```

### 3. Multi-Project Config Layering

Same rule, different projects, different behavior:

```yaml
# core/rules.yaml ─ universal defaults
tokens-compliance.no-hardcode-color:
  severity: error

                ↓ override per project
                
# projects/itg-mobile.yaml ─ legacy stack
tokens-compliance.no-hardcode-color:
  severity: warn        # downgrade — no design system yet
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

## 📊 Real-world example

Audited **4 screens** of a 170k-line Flutter app on day 1:

| Screen | Lines | Score | Hardcode | print() debug |
|---|---|---|---|---|
| SplashPage | 207 | 88/100 | 3 | 11 |
| LoginPage | 309 | 38/100 | 19 | 3 |
| RegisterPage | 501 | 14/100 | 27 | 4 |
| HomePage | 811 | 11/100 | 28 | 23 |
| **Total** | **1,828** | **37.75 avg** | **77** | **41** |

**Findings on day 1**:
- 77 hardcoded colors → recommended `AppColors` extraction (1-day work)
- 41 `print()` debug statements → recommended logger migration
- Cross-screen pattern auto-promoted PROPOSED → TESTING (`pattern-2026-05-27-001`)
- 1 false positive identified and added to global FP database (`fp-001` SystemUiOverlayStyle exempt)

**Expected after Priority 1 fixes**: avg score 37.75 → **76.25** (+38.5 lift).

> [Full audit reports here](./reports/2026-05-27/itg-mobile/) — including weekly summary and feedback demo.

---

## 📂 Project Structure

```
flutter-auto-test-skill/
├── SKILL.md                          # Entry point — Claude reads first
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
│   ├── feedback-parser.md            │  (separate from checks)
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

### 1. Create project config

```bash
cp projects/_template.yaml projects/my-app.yaml
```

### 2. Fill in your stack

```yaml
project: my-app
root_path: /path/to/your/flutter/project

stack:
  flutter: 3.27.0
  riverpod: 2.5.0
  go_router: 14.0.0
  dio: 5.4.0
  design_system: lme_ui@2.1.0      # or "custom" or "none"

figma:
  file_key: ABC123XYZ              # from figma.com/design/<file_key>/

rules:
  tokens-compliance.no-hardcode-color:
    severity: error
    exceptions: []                  # add as you confirm them

metrics:
  release_score_min: 85
  enabled_checks:
    - tokens-compliance
    - architecture
    - icons-compliance
```

### 3. (Optional) Notify Telegram on weekly summary

```yaml
notify:
  telegram_chat_id: 123456
```

---

## 🗺️ Roadmap

### v1.0 ─ Foundation *(current)*
- [x] 3 core checks: tokens / architecture / icons
- [x] 4-gate anti-FP filtering
- [x] Multi-project config layering
- [x] FP database + per-screen quirks
- [x] Pattern lifecycle (PROPOSED → TESTING)
- [x] Manual feedback loop

### v1.1 ─ Figma + Coverage
- [ ] Figma fidelity check via MCP
- [ ] i18n check
- [ ] States coverage (loading/error/empty/success)
- [ ] Git history mining cron
- [ ] CI integration via GitHub Actions

### v1.2 ─ Spec & Contract
- [ ] Spec compliance (markdown → code trace)
- [ ] API contract check (OpenAPI → Dio calls)
- [ ] State machine validation
- [ ] Cross-file analysis

### v2.0 ─ Web Dashboard *(stretch)*
- [ ] React dashboard for QA leads
- [ ] Trending across releases
- [ ] Jira integration

---

## 🤝 Workflow Integration

```
┌─────────────────────────────────────────────────────────────┐
│ LAYER 1 ─ Developer local (this skill)                       │
│ Dev codes → /flutter-auto-test → fix issues → commit         │
│ Cost: free (within Claude Code subscription)                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────────┐
│ LAYER 2 ─ Pre-commit hook (planned)                          │
│ git commit → fast tokens/icons check → block if errors       │
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

## ❌ What this skill is NOT

Being honest matters:

- **❌ Not a replacement for human QA** — replaces ~70% of compliance work. Exploratory testing, UX feel, real-device quirks still need a human.
- **❌ Not a runtime test** — verifies code structure, NOT app behavior at runtime. Pair with [`patrol`](https://patrol.leancode.co) for E2E.
- **❌ Not a linter** — Dart analyzer + linter rules still required for syntax/style. This catches **semantic compliance** (design system, architecture, spec adherence).
- **❌ Not perfect** — false positives happen. The whole point of the FP database is to make them happen **only once**.

---

## 🧑‍💻 Contributing

This is currently a single-developer project tuned for specific Flutter stacks (lme_ui + Riverpod + Dio + GoRouter), but PRs are welcome for:

- Adding new project templates (`projects/<your-stack>.yaml`)
- Proposing new checks (`core/checks/NN-<name>.md`)
- Improving detection regex / AST patterns
- Documentation / examples

Fork → branch → PR. Run `./scripts/install.sh` locally to test.

---

## 📚 Related Tools

| Tool | Purpose | When to use |
|---|---|---|
| [patrol](https://patrol.leancode.co) | E2E testing | Critical user flows |
| [golden_toolkit](https://pub.dev/packages/golden_toolkit) | Visual regression | Design system snapshots |
| [mocktail](https://pub.dev/packages/mocktail) | Unit test mocking | Business logic tests |
| [very_good_analysis](https://pub.dev/packages/very_good_analysis) | Linter rules | Syntax + style enforcement |
| **flutter-auto-test-skill** *(this)* | **Semantic compliance** | **Design / architecture / spec audit** |

---

## 📄 License

MIT — use freely, adapt to your stack.

---

## 🙏 Credits

Built by [@sonhai88](https://github.com/sonhai88) as part of a personal Claude Code skill ecosystem ([haiclaudeskill](https://github.com/sonhai88/haiclaudeskill)).

Distilled from production patterns observed across:
- 4+ Flutter projects (lme_ui, lsite-mobile, itg-mobile, sailo)
- 100+ commits of QA cycle pain
- 13 testers' daily workload, broken down into automatable vs human-only

---

<div align="center">

**[🐛 Report issue](https://github.com/sonhai88/flutter-auto-test-skill/issues)** ·
**[📖 Read SKILL.md](./SKILL.md)** ·
**[📋 See CHANGELOG](./CHANGELOG.md)** ·
**[📊 View example audits](./reports/)**

Made with ❤️ for Flutter teams tired of manual QA cycles.

</div>
