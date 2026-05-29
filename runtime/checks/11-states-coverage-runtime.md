# Check 11 — States Coverage (Runtime Verification)

Verify app thật sự render đúng `loading / error / empty / success` state — KHÔNG chỉ "code có handle case".

## Tại sao quan trọng

Static check 06 (states-coverage) đọc widget tree, đoán có handle state không. Runtime check **TRIGGER ACTUAL state** và screenshot.

Common bugs static miss:
- `loading` state có nhưng spinner sai size/màu
- `empty` state render xong nhưng overlap với content cũ
- `error` state có nhưng button "Retry" không hoạt động
- `success` flash 100ms rồi navigate → user không kịp thấy

## Quy trình

### Bước 1: Loading state
```bash
# Trigger network slow → force loading state hiện lâu
./runtime/scripts/launch-app.sh com.wssv.itg.dev --cold

# Screenshot 100ms sau launch (catch splash + loading)
sleep 0.5
./runtime/scripts/screenshot.sh --label state-loading-1

sleep 1
./runtime/scripts/screenshot.sh --label state-loading-2
```

Em phân tích vision:
- Có spinner/skeleton không?
- Spinner đúng color/size?
- Có placeholder content (lorem ipsum) hiện không?

### Bước 2: Empty state
```bash
# Maestro flow: search keyword không có result
cat > /tmp/empty-flow.yaml <<EOF
appId: com.wssv.itg.dev
---
- launchApp
- tapOn:
    id: "searchField"
- inputText: "xyzqwertynomatch12345"
- takeScreenshot: state-empty
EOF

./runtime/scripts/run-flow.sh /tmp/empty-flow.yaml
```

Phân tích:
- Có illustration/icon không?
- Có message giải thích (không phải "No data")?
- Có CTA "Try again" / "Browse" gì không?

### Bước 3: Error state
```bash
# Đặt network offline (simctl không direct support, dùng Network Link Conditioner hoặc proxy)
# Workaround: kill backend / kill network on dev machine
# Hoặc dùng app's debug menu nếu có

./runtime/scripts/screenshot.sh --label state-error
```

Phân tích:
- Error message user-friendly KHÔNG phải stack trace?
- Có nút "Retry" hiển thị?
- Icon/illustration phù hợp?

### Bước 4: Success state
```bash
# Trigger action thành công (e.g., login với credentials thật)
./runtime/scripts/run-flow.sh runtime/maestro-flows/login-success.yaml

# Screenshot navigation đích
```

### Bước 5: Cross-reference với static report

```yaml
states_coverage_runtime_report:
  screen: LoginPage
  
  states_checked:
    loading:
      detected: yes
      screenshot: state-loading-2.png
      duration_ms: 1200
      issues:
        - "Spinner màu tím khác design (designed: brand purple)"
    
    empty:
      detected: no
      reason: "Không trigger được — KHÔNG có search field empty case"
      static_says: "code có handle empty"
      runtime_says: "không reach state"
      severity: info
      note: "Có thể anh phải write test case để trigger"
    
    error:
      detected: yes
      screenshot: state-error.png
      issues:
        - "Hiển thị raw error string 'TimeoutException after 0:00:30.000000'"
        - "User-unfriendly — nên 'Kết nối chậm, thử lại'"
        - "Không có nút Retry visible"
      severity: error
    
    success:
      detected: yes
      screenshot: state-success.png
      issues: []
  
  score: 60
```

## Output

Bao gồm screenshots inline để anh review nhanh visually.

## Combine với check 06 (static states-coverage)

| Static says | Runtime says | Verdict |
|---|---|---|
| ✅ Code handles | ✅ Renders correct | PASS |
| ✅ Code handles | ❌ Render glitch | RUNTIME bug — file:line investigation |
| ❌ Missing handler | ❌ State crashes app | CONFIRMED MUST FIX |
| ❌ Missing handler | ✅ Looks OK | Possibly dead path — check trigger condition |
| ✅ Code handles | ⚠️ Cannot trigger | INFO — recommend test case |
