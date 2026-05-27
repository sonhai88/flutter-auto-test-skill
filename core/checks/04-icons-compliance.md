# Check 04 — Icons Compliance

Verify project dùng design system icons (LmeIcons hoặc equivalent), KHÔNG Material/Cupertino default.

## Tại sao quan trọng

Material Icons không match design system → UI lệch theme. Anh đã setup `lme-flutter` skill và memory rule: "dùng LmeIcons, CẤM Material Icons".

## Quy trình check

### Bước 1: Pre-flight
- Load project config → đọc `design_system` field (lme_ui? custom? none?)
- Nếu `design_system: none` → SKIP check này

### Bước 2: Detection

#### 2.1 Material Icons usage
```regex
Icons\.[a-z][a-zA-Z0-9_]+
```
**Skip files**:
- `lib/theme/**`, `lib/foundations/**`
- File định nghĩa custom icon mapping (nếu có)

#### 2.2 Cupertino Icons usage
```regex
CupertinoIcons\.[a-z][a-zA-Z0-9_]+
```

#### 2.3 Material import unused
```yaml
detection_logic: |
  1. File có `import 'package:flutter/material.dart';`
  2. Phân tích symbols được dùng từ material:
     - Nếu chỉ dùng: MaterialApp, Theme, ThemeData, Scaffold, AppBar (allowed)
     - VÀ KHÔNG dùng: Icons.*, Card, ListTile, FloatingActionButton, etc.
  3. Đề xuất: dùng `package:flutter/widgets.dart` thay thế cho file widget thuần
severity: warn
note: Hiện chưa có DS thay thế hoàn chỉnh Material core → severity WARN, không ERROR
```

### Bước 3: Apply 4-gate filter

Gate 3 đặc biệt cho icons:
```yaml
projects/itg-mobile.yaml might have:
  rules:
    icons-compliance.no-material-icons:
      severity: error
      exceptions:
        - icon_name: arrow_back
          reason: Native back button, LmeIcons chưa có
          allowed_in: ["AppBar leading"]
```

## Ví dụ Concrete

### TP — Material icon trong feature
```dart
// lib/features/cart/cart_screen.dart
IconButton(
  icon: Icon(Icons.shopping_cart),  // ← FLAG
  onPressed: ...
)
```
→ ERROR conf 0.98. Fix: `Icon(LmeIcons.cart)`.

### TP — Cupertino in cross-platform feature
```dart
Icon(CupertinoIcons.heart)  // ← FLAG
```
→ ERROR conf 0.98.

### FP — material.dart import for MaterialApp only
```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(  // OK, MaterialApp cần material.dart
    home: HomeScreen(),
    theme: lmeTheme(),
  ));
}
```
→ SUPPRESSED: only uses MaterialApp + theme.

### FP đã biết — exception cho arrow_back
```dart
// lib/features/auth/screens/login_screen.dart
AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),  // ← project allowed
    onPressed: () => context.pop(),
  ),
)
```
→ Nếu project itg-mobile.yaml có exception → SUPPRESS hoặc DOWNGRADE.

## Anti-pattern em phải tránh

- ❌ Flag Icons.* trong lib/theme/
- ❌ Flag generated files
- ❌ Báo "all icons fine" mà không list file đã scan
- ❌ Quên skip khi project chưa có design system (`design_system: none`)

## Output sample

```markdown
## icons-compliance — 2 issues

### [ERROR] no-material-icons (2)
- `cart_screen.dart:34` Icons.shopping_cart → LmeIcons.cart (conf 0.98)
- `profile_screen.dart:67` Icons.person → LmeIcons.user (conf 0.98)

### [WARN] material-import-unused (1)
- `home_screen.dart:1` import material.dart nhưng chỉ dùng Scaffold + Theme → cân nhắc widgets.dart (conf 0.7)
```

## Tích hợp với lme-flutter skill

Anh đã có skill `lme-flutter` mapping Material Icons → LmeIcons. Khi flag, em recommend ref đến đó:

```markdown
> 💡 Skill `lme-flutter` có sẵn mapping Icons.X → LmeIcons.X. 
> Có thể auto-fix bằng `/lme-flutter migrate-icons <file>`
```
