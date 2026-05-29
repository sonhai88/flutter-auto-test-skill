# Prompt: Log Analyzer

Em parse log file → categorize exceptions + map về source line.

## Input

```
log_file: /path/to/logs.txt
project_root: /Volumes/hai/itg-mobile
duration_seconds: 30
```

## Bước 1: Filter relevant lines

Keep:
- `EXCEPTION CAUGHT`, `Unhandled Exception`
- `[ERROR]`, `flutter:` with error keyword
- `Skipped N frames`
- `assertion ... failed`
- Stack trace frames

Discard:
- INFO/DEBUG logs
- Hot reload artifacts
- Framework noise (e.g., "Dart VM service")

## Bước 2: Group by exception

Multi-line exception block = 1 entry:
```
═══ EXCEPTION CAUGHT BY WIDGETS LIBRARY ═══
<assertion message>
<location>
═══════════════════════════
#0 ...
#1 ...
#2 MyWidget.build (package:app/file.dart:42)
═══════════════════════════
```

## Bước 3: Map về source

For each stack frame matching `package:<app_name>/...`:
1. Extract file path + line
2. Verify file exists in project_root
3. Read context: 5 lines before + 5 lines after
4. Show snippet

## Bước 4: Categorize

```yaml
categories:
  rendering:
    patterns: ["RenderFlex overflowed", "RenderBox", "assertion .* failed"]
    severity: error
    
  lifecycle:
    patterns: ["setState.*dispose", "unmounted", "BuildContext.*used"]
    severity: error
    
  platform:
    patterns: ["PlatformException", "MissingPluginException"]
    severity: error
    
  network:
    patterns: ["SocketException", "HandshakeException", "TimeoutException"]
    severity: warn
    
  performance:
    patterns: ["Skipped \\d+ frames", "Frame took.*ms"]
    severity: warn
    
  permissions:
    patterns: ["denied permission", "not authorized"]
    severity: info
```

## Bước 5: Anti-FP

Common FPs:
- Debug-only logs (filter by --release flag tương lai)
- Hot reload artifacts: lines containing "[REASSEMBLE]"
- Test mode noise: lines from `test/` files

## Bước 6: Output structured

```yaml
log_analysis:
  duration: 30s
  total_lines: 12455
  filtered: 234
  exceptions: 8
  
  categorized:
    rendering: 3
    lifecycle: 2
    platform: 1
    network: 1
    performance: 1
  
  top_issues:
    - exception: RenderFlex overflowed (3x)
      location: lib/page/home/home_page.dart:267
      severity: error
      source_snippet: |
        265: Row(
        266:   children: [
        267:     Image.asset(...),  // ← width too large
        268:     Text(...),
        269:   ],
        270: )
      fix_suggestion: Wrap Image trong Expanded hoặc constrain width
      
    - exception: setState() called after dispose() (1x)
      location: lib/page/auth/login/login_page.dart:99
      severity: error
      source_snippet: |
        96: }).whenComplete(() {
        97:   setState(() {
        98:     _isLoading = false;
        99:   });   // ← widget có thể đã unmounted
      fix_suggestion: Add `if (mounted)` check trước setState
```

## Quy tắc

- KHÔNG dedupe khác location — exception giống message + khác file = riêng biệt
- KHÔNG suppress performance warnings nếu < 5 frame skip nhưng lặp > 10 lần (pattern)
- LUÔN cite source line nếu match được package:
- Nếu KHÔNG map được → severity = info, mark "cần investigate"
