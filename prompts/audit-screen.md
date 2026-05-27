# Audit Screen Prompt

Prompt em (Claude) follow khi user gõ `/flutter-auto-test <path>`.

---

## Input

```
file_path: absolute path tới screen.dart
project: auto-detect hoặc explicit --project <slug>
figma_url: optional, --figma <url>
mode: full | quick (quick = chỉ tokens + icons, full = all checks enabled)
```

## Bước 1: Bootstrap

```
1. Walk up từ file_path tìm pubspec.yaml → xác định project root
2. Tìm projects/<slug>.yaml (nếu user explicit) hoặc match root_path
3. Nếu không có config:
   → Tell user: "Project chưa có config. Em tạo từ template projects/_template.yaml?"
   → Wait for confirmation
4. Load:
   - core/rules.yaml
   - core/severity-matrix.yaml
   - core/confidence-thresholds.yaml
   - projects/<slug>.yaml (override)
   - memory/false-positives.yaml
   - memory/per-project/<slug>/screens/<screen>.yaml (nếu có)
5. Compute effective rules: merge core + project + screen quirks
```

## Bước 2: Pre-flight

```
1. Read file_path (Read tool)
2. Detect role:
   - File ending _screen.dart, _page.dart, _view.dart → screen
   - File ending _notifier.dart, _controller.dart, _provider.dart → notifier
   - File ending _repository.dart, _repo.dart → repository
   - File ending _service.dart → service
   - File ending _model.dart, .freezed.dart → model
   - Default → widget
3. Detect related files:
   - Same folder + matching name (LoginScreen → login_notifier, login_repository)
   - Read them (giảm context if too big — chỉ đọc signature)
4. If --figma URL:
   - Parse fileKey + nodeId
   - Call mcp__plugin_figma_figma__get_design_context
   - Extract spec table: fontSize, color, padding, etc.
```

## Bước 3: Run Active Checks

Chạy theo thứ tự (parallel khi có thể):

```
For each check in project.metrics.enabled_checks:
  Read core/checks/<NN>-<name>.md
  Apply detection logic
  Output: [issue_candidate, ...]
```

## Bước 4: Anti-FP Filter (BẮT BUỘC qua 4 gates)

```
For each candidate:
  
  # Gate 1: FP Database
  signature = normalize(candidate.code_snippet)
  for fp in false_positives:
    if fp.rule_id == candidate.rule_id AND regex_match(signature, fp.pattern_signature):
      candidate.status = SUPPRESSED
      candidate.reason = f"matched FP {fp.id}"
      break
  
  # Gate 2: Screen Quirks
  for quirk in screen_yaml.quirks:
    if quirk.rule_id == candidate.rule_id AND candidate.line in quirk.line_range:
      candidate.status = SUPPRESSED
      candidate.reason = f"screen quirk: {quirk.reason}"
      break
  
  # Gate 3: Project Exceptions
  for exception in project.rules[candidate.rule_id].exceptions:
    if regex_match(candidate.code_snippet, exception.pattern):
      candidate.severity = DOWNGRADE(candidate.severity)
      candidate.note = f"project exception: {exception.reason}"
  
  # Gate 4: Confidence
  candidate.confidence = compute_confidence(candidate)
  candidate.severity = apply_confidence_mapping(candidate.severity, candidate.confidence)
```

## Bước 5: Generate Report

Output format markdown — xem template dưới đây.

## Bước 6: Update Memory

```
1. Write reports/<YYYY-MM-DD>/<project>/<screen>.md
2. Update memory/per-project/<slug>/screens/<ScreenName>.yaml:
   - Append history entry với date, score, bugs_fixed, regressions
3. Update memory/per-project/<slug>/screens/_index.yaml
```

## Bước 7: Prompt Feedback

Display:
```
Audit xong. Anh có feedback nào không?
- "FP: <rule_id> ở <file>:<line> — <reason>" → em update FP database
- "Bug pattern mới: <description>" → em propose new pattern
- "Quirk: <screen> skip <rule_id> line X-Y vì <reason>" → em add screen quirk
- (Bỏ qua nếu OK rồi)
```

Nếu anh reply → gọi `prompts/feedback-parser.md` để parse + propose update.

---

## REPORT TEMPLATE

```markdown
# Audit Report: {ScreenName}

**Project**: {project}
**File**: {relative_path}
**Audited**: {date} {time}
**Skill version**: {version}
**Score**: {score}/100 {trend_arrow} ({delta} từ lần trước {prev_score}/100)

---

## ❌ MUST FIX ({error_count})

### [HIGH] {rule_id}
**File**: {file}:{line}
**Issue**: {description}
**Evidence**:
```{lang}
{code_snippet}
```
**Fix**:
```{lang}
{proposed_fix}
```
**Confidence**: {confidence}

{repeat for each error}

---

## ⚠️ SHOULD FIX ({warn_count})

{same format, severity MED}

---

## 💡 NICE TO HAVE ({info_count})

{same format, severity LOW}

---

## ✅ PASSED ({passed_count})

{compact list:}
- ✓ {check_name}: {brief note}

---

## 🔇 SUPPRESSED ({suppressed_count})

{compact list with reason:}
- 🔇 {rule_id} {file}:{line} — {suppression_reason} [{fp_id} or quirk]

---

## 📊 Trend (last 5 audits)

| Date       | Score | Bugs Fixed                    |
|------------|-------|-------------------------------|
| {history_entries}                                  |

---

## 💡 Watch List (open items)

- {item} (detected {date}, plan: {plan})

---

## 📝 Anh có feedback nào không?

Reply để skill học:
- `FP: <rule_id> ở <file>:<line> — <reason>`
- `Bug pattern mới: <description>`
- `Quirk: <screen> skip <rule_id> line X-Y vì <reason>`
```

---

## RULES CỨNG khi audit

1. **KHÔNG kết luận chung chung** — mọi assertion phải có evidence (file + line + snippet)
2. **PHẢI qua 4 gates** trước khi flag — bypass = lỗi
3. **PHẢI update memory** sau audit — quên = mất learning loop
4. **PHẢI hỏi feedback** ở cuối — không hỏi = skill không học được
5. **KHÔNG modify source code** của project user — chỉ Read + report
6. **KHÔNG flag issue trong** `**/*.g.dart`, `**/*.freezed.dart`, `lib/theme/**`, ignore paths trong project config
