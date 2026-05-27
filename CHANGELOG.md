# Changelog

## [1.0.1] - 2026-05-27

### Added (memory data)
- 4 screen audits (itg-mobile): LoginPage, SplashPage, HomePage, RegisterPage
- FP database first entry: `fp-001` (SystemUiOverlayStyle exempt)
- Screen quirk first entry: HomePage BottomNav L558-668 exempt
- Pattern PROMOTED PROPOSED → TESTING: `pattern-2026-05-27-001` (print debug)
- 2 new patterns still PROPOSED: responsive magic numbers, nested setState chain

### Stats
- 4/4 screens audited contain print() pattern (100% hit rate, 41 instances)
- Avg score itg-mobile: 37.75/100 (baseline, no design system)
- Project itg-mobile config tuned cho legacy stack (Provider + http + Navigator)

## [1.0.0] - 2026-05-27

### Added
- Skeleton repo structure
- SKILL.md với 7-step audit workflow
- 3 core checks: tokens-compliance, architecture, icons-compliance
- Multi-project config layered (core → project → screen)
- 4-gate anti-FP filtering pipeline
- FP database schema (memory/false-positives.yaml)
- Pattern lifecycle (PROPOSED → TESTING → ACTIVE → DEPRECATED)
- Feedback parser prompt
- Install script + Obsidian sync script
- Project template (`projects/_template.yaml`)

### Planned (1.1.0)
- Figma fidelity check (cần test Figma MCP)
- i18n check
- States coverage check
- Git history mining cron
- GitHub Action CI integration

### Planned (1.2.0)
- Spec compliance check (cần spec format chuẩn)
- API contract check (cần OpenAPI spec)
