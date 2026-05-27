# Check 02 — Tokens Compliance

Verify code dùng design system tokens (LmeColors, LmeTypography, LmeSpacing) thay vì hardcode value.

## Mục tiêu

Catch các trường hợp:
- Hardcode color: `Color(0xFF...)`, `Colors.blue`
- Spacing arbitrary: `EdgeInsets.all(13)`, `SizedBox(width: 17)`
- Font size arbitrary: `TextStyle(fontSize: 15)`
- Border radius arbitrary: `BorderRadius.circular(7)`

## Quy trình check

### Bước 1: Pre-flight
- Load `projects/<project>.yaml` → đọc `rules.tokens-compliance.*` overrides
- Load `memory/per-project/<p>/screens/<s>.yaml` → đọc quirks
- Load `memory/false-positives.yaml` → đọc FP signatures

### Bước 2: Detection

#### 2.1 Hardcode color
```regex
Pattern A: Color\(0x[0-9A-Fa-f]{8}\)
Pattern B: Colors\.(?!transparent\b)[a-z][a-zA-Z]+
```

**Exemptions mặc định** (luôn skip):
- File path matches: `**/*.g.dart`, `**/*.freezed.dart`
- File path matches: `**/theme/**`, `**/foundations/**` (chính là nơi định nghĩa token)
- `Colors.transparent` (const, ok)

#### 2.2 Spacing arbitrary
```regex
EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*\)
SizedBox\(\s*(width|height):\s*\d+
```
Parse số → check thuộc scale `{4, 8, 12, 16, 20, 24, 32, 40, 48, 64}` không. Lệch → flag.

#### 2.3 Font size arbitrary
```regex
TextStyle\([^)]*fontSize:\s*\d+
fontSize:\s*\d+
```
Scale: `{10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 48}`

#### 2.4 Border radius arbitrary
```regex
BorderRadius\.circular\(\s*\d+
BorderRadius\.all\(Radius\.circular\(\s*\d+
```
Scale: `{4, 8, 12, 16, 24}` hoặc `BorderRadius.full` (cho avatar/chip).

### Bước 3: Apply 4-gate filter

For each candidate issue:

```
Gate 1 — FP Database:
  signature = "tokens-compliance.no-hardcode-color:" + normalize_code_snippet
  if signature in memory/false-positives.yaml → SUPPRESS

Gate 2 — Screen Quirks:
  if (rule_id, line) matches quirks[].rule_id + line_range → SUPPRESS

Gate 3 — Project Exceptions:
  if pattern matches projects[<p>].rules[<rule>].exceptions[].pattern
     AND context_match → DOWNGRADE severity

Gate 4 — Confidence:
  confidence = compute_ast_match_score(detection) * 0.7
             + compute_context_match_score(file_role) * 0.3
  apply core/confidence-thresholds.yaml mapping
```

### Bước 4: Output candidate

Per issue, output JSON-ish:
```yaml
- rule_id: tokens-compliance.no-hardcode-color
  file: lib/features/auth/login_screen.dart
  line: 120
  column: 12
  code_snippet: |
    Container(
      color: Color(0xFF1F1F1F),
      ...
  proposed_fix: |
    Container(
      color: LmeColors.onSurface,
      ...
  severity: error
  confidence: 0.95
  evidence: |
    Found `Color(0xFF1F1F1F)` which matches Pattern A.
    Not in any FP signature.
    Not in screen quirks.
    Not in project exceptions.
    AST match: exact (1.0). Context match: feature file (0.9).
```

## Ví dụ Concrete

### TP (true positive — đúng phải flag)
```dart
// lib/features/auth/login_screen.dart:120
Container(
  color: Color(0xFF1F1F1F),  // ← FLAG: hardcode
)
```
→ Confidence 0.95, severity ERROR.

### FP đã biết (cần SUPPRESS)
```dart
// File trong lib/theme/
class LmeColors {
  static const Color onSurface = Color(0xFF1F1F1F);  // ← OK, đây là định nghĩa token
}
```
→ Suppressed by exemption: `**/theme/**` path.

### Edge case — Color.fromARGB cho overlay (project itg-mobile)
```dart
// lib/features/home/home_screen.dart:45
gradient: LinearGradient(
  colors: [Color.fromARGB(120, 0, 0, 0), Colors.transparent],  // overlay
)
```
→ Project itg-mobile có exception:
```yaml
tokens-compliance.no-hardcode-color:
  exceptions:
    - pattern: Color.fromARGB
      context: gradient_overlay
      reason: Design chưa có gradient token
```
→ DOWNGRADE từ ERROR → INFO, hoặc SUPPRESS hoàn toàn tùy config.

## Anti-pattern em phải tránh

- ❌ KHÔNG flag `Colors.transparent` (đã exempt)
- ❌ KHÔNG flag file trong `**/theme/**`
- ❌ KHÔNG flag generated `.g.dart`, `.freezed.dart`
- ❌ KHÔNG flag `EdgeInsets.zero` (zero = ok)
- ❌ KHÔNG kết luận chung chung "all tokens look fine" — phải list cụ thể đã check gì

## Output sample

```markdown
## tokens-compliance — 2 issues

### [ERROR] no-hardcode-color (1)
- `login_screen.dart:120` Color(0xFF1F1F1F) → LmeColors.onSurface (conf 0.95)

### [WARN] spacing-arbitrary (1)
- `login_screen.dart:34` EdgeInsets.all(17) — không thuộc scale {4,8,12,16,20,24,32} → đề xuất 16 hoặc 20 (conf 0.85)
```
