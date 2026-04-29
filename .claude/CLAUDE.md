# Claude Usage Monitor

## Commands

### macOS App (Swift)
- Build: `cd app && ./build.sh`
- Hot-reload: `pkill -x ClaudeUsageMonitor; cd app && ./build.sh`
- DMG: `cd app && ./create_dmg.sh`

### Website (React + TypeScript + Vite)
- Dev: `cd website && pnpm dev`
- Build: `cd website && pnpm build`
- Lint: `cd website && pnpm lint`

## Rules
- App source is entirely in `app/Sources/` — `AppDelegate.swift` is the entry point, not a separate `ClaudeUsageMonitor.swift`
- All account data, cookies, and settings live in UserDefaults — no database or backend
- The app uses Claude.ai's internal API; endpoints are undocumented and can break without notice
- Menu bar badges use JetBrains Mono font bundled in `app/Fonts/`
- Panel dimensions are constants at the top of AppDelegate.swift — edit there, not inline
- The website is a standalone Vite app in `website/`; it has no backend and deploys as static files to `website/dist/`
- Tailwind v4 is used in the website — config is inline via `@tailwindcss/vite`, not `tailwind.config.js`

@.claude/docs/architecture.md
