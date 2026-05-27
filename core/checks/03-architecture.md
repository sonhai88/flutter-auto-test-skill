# Check 03 — Architecture Compliance

Verify code tuân thủ 7 rule cứng Flutter architecture (Riverpod + Dio + GoRouter + Repository pattern).

## 7 rule kiểm tra

1. **Models immutable** (copyWith/Freezed)
2. **State management qua Riverpod** (KHÔNG setState global)
3. **Dio interceptor** (auth + retry + log)
4. **GoRouter type-safe** + guards
5. **Result type cho error** (KHÔNG throw cross-layer)
6. **Repository pattern** (data source behind interface)
7. **Feature-based folder structure**

## Quy trình check

### Bước 1: Pre-flight
- Detect file role: screen / notifier / repository / service / widget / model
- Load project config → đọc Riverpod version, GoRouter có dùng không
- Load screen quirks

### Bước 2: Per-role checks

#### Role A: Screen file (`lib/features/*/screens/*.dart` hoặc `*_screen.dart`)

```yaml
checks:
  - id: architecture.no-setstate-feature
    detection: grep `setState\(` in file
    exemptions:
      - AnimationController (state management cho animation OK)
      - TextEditingController dispose hooks (OK)
    severity: error

  - id: architecture.gorouter-no-navigator-push
    detection: grep `Navigator\.(push|pop|pushNamed)\(`
    when: project config có go_router enabled
    proposed_fix: context.go / context.push
    severity: warn

  - id: states-coverage  # delegate to check 06
    note: Implemented separately

  - id: architecture.notifier-not-watched
    detection: |
      Tìm screen widget mà KHÔNG có ref.watch / Consumer / ConsumerWidget
      Nếu screen có data dynamic → nên watch một notifier
    severity: warn
```

#### Role B: Notifier file (`*_notifier.dart`, `*_provider.dart`)

```yaml
checks:
  - id: architecture.notifier-missing-autodispose
    detection: |
      Find StateNotifierProvider không phải .autoDispose
      Find @Riverpod(keepAlive: true) — cần intentional
    severity: warn

  - id: architecture.notifier-throw-direct
    detection: |
      Trong method của notifier, có `throw Exception(`
      Phải dùng AsyncValue.error hoặc Result type
    severity: error
```

#### Role C: Repository file (`*_repository.dart`, `*_repo.dart`)

```yaml
checks:
  - id: architecture.no-throw-cross-layer
    detection: |
      Find `throw ` trong method public của repository
      Trừ throw trong internal helper KHÔNG được gọi từ ngoài
    proposed_fix: return Result<T, AppError> / Either
    severity: error

  - id: architecture.repo-missing-interface
    detection: |
      Class XRepository không implement interface IXRepository
      Hoặc không có abstract base class
    severity: warn

  - id: architecture.dio-no-direct-instantiate
    detection: grep `Dio\(\)` trong file
    proposed_fix: inject qua provider
    severity: error
```

#### Role D: Service file (`*_service.dart`)

```yaml
checks:
  - id: architecture.no-throw-cross-layer  # same as repo
  - id: architecture.dio-no-direct-instantiate
  - id: architecture.service-no-business-logic-in-ui
    detection: service được import vào screen file trực tiếp (nên qua notifier)
    severity: warn
```

#### Role E: Model file (`*_model.dart`, `*.freezed.dart`)

```yaml
checks:
  - id: architecture.model-not-immutable
    detection: |
      Class XModel có field không final
      Hoặc không có copyWith / không dùng @freezed
    severity: error

  - id: architecture.model-missing-fromJson
    detection: |
      Class có field nhưng không có factory fromJson
      Trừ khi model thuần internal (không serialize)
    severity: warn
```

### Bước 3: Folder structure check (toàn project, run trên --all)

```yaml
expected_structure:
  - lib/features/<feature>/
      ├── data/          # repositories, data sources
      ├── domain/        # entities, use cases (optional)
      ├── presentation/  # screens, widgets, notifiers
      └── providers/     # Riverpod providers

check_id: architecture.folder-structure
severity: warn
description: Nếu thiếu feature folder → tệp lẻ → khó scale
```

### Bước 4: Apply 4-gate filter (giống check 02)

## Ví dụ Concrete

### TP — setState in feature
```dart
// lib/features/auth/screens/login_screen.dart
class LoginScreen extends StatefulWidget {
  ...
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  void _submit() {
    setState(() => _loading = true);  // ← FLAG
    ...
  }
}
```
→ ERROR confidence 0.95 — phải refactor sang Notifier.

### FP — setState cho AnimationController
```dart
class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() => setState(() {}));  // ← OK, animation render
  }
}
```
→ SUPPRESSED: line nằm trong context AnimationController.

### TP — Dio direct instantiate
```dart
// lib/features/products/data/product_repository.dart
class ProductRepository {
  final dio = Dio();  // ← FLAG: cần inject
}
```
→ ERROR — phải inject qua constructor + Riverpod provider.

### FP — throw trong internal helper
```dart
class OrderRepository {
  Future<Result<Order, AppError>> getOrder(String id) async {
    try {
      final raw = await _fetchRaw(id);
      return Result.ok(_parse(raw));
    } catch (e) {
      return Result.err(AppError.network(e));
    }
  }
  
  Order _parse(Map<String, dynamic> json) {
    if (json['id'] == null) throw FormatException(...);  // ← OK, internal helper
    ...
  }
}
```
→ SUPPRESSED: `_parse` là private, được wrap trong try-catch của public method.

## Anti-pattern em phải tránh

- ❌ Flag setState trong widget util nhỏ (toggle, counter local)
- ❌ Flag throw trong helper private đã được wrap
- ❌ Flag Navigator.push nếu project chưa enable GoRouter
- ❌ Flag autoDispose missing khi @Riverpod(keepAlive: true) là intentional (project có doc nói)

## Output sample

```markdown
## architecture — 3 issues

### [ERROR] no-setstate-feature (1)
- `login_screen.dart:42` setState(() => _loading = true) → dùng LoadingNotifier (conf 0.95)

### [ERROR] dio-no-direct-instantiate (1)
- `product_repository.dart:8` final dio = Dio() → inject via provider (conf 0.98)

### [WARN] notifier-missing-autodispose (1)
- `login_notifier.dart:12` StateNotifierProvider → cân nhắc .autoDispose (conf 0.75)
```
