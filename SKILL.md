---
name: flutter-auto-test
description: AI auditor cho Flutter — STATIC (code compliance) + RUNTIME (thao tác app trên iOS Simulator/Android Emulator). Static catch hardcode color/architecture/icons; Runtime catch render drift vs Figma, exception lúc chạy, deep link crash, state coverage thật. Tự control sim qua xcrun + Maestro. Self-improving qua FP database + pattern lifecycle. Auto-trigger: /flutter-auto-test, "audit screen", "test app trên simulator", "kiểm tra UI runtime", "screenshot app", "xem code khớp Figma".
---

# Flutter Auto Test Skill

## Mục đích

Skill thay thế 70% workload tester thật cho Flutter project — **STATIC + RUNTIME**:

### STATIC (code-level, không cần app chạy)
- **Design system compliance**: hardcode color, spacing arbitrary, fontsize lệch scale
- **Architecture rules**: Riverpod + Dio + GoRouter pattern đúng
- **Icons compliance**: dùng LmeIcons, cấm Material Icons
- **i18n check**: text tiếng Việt có dấu, không hardcode
- **States coverage** (static): code có handle loading/error/empty không

### RUNTIME (cần iOS Simulator / Android Emulator booted)
- **Visual Figma drift**: screenshot vs Figma spec — vision-based diff
- **Runtime exceptions**: parse Flutter log → catch RenderFlex overflow, setState after dispose, PlatformException
- **States coverage (runtime)**: trigger thật loading/error/empty state, verify render đúng
- **Deep link validation**: test URL routing không crash với invalid params
- **Push notification handling**: fake APNs payload, test foreground/background/killed state
- **Edge case status bar**: low-battery, bad-signal scenarios

**Self-improving**: mỗi lần audit học từ feedback anh → false-positive database + pattern lifecycle.

## Khi nào trigger

### Static-only mode
- User gõ `/flutter-auto-test <path>`
- User nói "audit màn hình X", "check compliance file Z"
- Trước khi commit feature mobile

### Runtime mode (cần sim/device booted)
- User gõ `/flutter-auto-test --runtime <screen>`
- User nói "test app trên simulator", "screenshot app", "check app chạy thế nào"
- User nói "xem UI runtime khớp Figma chưa"
- User nói "test deep link / push notification"
- User nói "catch lỗi lúc app chạy"

### Combined mode (default khi có sim + có code)
- User gõ `/flutter-auto-test --full <screen>` → chạy cả static + runtime, aggregate report

## Runtime Workflow (NEW v1.2)

Khi user nói "test trên simulator" / "screenshot app" / "audit runtime":

### Bước R1: Detect device
```bash
./runtime/scripts/device-list.sh --json
```
Nếu không có sim/device → báo "anh boot simulator trước"

### Bước R2: Pre-flight
```bash
./runtime/scripts/status-bar.sh apple    # clean status bar
```

### Bước R3: Capture state hiện tại
```bash
SS=$(./runtime/scripts/screenshot.sh --label initial)
HIER=$(./runtime/scripts/hierarchy.sh --save)
```
Em Read screenshot → vision analyze UI.

### Bước R4: Compare với Figma (nếu có URL)
- Call `mcp__plugin_figma_figma__get_design_context`
- Em diff per element → output drift report

### Bước R5: Interact (test flow)
Generate Maestro YAML cho test case → run:
```bash
./runtime/scripts/run-flow.sh runtime/maestro-flows/<flow>.yaml
```
Mỗi step có `takeScreenshot` → em vision-analyze từng state.

### Bước R6: Test edge cases
- Deep link invalid: `./runtime/scripts/deep-link.sh "itg://invalid"`
- Push notification: `./runtime/scripts/push-notification.sh <bundle> <payload>`
- Low battery: `./runtime/scripts/status-bar.sh low-battery`

### Bước R7: Capture exceptions
```bash
./runtime/scripts/stream-logs.sh --seconds 30 --bundle <bundle>
```
Em parse log → map về source file:line.

### Bước R8: Report combined
Aggregate static + runtime findings → markdown report với screenshots inline.

---

## Quy trình audit (7 bước STATIC)

