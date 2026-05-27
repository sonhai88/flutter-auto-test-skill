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
