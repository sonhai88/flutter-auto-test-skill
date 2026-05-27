# ITG Mobile — Project Overview

**Project slug**: itg-mobile
**Path**: TODO (anh fill khi onboard)
**Design system**: lme_ui
**Audited screens**: 1 (LoginPage)
**Stack**: Provider 6.x + http 1.x + Navigator (legacy, no DS)
**Path**: /Volumes/hai/itg-mobile

## Onboarding Checklist

- [x] Fill `projects/itg-mobile.yaml` — root_path, stack legacy confirmed
- [x] Scan project structure — lib/page/ thay vì lib/features/ (cấu trúc cũ)
- [x] Confirm stack: Provider + http + Navigator (no Riverpod/Dio/GoRouter)
- [ ] Lấy Figma file key (nếu có — chưa có)
- [x] Audit 1 screen pilot — LoginPage done 2026-05-27, score 38/100
- [ ] Review FP với anh → update fp database (audit đầu tiên không phát sinh FP)
- [x] Quyết định checks enable — chỉ tokens-compliance (architecture/icons disabled vì legacy)

## Known Patterns

### Patterns confirmed (2026-05-27 audit)
- Hardcode colors lan rộng (15 entries trong LoginPage) → cần extract `AppColors` constants
- Pattern responsive bằng `MediaQuery.of(context).size.* * .x / 2` — magic numbers
- `print()` debug còn sót production code (3 entries LoginPage)
- Nested `setState` trong `.then()/.catchError()` chain — khó debug

### Proposed new patterns (chờ anh approve thành rule)
- `code-quality.no-print-in-production` — grep `print(` trong lib/ (trừ test/)
- `code-quality.responsive-magic-numbers` — pattern `MediaQuery.of(context).size.* * .x / 2`
- `style.async-callback-chain-vs-await` — nested .then().catchError() nên dùng async/await

## Cross-references

- Skill flutter-architecture: 7 rule cứng anh đã có rule
- Skill lme-flutter: build UI bằng lme_ui (icons mapping)
- Skill mobile-design: design formula cho mobile

## Notes

- Tester thật cần check phần exploratory + visual taste (skill không thay được)
- Pattern itg riêng: TBD sau khi audit lần đầu
