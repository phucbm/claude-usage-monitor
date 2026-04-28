# Claude Usage Monitor

> Track your Claude.ai usage across multiple accounts right from your Mac menu bar.

<img width="1280" height="720" alt="cum-screenshot" src="https://github.com/user-attachments/assets/48391321-1a78-4326-bfb9-5d110e2d39f0" />


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

## Installation

1. Download `ClaudeUsageMonitor-1.0.0.dmg` from the [latest release](../../releases/latest)
2. Double-click to mount
3. Drag `ClaudeUsageMonitor.app` to the Applications folder
4. Eject the DMG
5. Open **ClaudeUsageMonitor** from Applications

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
cd app && ./build.sh
```

The app bundle is created at `app/build/ClaudeUsageMonitor.app`. The script compiles a universal binary (arm64 + x86_64), signs it, and opens the app automatically.

**Hot-reload during development** — kill the running instance, rebuild, and relaunch in one line:

```bash
pkill -x ClaudeUsageMonitor; cd app && ./build.sh
```

**Create a DMG installer:**

```bash
cd app && ./create_dmg.sh
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
- **UserDefaults** — Local storage for accounts and settings

## Disclaimer

This app uses Claude.ai's internal API endpoints which may change without notice. It is not affiliated with or endorsed by Anthropic. Use at your own risk.

**Inspired by [ClaudeUsageBar](https://github.com/Artzainnn/ClaudeUsageBar) by Artzainnn** — this fork adds multi-account support and a redesigned popup UI.

## License

MIT License — see [LICENSE](LICENSE) for details.
