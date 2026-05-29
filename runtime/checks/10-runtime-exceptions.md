# Check 10 — Runtime Exceptions (Log Parse)

Catch exception, error, jank xảy ra khi app chạy thật — KHÔNG visible từ code.

## Tại sao quan trọng

Code compile pass ≠ app chạy không lỗi. Common runtime errors:
- `RenderFlex overflowed` — UI vỡ
- `setState() called after dispose()` — memory leak
- `PlatformException` — native bridge fail
- Network 404/500 → silent retry loop
- Frame drops > 16ms → janky scroll

## Quy trình

### Bước 1: Start log capture TRƯỚC khi reproduce
```bash
# Stream logs trong 30s, filter Flutter + exceptions
./runtime/scripts/stream-logs.sh --seconds 30 --bundle com.wssv.itg.dev &
LOG_PID=$!

# Trigger interaction (manual hoặc Maestro flow)
./runtime/scripts/run-flow.sh runtime/maestro-flows/states-coverage-check.yaml

wait $LOG_PID
```

### Bước 2: Parse log → categorize

Categories em detect:
```yaml
categories:
  rendering:
    - RenderFlex overflowed
    - Failed assertion: line ... pos ...
    - A RenderFlex.flex
    
  lifecycle:
    - setState() called after dispose()
    - This widget has been unmounted
    - dispose() called more than once
    
  platform:
    - PlatformException
    - MissingPluginException
    - Method ... not implemented
    
  network:
    - SocketException
    - HandshakeException
    - 5\d\d response
    
  performance:
    - Skipped \d+ frames
    - Frame took \d+ms
    - Memory warning
```

### Bước 3: Map exception → source line

```
[ERROR] flutter: ════ EXCEPTION CAUGHT BY WIDGETS LIBRARY ═════
[ERROR] flutter: The following assertion was thrown building MyWidget:
[ERROR] flutter: A RenderFlex overflowed by 42 pixels on the right.
[ERROR] flutter: ...
[ERROR] flutter: #0      assertion ...
[ERROR] flutter: #2      MyWidget.build (package:app/screens/home.dart:42:18)
                                                          ^^^^^^^^^^^^^^^^^^
                                              → Em map về file:line cụ thể
```

### Bước 4: Anti-FP gates (giống static)

Common FPs:
- Logging warnings (not errors): SUPPRESS
- Known framework noise: filter
- Hot reload artifacts: ignore

### Bước 5: Report

```yaml
runtime_exceptions_report:
  app: com.wssv.itg.dev
  device: iPhone 15 Pro
  duration: 30s
  
  exceptions:
    - category: rendering
      type: RenderFlex.overflowed
      message: "A RenderFlex overflowed by 42 pixels on the right"
      source: lib/page/home/home_page.dart:267
      occurrences: 3
      severity: error
      
    - category: lifecycle
      type: setState_after_dispose
      message: "setState() called after dispose()"
      source: lib/page/auth/login/login_page.dart:99
      occurrences: 1
      severity: error
      note: "Probable cause: setState trong .then() callback sau navigation"
      
    - category: performance
      type: frame_drop
      message: "Skipped 8 frames!"
      occurrences: 12
      severity: warn
      
  score: 45
  
  recommendations:
    - "lib/page/home/home_page.dart:267 — wrap Row trong Expanded/Flexible"
    - "lib/page/auth/login/login_page.dart:99 — check mounted trước setState"
    - "Scroll performance: profile với Flutter DevTools"
```

## Anti-pattern em phải tránh

- ❌ Flag mỗi warning là error
- ❌ Flag log từ third-party package noise
- ❌ Skip frame drops nhỏ < 5 frames (ngưỡng noise)

## Combine với static audit

Khi runtime exception map về file:line, em cross-reference với static report:
- Nếu file đó cũng có MUST_FIX → combined ERROR (high confidence)
- Nếu chỉ runtime báo → standalone runtime issue
- Nếu static báo + runtime không hit → static có thể là FP (giảm confidence)
