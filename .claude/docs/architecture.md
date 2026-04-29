# Architecture

## Two independent components

### macOS App (`app/`)
- **Entry:** `app/Sources/AppDelegate.swift` — `@main`, sets up NSStatusItem, FloatingPanel, AccountsManager, global hotkey
- **Views:** `app/Sources/Views/` — SwiftUI views rendered inside NSHostingController
- **Data model:** `app/Sources/Account.swift`, `app/Sources/AccountsManager.swift` — fetches usage from claude.ai internal API, stores in UserDefaults
- **Theme:** `app/Sources/Theme.swift` — colors and fonts shared across views
- **Build output:** `app/build/ClaudeUsageMonitor.app` — universal binary (arm64 + x86_64)
- **Fonts:** `app/Fonts/JetBrainsMono-*.ttf` — bundled, used for menu bar badges and UI

**Data flow:**
`AccountsManager.fetchAllAccounts()` → HTTP with session cookie → parses usage JSON → updates `Account` model → `refreshMenuBar()` renders badge image → SwiftUI views reflect state via `@Published`

**Key behaviors:**
- Auto-refresh every 300 seconds via `Timer.scheduledTimer`
- Panel position persisted in UserDefaults under `FloatingPanelOrigin` key
- Accessibility permission required for Cmd+U global shortcut (Carbon `RegisterEventHotKey`)

### Website (`website/`)
- **Stack:** React 19, TypeScript 6, Vite 8, Tailwind v4 via `@tailwindcss/vite`
- **Entry:** `website/src/main.tsx` → `App.tsx` — single-page marketing site
- **Components:** `website/src/components/` — Nav, Hero, Ticker, Features, HowItWorks, FAQ, CTABanner, Footer
- **Data:** `website/src/data.ts`, `website/src/constants.ts` — static content, no API calls
- **i18n:** `website/src/locales/` — locale strings
- **Output:** `website/dist/` — static files, already includes a built `index.html`

## Repo layout
```
/
├── app/           # macOS Swift app
│   ├── Sources/   # All Swift source
│   ├── Fonts/     # Bundled JetBrains Mono
│   ├── build.sh   # Compile + sign universal binary
│   └── create_dmg.sh
└── website/       # React marketing site
    ├── src/
    └── dist/      # Built output (committed)
```
