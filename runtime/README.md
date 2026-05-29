# Runtime Audit Layer

Skill leo từ **static code analysis** lên **runtime app interaction**. Em thao tác trực tiếp trên iOS Simulator / Android Emulator anh đang mở.

## Capabilities

| Capability | Tool | Install? |
|---|---|---|
| Screenshot | `xcrun simctl` / `adb` | ❌ Built-in |
| Launch / terminate app | `xcrun simctl launch` | ❌ |
| Deep link test | `xcrun simctl openurl` | ❌ |
| Push notification fake | `xcrun simctl push` | ❌ |
| Stream logs / exceptions | `log stream` / `logcat` | ❌ |
| Status bar override | `xcrun simctl status_bar` | ❌ |
| Record video | `xcrun simctl io recordVideo` | ❌ |
| **Tap / Swipe / Type** | **Maestro** | ✅ 1 command |
| **UI hierarchy dump** | **Maestro** | ✅ |
| **Visual compare với Figma** | Vision + Figma MCP | ❌ |

## Install

```bash
# Maestro (1 lần)
curl -Ls "https://get.maestro.mobile.dev" | bash
source ~/.zshrc
maestro --version    # verify
```

iOS Simulator dùng `xcrun simctl` (đã có trong Xcode). Android dùng `adb` (có trong Android SDK).

## Scripts (all in `scripts/`)

| Script | Purpose |
|---|---|
| `device-list.sh` | List booted devices (iOS + Android) |
| `screenshot.sh` | Capture screen state |
| `launch-app.sh <bundle>` | Cold/warm launch app |
| `hierarchy.sh` | Dump UI accessibility tree |
| `tap.sh <text|--id|--xy>` | Tap element |
| `type-text.sh <text>` | Type into focused field |
| `deep-link.sh <url>` | Open URL scheme |
| `push-notification.sh <bundle> <payload>` | Fake APNs payload |
| `stream-logs.sh --seconds N` | Capture Flutter logs |
| `status-bar.sh apple|low-battery|bad-signal|clear` | Override status bar |
| `record-video.sh --seconds N` | Record screen |
| `run-flow.sh <flow.yaml>` | Run Maestro flow + screenshot |

## Maestro Flows (`maestro-flows/`)

Template + ready-to-use:
- `_template.yaml` — pattern chuẩn
- `states-coverage-check.yaml` — navigate qua loading/error/empty/success
- `visual-regression-baseline.yaml` — screenshot mọi screen for baseline
- `deep-link-validation.yaml` — test URL routing edge cases

## Runtime Checks (`checks/`)

Khác static checks: chạy trên app THẬT, không đọc code.

| Check | Purpose |
|---|---|
| `09-visual-figma-drift.md` | Screenshot vs Figma diff (vision-based) |
| `10-runtime-exceptions.md` | Parse log → catch RenderFlex overflow, setState after dispose, PlatformException |
| `11-states-coverage-runtime.md` | Trigger thật loading/error/empty state, verify render |
| `12-deep-link-validation.md` | Test URL routing không crash |

## Prompts (`prompts/`)

LLM behavior cho runtime tasks:
- `visual-compare.md` — compare screenshot vs Figma spec
- `log-analyzer.md` — parse Flutter log → map về source line
- `maestro-flow-generator.md` — generate YAML từ goal description

## Artifacts

Run output (gitignored, local only):
```
~/.flutter-auto-test/artifacts/<YYYY-MM-DD>/
├── screenshot-XXXXXX.png
├── hierarchy-XXXXXX.json
├── logs-XXXXXX.txt
├── flow-states-coverage-XXXXXX/
│   ├── 01-cold-launch-loading.png
│   ├── 02-loaded-state.png
│   └── ...
└── video-XXXXXX.mp4
```

## Workflow End-to-End

```bash
# 1. Pre-flight
./runtime/scripts/device-list.sh

# 2. Clean baseline
./runtime/scripts/status-bar.sh apple

# 3. Cold launch
./runtime/scripts/launch-app.sh com.wssv.itg.dev --cold
sleep 3

# 4. Capture initial state
SS=$(./runtime/scripts/screenshot.sh --label "initial")

# 5. Start log capture (background)
./runtime/scripts/stream-logs.sh --seconds 30 --bundle com.wssv.itg.dev &

# 6. Run interactive flow
./runtime/scripts/run-flow.sh runtime/maestro-flows/states-coverage-check.yaml

# 7. Test edge cases
./runtime/scripts/deep-link.sh "itg://message/123"
sleep 2
./runtime/scripts/screenshot.sh --label "deeplink-target"

./runtime/scripts/push-notification.sh com.wssv.itg.dev '{"aps":{"alert":"Test notification"}}'
sleep 2
./runtime/scripts/screenshot.sh --label "after-push"

# 8. Cleanup
./runtime/scripts/status-bar.sh clear
```

## Em (Claude) flow

Khi anh gõ `/flutter-auto-test --runtime <screen>`:
1. Em chạy `device-list.sh` → confirm có sim booted
2. Em chạy `screenshot.sh` → có ảnh state hiện tại
3. Em đọc ảnh bằng vision → phân tích UI
4. Nếu có Figma URL → call MCP get_design_context → diff
5. Em generate Maestro flow phù hợp → save vào maestro-flows/
6. Em chạy `run-flow.sh` → capture states
7. Em parse logs → tìm exception
8. Em aggregate report markdown với screenshots inline
9. Save vào `reports/<date>/<project>/<screen>-runtime.md`

## Limitations

- ❌ Network simulation (slow/offline) cần Network Link Conditioner setup tay
- ❌ Real device cần USB connection + Developer Mode
- ❌ Android push notification cần Firebase CLI (không có simctl tương đương)
- ❌ Em ước lượng pixel ~5% error (vision-based, not exact)
- ❌ Animation state khó capture đúng moment
