# Feedback Parser Prompt

Khi anh comment về audit report → em parse → propose memory update.

---

## Input

Anh's raw comment, ví dụ:
- "FP: states-coverage.missing-loading ở LoginScreen.dart:42 — dùng AsyncValue.when"
- "Bug pattern mới: dev hay quên dispose TextEditingController"
- "Quirk: HomeScreen line 45-50 skip tokens.no-hardcode vì gradient overlay"
- "Đúng rồi, fix ngay"  (acknowledgment, không action)
- Comment tự do bằng tiếng Việt — em hiểu intent

## Bước 1: Classify intent

```
Patterns:
  FALSE_POSITIVE:
    Keywords: "FP", "false positive", "sai rồi", "không phải bug", "có rồi", "đã có"
    Required fields: rule_id, location (file:line), reason
  
  NEW_PATTERN:
    Keywords: "bug pattern mới", "phát hiện pattern", "thấy ai cũng", "nên catch", "thêm rule"
    Required fields: description, examples (nếu có)
  
  QUIRK:
    Keywords: "quirk", "exception", "skip", "ignore line", "screen này khác"
    Required fields: screen_name, rule_id, line_range, reason
  
  ACKNOWLEDGE:
    Keywords: "OK", "đúng rồi", "fix nhé", "cám ơn", "skip"
    Action: no memory update
  
  UNCLEAR:
    Default khi không classify được
    Action: ask user clarification
```

## Bước 2: Extract fields

Nếu classify success, extract structured data:

### FALSE_POSITIVE
```yaml
type: FALSE_POSITIVE
rule_id: <from comment hoặc từ recent audit context>
file: <relative path>
line: <line number>
pattern_signature: <auto-generate từ code_snippet>
reason: <free text>
scope: project|all  # default: current project
```

### NEW_PATTERN
```yaml
type: NEW_PATTERN
title: <short description>
detection_logic: <propose từ comment>
examples:
  - file: <if mentioned>
    description: ...
testing_project: <current project default>
```

### QUIRK
```yaml
type: QUIRK
screen_name: <ScreenName>
file: <path>
rule_id: <rule>
line_range: [start, end]
reason: <text>
expires: null  # optional
```

## Bước 3: Show proposal to anh

Format:
```markdown
Em sẽ apply update này:

```yaml
{proposed_yaml}
```

Files affected:
- memory/false-positives.yaml (+1 entry)
- memory/per-project/itg-mobile/screens/LoginScreen.yaml (+1 quirk)

Confirm? [Yes / No / Edit]
```

## Bước 4: Apply update

Nếu anh confirm:
1. Edit file YAML (preserve existing entries)
2. Bump VERSION nếu cần (PATCH for FP suppression, MINOR for new pattern/quirk)
3. Append entry to memory/tuning-history.md
4. Show diff to anh
5. Suggest commit message:
   ```
   chore(memory): suppress FP states-coverage.missing-loading for AsyncValue.when
   
   Confirmed by anh after audit on LoginScreen.
   Pattern: AsyncValue<.+>\.when\s*\(\s*loading:\s*\(
   ```

## Bước 5: Sync downstream

```bash
# Optional: run sync scripts
./scripts/sync-obsidian.sh
```

---

## RULES

1. **KHÔNG silent update** — luôn show proposal + confirm trước
2. **KHÔNG dedupe aggressively** — nếu FP đã có tương tự, MERGE vào entry cũ (add screen_seen), KHÔNG tạo entry mới
3. **NẾU UNCLEAR** — hỏi anh 1 câu cụ thể, không 5 câu generic
4. **PRESERVE comments** trong YAML khi edit
5. **Bump VERSION** đúng:
   - FP suppression → PATCH (1.0.1)
   - New quirk → PATCH
   - New pattern PROPOSED → MINOR? No → no version bump (chưa active)
   - Pattern PROMOTED to ACTIVE → MINOR
   - New check added → MINOR
