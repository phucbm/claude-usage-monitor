# Claude Usage Monitor

> Track your Claude.ai usage across multiple accounts right from your Mac menu bar.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos/)

**Inspired by [ClaudeUsageBar](https://github.com/Artzainnn/ClaudeUsageBar) by Artzainnn** — this fork adds multi-account support and a redesigned popup UI.

**Author:** [phucbm](https://github.com/phucbm)

---

## Features

- **Multi-account support** — Add multiple Claude accounts (Work, Personal, etc.), each with its own session and weekly usage bars
- **Active account indicator** — The menu bar icon shows the session usage of the currently active account
- **Color-coded icon** — Spark icon changes color: green (<70%), yellow (<90%), red (≥90%)
- **Smart notifications** — Alerts at 25%, 50%, 75%, 90% session usage for the active account
- **Keyboard shortcut** — Toggle popup with Cmd+U from anywhere
- **Auto-refresh** — Updates every 5 minutes automatically
- **Privacy-first** — All data (cookies, settings) stored locally in UserDefaults
- **Pro plan support** — Shows weekly Sonnet usage for Pro subscribers
- **Menu bar only** — No Dock icon, stays out of your way

## Setup

### Get your session cookie

1. Go to [claude.ai/settings/usage](https://claude.ai/settings/usage)
2. Open Developer Tools (`Cmd+Option+I`) → **Network** tab
3. Refresh the page, click the **"usage"** request
4. Copy the full **"Cookie"** value from the Request Headers

### Add an account

On first launch, you'll see the onboarding screen. Paste your cookie and give the account a label (e.g. "Work"). You can add more accounts any time via **"+ Add Account"**.

## Build from Source

**Requirements:** macOS 12.0+, Xcode Command Line Tools

```bash
cd /path/to/claude-usage-monitor
chmod +x build.sh
./build.sh
```

The app bundle is created at `build/ClaudeUsageMonitor.app`.

**Create a DMG installer:**

```bash
./create_dmg.sh
```

## Project Structure

- `ClaudeUsageMonitor.swift` — Full application source
- `Info.plist` — App bundle metadata
- `build.sh` — Build script (universal binary: arm64 + x86_64)
- `create_dmg.sh` — DMG installer creation

## Key Technologies

- **SwiftUI** — Modern macOS UI framework
- **AppKit** — Menu bar integration
- **Carbon** — Global keyboard shortcut (Cmd+U)
- **NSUserNotification** — System notifications (no permissions needed)
- **UserDefaults** — Local storage for accounts and settings

## Disclaimer

This app uses Claude.ai's internal API endpoints which may change without notice. It is not affiliated with or endorsed by Anthropic. Use at your own risk.

## License

MIT License — see [LICENSE](LICENSE) for details.
