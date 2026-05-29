# Changelog

## [1.2.0] - 2026-05-28

### Added — Runtime Audit Layer 🚀

New `runtime/` folder with full simulator/emulator control:

**Scripts** (`runtime/scripts/`):
- `device-list.sh` — list booted iOS + Android devices
- `screenshot.sh` — capture state with auto-labeled artifacts
- `launch-app.sh` — cold/warm launch
- `hierarchy.sh` — UI tree dump via Maestro
- `tap.sh`, `type-text.sh` — interaction via Maestro
- `deep-link.sh` — URL scheme test
- `push-notification.sh` — fake APNs payload
- `stream-logs.sh` — capture Flutter exceptions (macOS timeout fix)
- `status-bar.sh` — Apple marketing / low-battery / bad-signal / clear
- `record-video.sh` — screen recording
- `run-flow.sh` — execute Maestro YAML with screenshots

**Maestro flows** (`runtime/maestro-flows/`):
- `_template.yaml`
- `states-coverage-check.yaml`
- `visual-regression-baseline.yaml`
- `deep-link-validation.yaml`

**Runtime checks** (`runtime/checks/`):
- `09-visual-figma-drift.md` — screenshot vs Figma diff
- `10-runtime-exceptions.md` — log parse + source map
- `11-states-coverage-runtime.md` — verify loading/error/empty actually render
- `12-deep-link-validation.md` — URL routing crash test

**Prompts** (`runtime/prompts/`):
- `visual-compare.md` — LLM diff screenshot vs Figma
- `log-analyzer.md` — categorize + source-map exceptions
- `maestro-flow-generator.md` — generate YAML from goal

### Real-world findings (demo on itg-mobile)
- 🔴 **Missing CFBundleURLTypes in Info.plist** — runtime-only finding, static checks would NEVER catch
- 🟡 Mix language UI labels detected (VN field in JP UI)
- 🟢 No low-battery UI adaptation

### Dependencies
- Maestro 2.6.0 (install via curl script)
- xcrun simctl (built-in with Xcode)
- adb (Android SDK, optional)

### SKILL.md updates
- Mode flags: `--runtime`, `--full`
- New trigger phrases: "test trên simulator", "screenshot app", "deep link test"
- 8-step runtime workflow added

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
