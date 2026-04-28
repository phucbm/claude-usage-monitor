export const en = {
  nav: {
    features: 'Features',
    faq: 'FAQ',
    github: 'GitHub',
    download: 'Download',
  },
  hero: {
    badge: '/// FREE & OPEN SOURCE MACOS APP',
    description: 'Monitor Claude session & weekly usage across <strong>multiple accounts</strong> from your macOS menu bar. Two rings. Always visible. Never surprised by a rate limit again.',
    downloadBtn: '↓ Download .dmg',
    githubBtn: 'View on GitHub →',
    meta: 'Free · MIT License · No account needed',
    mockup: {
      live: '● LIVE',
      personal: 'Personal',
      work: 'Work',
      session: 'Session',
      weekly: 'Weekly',
      resetsIn: 'Resets in',
      resetsMon: 'Resets Mon 9:00 AM',
      updated: 'Updated just now',
      randomize: 'Randomize →',
    },
  },
  ticker: [
    'MULTI-ACCOUNT', 'FREE FOREVER', 'OPEN SOURCE', 'macOS 14+',
    'NATIVE SWIFT', 'ZERO TELEMETRY', '< 5MB', 'SESSION + WEEKLY',
    'MENU BAR NATIVE', 'MIT LICENSE', 'RESET COUNTDOWN',
  ],
  features: {
    heading: 'WHAT IT DOES',
    count: '06 MODULES',
    items: [
      { id: '01', label: 'MULTI-ACCOUNT',    body: 'Track as many Claude accounts as you need — work, personal, team — each with its own ring display and menu bar badge.' },
      { id: '02', label: 'CONCENTRIC RINGS', body: 'Two rings. Outer = weekly limit. Inner = current session. Read both at a glance without opening anything else.' },
      { id: '03', label: 'MENU BAR NATIVE',  body: 'Sits in your macOS menu bar. One click for the full panel. No dock icon, no windows, no friction.' },
      { id: '04', label: 'RESET COUNTDOWN',  body: 'Each account shows exactly when session and weekly limits reset. Plan your work, not your surprises.' },
      { id: '05', label: 'ZERO TELEMETRY',   body: 'Your session cookie and usage data never leave your machine. No analytics, no cloud sync, ever.' },
      { id: '06', label: 'OPEN SOURCE',      body: "Every line of code is on GitHub. MIT licensed. Fork it, audit it, improve it — it's yours." },
    ],
  },
  howItWorks: {
    heading: 'SETUP GUIDE',
    count: '04 STEPS',
    steps: [
      {
        n: '01',
        title: 'OPEN USAGE SETTINGS',
        body: 'Go to claude.ai/settings/usage — this is where Claude shows your current session and weekly usage limits.',
      },
      {
        n: '02',
        title: 'OPEN DEVTOOLS NETWORK TAB',
        body: 'Press Cmd+Option+I to open Developer Tools, then click the Network tab. Make sure "Fetch/XHR" filter is selected.',
      },
      {
        n: '03',
        title: 'COPY THE COOKIE',
        body: 'Refresh the page, click the "usage" request in the list, go to the Headers tab, and copy the full "Cookie" value from Request Headers.',
      },
      {
        n: '04',
        title: 'ADD ACCOUNT TO THE APP',
        body: 'Open Claude Usage Monitor from your menu bar, click "+", give the account a label, paste the cookie, and hit Save Account.',
      },
    ],
  },
  faq: {
    heading: 'FAQ',
    items: [
      { q: 'HOW DO I ADD MY ACCOUNTS?',       a: 'Open the app, click the "+" button, paste your session cookie from claude.ai, and give the account a label. Repeat for each account you want to track.' },
      { q: 'CAN I TRACK MULTIPLE ACCOUNTS?',  a: "Yes — that's a core feature. Add as many accounts as you have (personal, work, team). Each gets its own ring display and can appear independently in the menu bar." },
      { q: 'HOW DO I GET MY SESSION COOKIE?', a: 'Go to claude.ai, open DevTools (Cmd+Option+I), open the Network tab, refresh the page, click any request, and copy the full "Cookie" value from Request Headers.' },
      { q: 'IS MY DATA SAFE?',                a: "Your cookie and usage data are stored locally on your Mac. Nothing is sent to any server — not ours, not anyone's. The source code is public, go verify it." },
      { q: 'WHAT DO THE TWO RINGS MEAN?',     a: 'The outer ring tracks your weekly usage limit. The inner ring tracks your current 5-hour session usage. Both show a countdown to their respective resets.' },
      { q: 'DOES IT WORK WITH CLAUDE CODE?',  a: 'Yes. Claude Code usage counts against the same account limits as claude.ai. The monitor shows the combined figure.' },
      { q: 'IS IT FREE?',                     a: 'Completely free, forever. MIT licensed, open source, no paid tiers, no subscriptions, no hidden anything.' },
    ],
  },
  cta: {
    heading: 'OWN YOUR\nLIMITS.',
    meta: 'Free download · No signup · Open source',
    downloadBtn: '↓ Download for macOS',
    githubBtn: 'GitHub →',
  },
  footer: {
    copyright: '© 2026 Claude Usage Monitor · MIT License',
    releases: 'Releases',
  },
}

export type Translations = typeof en
