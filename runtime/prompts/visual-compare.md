# Prompt: Visual Compare Screenshot vs Figma

Em (Claude) follow prompt này khi user yêu cầu visual audit runtime.

## Input

```
device_screenshot: /path/to/screenshot.png
figma_url: figma.com/design/<file_key>/?node-id=<node_id>
screen_name: LoginPage
project: itg-mobile
```

## Bước 1: Lấy Figma spec

```
1. Parse figma_url → fileKey + nodeId
2. Call mcp__plugin_figma_figma__get_design_context(fileKey, nodeId)
3. Extract spec table từ Tailwind/CSS output:
   - fontSize, fontWeight, letterSpacing per text
   - color hex per element
   - padding/margin numeric
   - border radius
   - layout flexbox / grid
```

## Bước 2: Vision analyze screenshot

```
1. Identify UI elements (header, button, input, card, list)
2. For each element:
   - Estimate position (x, y, width, height)
   - Read text content via OCR
   - Estimate dominant color (closest hex)
   - Estimate font size (pixel measurement)
   - Detect alignment (left/center/right)
3. Build element tree từ screenshot
```

## Bước 3: Element matching

Match Figma elements ↔ Screenshot elements:
- By text content (exact match preferred)
- By position (relative coordinates)
- By role (header, button, list-item)

## Bước 4: Diff per attribute

Per matched pair, compare:
```yaml
element_diff:
  figma:
    text: "Đăng nhập"
    fontSize: 16
    fontWeight: 600
    color: "#7B56E0"
    padding: { vertical: 16, horizontal: 32 }
    radius: 12
  
  actual:
    text: "Đăng nhập"
    fontSize: 18   # 🚨 +2px
    fontWeight: 700 # 🚨 +100
    color: "#7B56E0"
    padding: { vertical: 14, horizontal: 28 }  # 🚨 lệch
    radius: 8       # 🚨 -4
  
  drift:
    severity: warn
    details:
      - fontSize: +2px
      - fontWeight: +100
      - padding: -2 v, -4 h
      - radius: -4
```

## Bước 5: Apply anti-FP gates

Common false positives em phải SUPPRESS:

```yaml
fp_suppressions:
  - rule: Status bar (47px iPhone) không trong Figma
    reason: Hệ thống render — không phải code drift
    
  - rule: Safe area inset bottom (34px iPhone home indicator)
    reason: System UI, design ignore
    
  - rule: System font fallback
    reason: Nếu device thiếu font designed → fallback OK
    
  - rule: Anti-aliasing edge variation < 2px
    reason: Render engine difference iOS vs Figma
```

## Bước 6: Output

Markdown report:
```markdown
# Visual Audit: LoginPage

**Score**: 78/100 (3 critical drifts, 5 minor)

## 🔴 Critical drifts (3)

### Button "Đăng nhập" — padding lệch
- Figma: `padding: 16 32`
- Render: `padding: 14 28`
- Delta: vertical -2px, horizontal -4px
- Fix: lib/page/auth/login/login_page.dart:190
- Suggested: `EdgeInsets.symmetric(vertical: 16, horizontal: 32)`

[screenshot inline]

## 🟡 Minor drifts (5)

...

## ✅ Matches (15)

...
```

## Quy tắc CẤM

- ❌ KHÔNG kết luận "looks correct" mà không list từng element đã check
- ❌ KHÔNG flag drift < 2px (noise)
- ❌ KHÔNG flag pure-render artifact (anti-aliasing, font smoothing)
- ❌ KHÔNG so sánh đường nét bằng pixel — chỉ semantic (color, size, spacing)

## Self-confidence

Em luôn đánh confidence per drift:
- 0.95+ → text content mismatch (OCR clear)
- 0.85 → color hex mismatch (sample multiple pixels)
- 0.70 → spacing mismatch (estimation ~5% error)
- 0.50 → font weight (khó measure exact)
- <0.5 → vague — note "cần measure tay"