```
STEP 1: BOOTSTRAP
  • Detect project: walk up tới root, tìm .flutter-audit.yaml hoặc pubspec.yaml
  • Load projects/<project>.yaml (override defaults)
  • Load core/rules.yaml (universal rules)
  • Load memory/per-project/<project>/screens/<screen>.yaml (quirks per-screen)
  • Load memory/false-positives.yaml (FP database)

STEP 2: PRE-FLIGHT
  • Read file đích + widget con (related files)
  • Detect notifier/repository/service liên quan
  • Nếu có Figma URL → call mcp__plugin_figma_figma__get_design_context

STEP 3: CHECK EXECUTION (parallel khi có thể)
  Active checks (priority order):
    1. core/checks/02-tokens-compliance.md
    2. core/checks/03-architecture.md
    3. core/checks/04-icons-compliance.md
    4. core/checks/01-figma-fidelity.md (nếu có Figma URL)
    5. core/checks/05-i18n-check.md
    6. core/checks/06-states-coverage.md

STEP 4: ANTI-FP FILTERING (4 gates — BẮT BUỘC chạy hết)
  Mỗi issue candidate PHẢI qua 4 gates:
  
  Gate 1 — FP Database:
    Query memory/false-positives.yaml
    Match rule_id + pattern_signature → SUPPRESS, log "suppressed-by-fp-db"
  
  Gate 2 — Screen Quirks:
    Query memory/per-project/<p>/screens/<s>.yaml → quirks[]
    Match rule_id + line trong line_range → SUPPRESS
  
  Gate 3 — Project Exceptions:
    Query projects/<project>.yaml → rules[rule_id].exceptions
    Match → DOWNGRADE severity (ERROR → INFO)
  
  Gate 4 — Confidence Score:
    Compute confidence = ast_match_score * 0.7 + context_match_score * 0.3
    ≥0.9 → keep severity
    0.6-0.9 → WARN
    <0.6 → INFO (need human review)

STEP 5: GENERATE REPORT
  Format: reports/<YYYY-MM-DD>/<project>/<screen>.md
  Sections: MUST FIX / SHOULD FIX / PASSED / SUPPRESSED / TREND / WATCH LIST
  Compute score: 100 - (ERROR*10 + WARN*3 + INFO*1)

STEP 6: UPDATE MEMORY
  • Append audit entry to memory/per-project/<p>/screens/<s>.yaml > history[]
  • Compare with previous score → log bugs_fixed / regressions
  • Update memory/per-project/<p>/screens/_index.yaml

STEP 7: PROMPT FOR FEEDBACK
  Hiển thị report + dòng cuối:
  "Anh có feedback nào không? Reply để skill học:
   - 'FP: <rule_id> ở <file>:<line> — <reason>'
   - 'Bug pattern mới: <description>'
   - 'Quirk: <screen> skip <rule_id> vì <reason>'"
  
  Nếu anh reply → parse qua prompts/feedback-parser.md → update memory → propose commit
```

## Anti-False-Positive — RULE CỨNG

**TRƯỚC KHI flag bất kỳ issue nào**:

1. ĐỌC memory/false-positives.yaml — nếu match pattern → SUPPRESS, KHÔNG flag
2. ĐỌC screen quirks — nếu line trong range exception → SUPPRESS
3. ĐỌC project config — nếu rule có exception cho project này → DOWNGRADE
4. TÍNH confidence — nếu <0.6 → INFO, không ERROR

**Mọi flag phải có evidence**:
- File + line cụ thể
- Code snippet trích từ file
- Proposed fix
- Confidence score [0.0-1.0]

KHÔNG được output kết luận chung chung kiểu "looks good overall". CHỈ assertion + evidence.

## Multi-Project Context — RULE CỨNG

KHÔNG apply rule mặc định cứng nhắc. PHẢI:

1. Detect project trước
2. Load `projects/<project>.yaml`
3. Apply override rules per project
4. Nếu chưa có config project → tạo từ `projects/_template.yaml` và CONFIRM với anh

## Self-Learning — RULE CỨNG

Sau MỖI audit:
1. Parse anh's feedback (nếu có)
2. Update memory/false-positives.yaml hoặc memory/new-patterns.yaml
3. Show diff propose commit
4. Sau khi anh OK → commit + bump CHANGELOG

Pattern lifecycle: DETECTED → PROPOSED → TESTING (14 ngày) → VALIDATED → ACTIVE → DEPRECATED.
**Manual approve** từ anh tại mọi state transition. KHÔNG auto-promote.

## Output Format

Report markdown — xem `prompts/audit-screen.md` cho format chuẩn.

## Files cần đọc khi audit

1. `core/rules.yaml` — universal rules
2. `core/severity-matrix.yaml` — severity per rule_id
3. `core/confidence-thresholds.yaml` — FP avoidance settings
4. `projects/<project>.yaml` — project override
5. `memory/false-positives.yaml` — FP database
6. `memory/per-project/<project>/screens/<screen>.yaml` — per-screen context
7. `core/checks/*.md` — actual check logic

## CẤM

- KHÔNG output "looks correct" / "all good" / "no issues found" without listing what was checked
- KHÔNG flag issue mà không qua 4 gates anti-FP
- KHÔNG modify file của project user — chỉ READ và report
- KHÔNG auto-promote pattern khi anh chưa approve
- KHÔNG ignore memory — phải đọc TRƯỚC khi audit
