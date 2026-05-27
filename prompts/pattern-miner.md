# Pattern Miner Prompt

Chạy từ `scripts/mine-git-history.sh` cron weekly.
Phân tích git commit (fix bug) → extract pattern catchable bằng static analysis.

---

## Input

```
commit_hash: <hash>
diff: <full git show output>
message: <commit message>
project: <slug>
```

## Bước 1: Phân loại commit

Chỉ analyze nếu:
- Commit message starts with `fix:`, `fix(`, `bugfix:`, hoặc tag `bug`
- Diff có ý nghĩa (> 5 lines changed, không phải doc/format)
- Files trong `lib/features/` hoặc `lib/shared/`

Skip:
- `chore:`, `docs:`, `test:`, `style:`, `refactor:` (không phải bug fix)
- Pure dependency bump
- Generated files (`.g.dart`, `.freezed.dart`)

## Bước 2: Extract pattern

Đọc diff. Trả lời:

```
1. Bug gì? (1 câu)
2. Pattern code nào gây bug? (regex hoặc AST descrition)
3. Pattern fix nào solve? (proposed solution)
4. Static analysis có catch được không? (true/false + lý do)
5. Generality: bug này có thể xảy ra ở file/feature khác? (yes/no + why)
```

## Bước 3: Generate proposal

Nếu Step 2 question 4 == true AND question 5 == yes:

```yaml
- id: pattern-{date}-{seq}
  title: {1-line title}
  status: PROPOSED
  detected_from: git-history-mining
  detected_at: {today}
  detection_logic: |
    {regex hoặc rules}
  examples_caught:
    - commit: {hash}
      file: {file}
      line: {line}
      note: {bug description}
  testing_in_project: {project}
  testing_started: null
  testing_window_days: 14
  metrics:
    true_positives: 0
    false_positives: 0
    fp_rate: 0.0
  promote_at: null
  notes: |
    Auto-mined từ commit {hash}.
    Cần anh review trước khi promote TESTING.
```

Append vào `memory/new-patterns.yaml` → `patterns` array.

## Bước 4: Notification

Sau khi mine xong batch (ví dụ 1 tuần):
```
Telegram message gửi anh:
"📊 Tuần này mine được {N} pattern mới đề xuất.
Review tại: /Volumes/hai/Notes/2.0 Projects/flutter-auto-test-skill/
File: memory/new-patterns.yaml (anh check section 'patterns' mới thêm)"
```

---

## DEDUPE

Trước khi append, check existing patterns:
- Match title (fuzzy 80%)
- Match detection_logic
→ Nếu match → add commit vào `examples_caught` của entry cũ thay vì tạo mới

## ANTI-PATTERN

- ❌ Propose pattern quá generic ("missing error handling" — không actionable)
- ❌ Propose pattern không catch được bằng static analysis
- ❌ Propose pattern chỉ xảy ra 1 lần (chờ thêm data point)
- ❌ Auto-promote không cần anh approve

## QUALITY BAR

Pattern proposal được xem là HIGH QUALITY nếu:
- Có ≥ 2 examples từ commit thật
- Detection logic là regex/AST cụ thể (không phải "phân tích semantic")
- Có proposed fix rõ ràng
- Generality ≥ 0.7 (có thể tái xuất hiện)
