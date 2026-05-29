# Check 09 — Visual Figma Drift (Runtime)

Compare app rendered state vs Figma design — catch pixel/layout drift mà static check không thấy.

## Tại sao quan trọng

Static audit chỉ verify code dùng đúng token. Nhưng:
- Widget tree đúng KHÔNG có nghĩa render đúng
- Font system khác trên iOS vs Android
- Image asset có thể lệch resolution
- AnimationController có thể glitch state
→ Phải xem app THẬT chạy mới biết.

## Quy trình

### Bước 1: Pre-flight
- Confirm có booted simulator (`runtime/scripts/device-list.sh`)
- App đã install (bundle_id trong project config)
- Có Figma URL/node_id cho screen target

### Bước 2: Setup baseline
```bash
# Clean status bar (Apple marketing)
./runtime/scripts/status-bar.sh apple

# Launch app cold
./runtime/scripts/launch-app.sh com.wssv.itg.dev --cold

# Wait for splash → home
sleep 3
```

### Bước 3: Capture target screen
Navigate đến screen target (qua Maestro flow hoặc manual):
```bash
# Option A: Manual — anh navigate, em chỉ screenshot
./runtime/scripts/screenshot.sh --label target-screen

# Option B: Auto — Maestro navigate
./runtime/scripts/run-flow.sh runtime/maestro-flows/navigate-to-login.yaml
```

### Bước 4: Get Figma spec
```bash
# Em call qua MCP
mcp__plugin_figma_figma__get_design_context(file_key, node_id)
# → trả về React/Tailwind code = SPEC chính xác
```

### Bước 5: Compare (LLM vision)

Em phân tích screenshot + Figma spec, output diff:

```yaml
visual_drift_report:
  screen: LoginPage
  figma_node: ABC123:42
  device: iPhone 15 Pro iOS 17.5
  screenshot: artifacts/2026-05-28/login-actual.png
  
  drifts:
    - element: "Title text"
      figma: { fontSize: 24, fontWeight: 600, color: "#1F1F1F" }
      actual: { fontSize: 28, fontWeight: 700, color: "#1F1F1F" }
      severity: warn
      delta: "fontSize +4px, weight +100"
      
    - element: "Submit button"
      figma: { padding: 16, radius: 12, color: "#7B56E0" }
      actual: { padding: 12, radius: 8, color: "#7B56E0" }
      severity: error
      delta: "padding -4, radius -4"
      
    - element: "Status bar"
      figma: "absent"
      actual: "visible 47px"
      severity: info
      note: "SafeArea handling — verify intentional"
  
  score: 70
  recommendation: |
    2 drifts critical: button padding/radius lệch design.
    Fix file: lib/page/auth/login/login_page.dart
    Line: ~190 (TextButton decoration)
```

### Bước 6: Anti-FP gates (giống static)
- Gate 1: FP database (e.g., status bar drift exempt cho SystemUiOverlayStyle)
- Gate 2: Screen quirks
- Gate 3: Project exceptions
- Gate 4: Confidence (vision match score)

## Detection logic

Em phân tích screenshot bằng vision capabilities:
1. **OCR text** → so sánh với Figma text
2. **Detect layout boundaries** (group widget, alignment)
3. **Extract dominant colors** trong regions
4. **Estimate spacing** (px gap giữa elements)
5. **Detect font family/weight** từ render

## Ví dụ thực tế

### TP (drift đúng phải flag)
```
Figma:   Button { padding: 16, radius: 12 }
Render:  Button rounded-corner nhỏ + text touching edge
→ Confidence 0.95 (clear visual diff)
→ ERROR
```

### FP (drift không phải lỗi)
```
Figma:   Status bar transparent
Render:  Status bar 47px visible
→ Reason: SafeArea handling — design system convention
→ SUPPRESSED bởi fp-002 (Status bar SafeArea exempt)
```

## Output

Markdown table + screenshot inline (Obsidian/GitHub render).

## Limitations

- Em ước lượng pixel KHÔNG đo chính xác — vision-based, error ~5%
- Animation state khó capture đúng moment
- Dark mode vs Light mode cần audit riêng
- Multi-resolution (iPhone SE vs Pro Max) cần screenshot từng device
