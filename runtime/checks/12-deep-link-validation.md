# Check 12 — Deep Link Validation

Verify app routes correctly khi mở qua URL — KHÔNG crash với invalid link.

## Tại sao quan trọng

Deep link bugs là 30% silent crashes của mobile app:
- Wrong route → crash
- Missing param → crash
- Auth required nhưng link không gate → expose data
- Universal Link conflict với in-app navigation

## Quy trình

### Bước 1: Liệt kê deep link routes
Em đọc code → tìm route handlers:
```bash
grep -rn "GoRoute\|onGenerateRoute\|MaterialPageRoute" lib/
grep -rn "appLinks\|openLink\|getInitialLink" lib/
```

### Bước 2: Generate test cases

Per route, 3 test cases:
- **Valid happy path**: `itg://message/123`
- **Missing param**: `itg://message/`
- **Invalid param**: `itg://message/abc-not-numeric`

### Bước 3: Execute test
```bash
for URL in \
  "itg://message/123" \
  "itg://message/" \
  "itg://message/invalid" \
  "itg://nonexistent/path" \
  "itg://" \
; do
  ./runtime/scripts/deep-link.sh "$URL"
  sleep 2
  ./runtime/scripts/screenshot.sh --label "deeplink-$(echo $URL | md5)"
  # Capture logs for crash detection
  ./runtime/scripts/stream-logs.sh --seconds 3 --filter "EXCEPTION|crash"
done
```

### Bước 4: Verify app survives

App phải:
- ✅ Show graceful fallback (not crash)
- ✅ Navigate to correct screen (happy path)
- ✅ Show error UI (invalid link)
- ❌ NOT show stack trace to user
- ❌ NOT silently fail (must show feedback)

### Bước 5: Report

```yaml
deep_link_validation_report:
  app: com.wssv.itg.dev
  tested_urls: 5
  
  results:
    - url: "itg://message/123"
      expected: navigate to message detail
      actual: ✅ Navigated to MessageDetail
      screenshot: deeplink-valid.png
      
    - url: "itg://message/"
      expected: error state / home fallback
      actual: ❌ App crashed (white screen)
      screenshot: deeplink-empty-param.png
      logs:
        - "RangeError: index out of range"
      severity: error
      source: lib/router/deep_link_handler.dart:34
      
    - url: "itg://message/abc-not-numeric"
      expected: validation error
      actual: ⚠️  Navigated but loading forever
      severity: warn
      
    - url: "itg://nonexistent/path"
      expected: 404 fallback
      actual: ✅ Showed home page
      severity: info
      
    - url: "itg://"
      expected: home
      actual: ✅ Showed splash → home
      
  score: 60
  must_fix: 1
  should_fix: 1
```

## Anti-FP

- Cold start vs warm start có thể behave khác → screenshot cả 2
- Universal Link vs custom scheme: test riêng
- Race condition: deep link gọi trước khi auth load → có thể flag wrong navigation

## Combine

Cross-reference với:
- **Static architecture check** — GoRouter type-safe + guards
- **Static i18n check** — error message có localize không
- **Runtime exception check** — log có crash không
