# Prompt: Maestro Flow Generator

Em generate Maestro YAML flow từ spec text hoặc Figma navigation.

## Input

```
target_screen: LoginPage
goal: Test login happy path + invalid credentials + empty form
app_bundle_id: com.wssv.itg.dev
ui_hierarchy: (output từ scripts/hierarchy.sh)
spec_description: |
  User nhập email + password → submit
  Success → navigate Home
  Wrong password → show error inline
  Empty fields → button disabled
```

## Bước 1: Parse UI hierarchy

Read JSON hierarchy → extract:
- Text content (visible labels)
- Accessibility IDs (resource-id)
- Input fields position
- Button positions

## Bước 2: Generate flow per scenario

### Scenario 1: Happy path
```yaml
- launchApp:
    clearState: true
- assertVisible: "ログイン"
- tapOn:
    id: "emailField"        # hoặc text gần nó
- inputText: "test@example.com"
- tapOn:
    id: "passwordField"
- inputText: "password123"
- tapOn: "送信"
- waitForAnimationToEnd:
    timeout: 5000
- assertVisible: "ホーム"
- takeScreenshot: scenario1-success
```

### Scenario 2: Wrong password
```yaml
- launchApp:
    clearState: true
- inputText: "test@example.com"
- tapOn:
    id: "passwordField"
- inputText: "wrongpassword"
- tapOn: "送信"
- waitForAnimationToEnd
- assertVisible: ".*invalid.*|.*Sai.*"  # error message
- takeScreenshot: scenario2-error
```

### Scenario 3: Empty form
```yaml
- launchApp:
    clearState: true
- tapOn: "送信"
- assertNotVisible: "ホーム"        # KHÔNG navigate
- takeScreenshot: scenario3-empty
```

## Bước 3: Add edge cases

Per project complexity:
- Cold start vs warm start
- Background → foreground (test resume)
- Rotation (portrait → landscape)
- Slow network (combine với Network Link Conditioner)

## Bước 4: Output

Save vào `runtime/maestro-flows/<feature>-<scenario>.yaml`.
Each flow self-contained, runnable independently.

## Quy tắc generation

- ✅ ALWAYS use `clearState: true` cho repeatable test
- ✅ ALWAYS có `assertVisible` để verify state
- ✅ ALWAYS `takeScreenshot` ở moments quan trọng
- ✅ Prefer accessibility ID > text (i18n-safe)
- ❌ KHÔNG hardcode pixel coordinates trừ khi cần
- ❌ KHÔNG dùng `sleep` cứng — dùng `waitForAnimationToEnd` hoặc `waitForVisible`
- ❌ KHÔNG assume order — test independence

## Anti-pattern

```yaml
# ❌ XẤU
- tapOn:
    point: "200,400"           # fragile pixel
- sleep: 3000                   # arbitrary

# ✅ TỐT
- tapOn:
    id: "loginButton"
- waitForVisible:
    id: "homeScreen"
    timeout: 5000
```
