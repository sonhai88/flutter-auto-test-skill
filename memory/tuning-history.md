# Tuning History

Decisions log — mỗi lần đổi rule, suppress FP, promote pattern → 1 entry.
Mục đích: lookback tại sao em quyết định gì + revert được nếu sai.

---

## Format

```
## YYYY-MM-DD — [TYPE] Title

**Type**: FP_SUPPRESSION | RULE_ADDED | PATTERN_PROMOTED | PATTERN_DEPRECATED | SEVERITY_CHANGED | EXCEPTION_ADDED

**Trigger**: Anh's feedback / git mining / scheduled review

**Change**:
  Before: ...
  After: ...

**Reason**: 1-2 dòng tại sao

**Impact**: scope của thay đổi (1 rule / 1 project / cross-project)

**Reversible**: Yes/No, cách revert
```

---

## 2026-05-27 — [INIT] Skill repo created

**Type**: INIT
**Trigger**: Anh request build skill thay tester
**Change**: Tạo skeleton v1.0.0 với 3 core check (Tokens + Architecture + Icons)
**Reason**: MVP để validate flow + memory loop
**Impact**: All projects (sẽ active khi project có config)
**Reversible**: Yes — xóa repo

---

## 2026-05-27 — [CONFIG] itg-mobile config — disable architecture/icons cho legacy stack

**Type**: CONFIG / EXCEPTION_ADDED
**Trigger**: Scan itg-mobile structure → phát hiện stack legacy
**Change**:
  - `architecture.no-setstate-feature`: enabled=false (project dùng Provider + setState legit)
  - `architecture.dio-no-direct-instantiate`: enabled=false (no Dio)
  - `architecture.gorouter-no-navigator-push`: enabled=false (no GoRouter)
  - `architecture.notifier-missing-autodispose`: enabled=false (Provider khác Riverpod)
  - `icons-compliance.no-material-icons`: enabled=false (no DS thay thế)
  - `tokens-compliance.no-hardcode-color`: severity error → warn (chưa có DS)
  - `tokens-compliance.spacing-arbitrary`: severity warn → info
**Reason**: itg-mobile = instagram_app, legacy stack Provider+http+Navigator+no-DS. Rule mặc định Riverpod/Dio/GoRouter/lme_ui KHÔNG apply. Nếu enforce → 100% noise → anh tắt skill.
**Impact**: project itg-mobile only
**Reversible**: Yes — re-enable từng rule khi project migrate stack

---

## 2026-05-27 — [PILOT_AUDIT] LoginPage first audit — baseline 38/100

**Type**: AUDIT
**Trigger**: Anh request "chạy hết quy trình"
**Change**: First audit LoginPage.dart 309 lines
**Result**:
  - 0 errors
  - 19 warns (15 hardcode color + 4 Material color names)
  - 10 infos (4 spacing + 3 radius + 1 fontsize + 2 misc)
  - 1 suppressed (Colors.transparent built-in exempt)
  - Score: 38/100 (baseline)
**Findings ngoài rule**:
  - 3 print() debug còn sót → propose new pattern `code-quality.no-print-in-production`
  - Responsive magic numbers `MediaQuery.size.* *.x/2` lan rộng
  - Nested setState trong .then() chain → khó debug
**Memory updated**:
  - `memory/per-project/itg-mobile/screens/LoginPage.yaml` created
  - `memory/per-project/itg-mobile/screens/_index.yaml` updated (1 screen)
  - `memory/per-project/itg-mobile/overview.md` patterns appended
**Reversible**: Yes — xóa report + revert memory entries

---
