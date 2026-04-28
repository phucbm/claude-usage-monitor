import { useEffect, useRef, useState } from 'react'
import './index.css'

const GITHUB = 'https://github.com/phucbm/claude-usage-monitor'
const RELEASES = `${GITHUB}/releases/latest`
const ICON = `${import.meta.env.BASE_URL}icon.png`

// ─── Logo ─────────────────────────────────────────────────────────────────────
function Logo({ size = 32 }: { size?: number }) {
  return <img src={ICON} alt="Claude Usage Monitor" width={size} height={size} style={{ display: 'block', objectFit: 'contain' }} />
}

// ─── Rings mockup ─────────────────────────────────────────────────────────────
function RingsMockup({ sessionPct, weeklyPct }: { sessionPct: number; weeklyPct: number }) {
  const r1 = 70; const r2 = 46; const cx = 100; const cy = 100
  const c1 = 2 * Math.PI * r1; const c2 = 2 * Math.PI * r2
  const [visible, setVisible] = useState(false)
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true) }, { threshold: 0.3 })
    if (ref.current) obs.observe(ref.current)
    return () => obs.disconnect()
  }, [])

  useEffect(() => { setVisible(false); const t = setTimeout(() => setVisible(true), 80); return () => clearTimeout(t) }, [sessionPct, weeklyPct])

  return (
    <svg ref={ref} viewBox="0 0 200 200" width="148" height="148" style={{ display: 'block', flexShrink: 0 }}>
      <circle cx={cx} cy={cy} r={r1} fill="none" stroke="#0A0A0A" strokeWidth="11" strokeOpacity="0.08" />
      <circle cx={cx} cy={cy} r={r2} fill="none" stroke="#0A0A0A" strokeWidth="11" strokeOpacity="0.08" />
      <circle cx={cx} cy={cy} r={r1} fill="none" stroke="#E61919" strokeWidth="11" strokeLinecap="square"
        strokeDasharray={`${(visible ? weeklyPct : 0) * c1} ${c1}`}
        transform={`rotate(-90 ${cx} ${cy})`}
        style={{ transition: 'stroke-dasharray 1.2s cubic-bezier(0.4,0,0.2,1)' }} />
      <circle cx={cx} cy={cy} r={r2} fill="none" stroke="#0A0A0A" strokeWidth="11" strokeLinecap="square"
        strokeDasharray={`${(visible ? sessionPct : 0) * c2} ${c2}`}
        transform={`rotate(-90 ${cx} ${cy})`}
        style={{ transition: 'stroke-dasharray 1.2s cubic-bezier(0.4,0,0.2,1) 0.15s' }} />
    </svg>
  )
}

// ─── Ticker ───────────────────────────────────────────────────────────────────
const TICKER_ITEMS = [
  'MULTI-ACCOUNT', 'FREE FOREVER', 'OPEN SOURCE', 'macOS 14+',
  'NATIVE SWIFT', 'ZERO TELEMETRY', '< 5MB', 'SESSION + WEEKLY',
  'MENU BAR NATIVE', 'MIT LICENSE', 'RESET COUNTDOWN',
]

function Ticker() {
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS]
  return (
    <div style={{ borderTop: '2px solid #0A0A0A', borderBottom: '2px solid #0A0A0A', background: '#0A0A0A', overflow: 'hidden', padding: '10px 0' }}>
      <div className="ticker-track">
        {items.map((item, i) => (
          <span key={i} style={{ color: '#F2F0EB', fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', padding: '0 28px' }}>
            {item}<span style={{ color: '#E61919', marginLeft: 28 }}>///</span>
          </span>
        ))}
      </div>
    </div>
  )
}

// ─── Features data ────────────────────────────────────────────────────────────
const FEATURES = [
  { id: '01', label: 'MULTI-ACCOUNT', body: 'Track as many Claude accounts as you need — work, personal, team — each with its own ring display and menu bar badge.' },
  { id: '02', label: 'CONCENTRIC RINGS', body: 'Two rings. Outer = weekly limit. Inner = current session. Read both at a glance without opening anything else.' },
  { id: '03', label: 'MENU BAR NATIVE', body: 'Sits in your macOS menu bar. One click for the full panel. No dock icon, no windows, no friction.' },
  { id: '04', label: 'RESET COUNTDOWN', body: 'Each account shows exactly when session and weekly limits reset. Plan your work, not your surprises.' },
  { id: '05', label: 'ZERO TELEMETRY', body: 'Your session cookie and usage data never leave your machine. No analytics, no cloud sync, ever.' },
  { id: '06', label: 'OPEN SOURCE', body: "Every line of code is on GitHub. MIT licensed. Fork it, audit it, improve it — it's yours." },
]

// ─── FAQ data ─────────────────────────────────────────────────────────────────
const FAQS = [
  { q: 'HOW DO I ADD MY ACCOUNTS?', a: 'Open the app, click the "+" button, paste your session cookie from claude.ai, and give the account a label. Repeat for each account you want to track.' },
  { q: 'CAN I TRACK MULTIPLE ACCOUNTS?', a: "Yes — that's a core feature. Add as many accounts as you have (personal, work, team). Each account gets its own ring display and can appear independently in the menu bar." },
  { q: 'HOW DO I GET MY SESSION COOKIE?', a: 'Go to claude.ai, open DevTools (Cmd+Option+I), open the Network tab, refresh the page, click any request to claude.ai, and copy the full "Cookie" value from Request Headers.' },
  { q: 'IS MY DATA SAFE?', a: 'Your cookie and usage data are stored locally on your Mac. Nothing is sent to any server — not ours, not anyone\'s. The source code is public, go verify it.' },
  { q: 'WHAT DO THE TWO RINGS MEAN?', a: 'The outer ring tracks your weekly usage limit. The inner ring tracks your current 5-hour session usage. Both include a countdown to their respective resets.' },
  { q: 'DOES IT WORK WITH CLAUDE CODE?', a: 'Yes. Claude Code usage is counted against the same account limits as claude.ai. The monitor shows the combined figure.' },
  { q: 'IS IT FREE?', a: 'Completely free, forever. MIT licensed, open source, no paid tiers, no subscriptions, no hidden anything.' },
]

// ─── Nav ──────────────────────────────────────────────────────────────────────
function Nav() {
  const linkStyle = (base = {}): React.CSSProperties => ({
    fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700,
    letterSpacing: '0.1em', textTransform: 'uppercase', textDecoration: 'none',
    color: '#0A0A0A', padding: '0 18px', height: 56, display: 'flex',
    alignItems: 'center', borderLeft: '1px solid #0A0A0A', transition: 'background 0.1s, color 0.1s',
    ...base,
  })

  return (
    <nav style={{ borderBottom: '2px solid #0A0A0A', position: 'sticky', top: 0, background: '#F2F0EB', zIndex: 100 }}>
      <div style={{ maxWidth: 1200, margin: '0 auto', padding: '0 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 56 }}>
        <a href="#" style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none', color: '#0A0A0A' }}>
          <Logo size={26} />
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: 12, letterSpacing: '0.06em', textTransform: 'uppercase' }}>
            Claude Usage Monitor
          </span>
        </a>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <div className="nav-links" style={{ display: 'flex', alignItems: 'center' }}>
            {[{ label: 'Features', href: '#features' }, { label: 'FAQ', href: '#faq' }, { label: 'GitHub', href: GITHUB, ext: true }].map(({ label, href, ext }) => (
              <a key={label} href={href} target={ext ? '_blank' : undefined} rel={ext ? 'noopener noreferrer' : undefined}
                style={linkStyle()}
                onMouseEnter={e => { e.currentTarget.style.background = '#E61919'; e.currentTarget.style.color = '#fff' }}
                onMouseLeave={e => { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.color = '#0A0A0A' }}
              >{label}</a>
            ))}
          </div>
          <a href={RELEASES} target="_blank" rel="noopener noreferrer"
            className="nav-download"
            style={linkStyle({ background: '#0A0A0A', color: '#F2F0EB', borderLeft: '2px solid #0A0A0A' })}
            onMouseEnter={e => { e.currentTarget.style.background = '#E61919'; e.currentTarget.style.borderColor = '#E61919' }}
            onMouseLeave={e => { e.currentTarget.style.background = '#0A0A0A'; e.currentTarget.style.borderColor = '#0A0A0A' }}
          >Download</a>
        </div>
      </div>
    </nav>
  )
}

// ─── Hero ────────────────────────────────────────────────────────────────────
function Hero() {
  return (
    <section style={{ borderBottom: '2px solid #0A0A0A' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto', padding: '0 24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 0', borderBottom: '1px solid rgba(10,10,10,0.18)', fontFamily: 'JetBrains Mono, monospace', fontSize: 11, letterSpacing: '0.1em', textTransform: 'uppercase', color: '#6B6B6B' }}>
          <span>[ REV 1.0 ]</span>
          <span>macOS 14+ &nbsp;//&nbsp; Apple Silicon + Intel</span>
        </div>
        <div className="grid-2col" style={{ gap: 40, alignItems: 'end', padding: '64px 0 56px' }}>
          <div className="hero-text">
            <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase', color: '#E61919', marginBottom: 18 }}>
              /// FREE &amp; OPEN SOURCE MACOS APP
            </p>
            <h1 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(56px, 9vw, 116px)', lineHeight: 0.88, letterSpacing: '-0.04em', textTransform: 'uppercase', color: '#0A0A0A', marginBottom: 32 }}>
              KNOW<br />YOUR<br />LIMITS.
            </h1>
            <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 14, lineHeight: 1.75, color: '#3A3A3A', maxWidth: 460, marginBottom: 40 }}>
              Monitor Claude session &amp; weekly usage across <strong>multiple accounts</strong> from your macOS menu bar. Two rings. Always visible. Never surprised by a rate limit again.
            </p>
            <div style={{ display: 'flex', flexWrap: 'wrap' }}>
              <a href={RELEASES} target="_blank" rel="noopener noreferrer"
                className="btn-primary" style={{ padding: '15px 32px', fontSize: 12 }}>
                ↓ Download .dmg
              </a>
              <a href={GITHUB} target="_blank" rel="noopener noreferrer"
                className="btn-ghost" style={{ padding: '15px 32px', fontSize: 12, borderLeft: 'none' }}>
                View on GitHub →
              </a>
            </div>
            <p style={{ marginTop: 14, fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#6B6B6B', letterSpacing: '0.06em' }}>
              Free &nbsp;·&nbsp; MIT License &nbsp;·&nbsp; No account needed
            </p>
          </div>
          <div className="hero-logo-box" style={{ border: '2px solid #0A0A0A', width: 200, height: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, justifySelf: 'end' }}>
            <Logo size={144} />
          </div>
        </div>
      </div>
    </section>
  )
}

// ─── App Mockup ───────────────────────────────────────────────────────────────
function AppMockup() {
  const [s, setS] = useState(0.67)
  const [w, setW] = useState(0.42)
  const randomize = () => { setS(+(Math.random() * 0.88 + 0.06).toFixed(2)); setW(+(Math.random() * 0.88 + 0.06).toFixed(2)) }

  return (
    <section style={{ borderBottom: '2px solid #0A0A0A', padding: '72px 24px' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div className="grid-2col" style={{ gap: 0, border: '2px solid #0A0A0A' }}>
          <div className="mockup-left" style={{ borderRight: '2px solid #0A0A0A', padding: '48px 48px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase', color: '#E61919', marginBottom: 16 }}>
                [ APP PREVIEW ]
              </p>
              <h2 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(30px, 4vw, 52px)', lineHeight: 0.93, letterSpacing: '-0.03em', textTransform: 'uppercase', color: '#0A0A0A', marginBottom: 24 }}>
                TWO RINGS.<br />ALL THE<br />CONTEXT.
              </h2>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, lineHeight: 1.75, color: '#3A3A3A', maxWidth: 320 }}>
                Outer ring = weekly limit. Inner ring = current session. Reset time shown inline. No reading required.
              </p>
            </div>
            <button onClick={randomize} className="btn-ghost" style={{ padding: '10px 20px', fontSize: 11, marginTop: 32, alignSelf: 'flex-start', cursor: 'pointer' }}>
              Randomize data →
            </button>
          </div>
          <div style={{ padding: 48, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <div style={{ border: '2px solid #0A0A0A', background: '#fff', width: '100%', maxWidth: 340 }}>
              <div style={{ borderBottom: '2px solid #0A0A0A', padding: '9px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Claude Usage Monitor</span>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#22c55e', fontWeight: 700 }}>● LIVE</span>
              </div>
              <div style={{ borderBottom: '1px solid rgba(10,10,10,0.12)', padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700 }}>Personal</span>
                <span style={{ width: 8, height: 8, background: '#22c55e', border: '1px solid rgba(10,10,10,0.3)', display: 'inline-block' }}></span>
              </div>
              <div style={{ padding: '20px 16px', display: 'flex', gap: 16, alignItems: 'center' }}>
                <RingsMockup sessionPct={s} weeklyPct={w} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Session</p>
                  <p style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 30, color: '#0A0A0A', lineHeight: 1, marginBottom: 3 }}>{Math.round(s * 100)}%</p>
                  <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B', marginBottom: 14 }}>Resets in 2h 14m</p>
                  <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Weekly</p>
                  <p style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 30, color: '#E61919', lineHeight: 1, marginBottom: 3 }}>{Math.round(w * 100)}%</p>
                  <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B' }}>Resets Mon 9:00 AM</p>
                </div>
              </div>
              <div style={{ borderTop: '1px solid rgba(10,10,10,0.12)', padding: '8px 16px', display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B' }}>Updated just now</span>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9, color: '#6B6B6B' }}>github.com/phucbm</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

// ─── Features ─────────────────────────────────────────────────────────────────
function Features() {
  const [hovered, setHovered] = useState<number | null>(null)
  return (
    <section id="features" style={{ borderBottom: '2px solid #0A0A0A', padding: '72px 24px' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(10,10,10,0.2)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: '#0A0A0A' }}>WHAT IT DOES</h2>
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#6B6B6B', letterSpacing: '0.1em', textTransform: 'uppercase' }}>06 MODULES</span>
        </div>
        <div className="grid-3col" style={{ gap: 0, border: '2px solid #0A0A0A' }}>
          {FEATURES.map((f, i) => {
            const isHov = hovered === i
            return (
              <div key={f.id}
                onMouseEnter={() => setHovered(i)}
                onMouseLeave={() => setHovered(null)}
                style={{
                  padding: 32,
                  background: isHov ? '#0A0A0A' : 'transparent',
                  borderRight: i % 3 !== 2 ? '1px solid #0A0A0A' : 'none',
                  borderBottom: i < 3 ? '1px solid #0A0A0A' : 'none',
                  transition: 'background 0.12s',
                  cursor: 'default',
                }}
              >
                <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, color: '#E61919', letterSpacing: '0.1em', marginBottom: 12 }}>[{f.id}]</p>
                <p style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 15, letterSpacing: '-0.01em', textTransform: 'uppercase', color: isHov ? '#F2F0EB' : '#0A0A0A', marginBottom: 12, transition: 'color 0.12s' }}>{f.label}</p>
                <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, lineHeight: 1.75, color: isHov ? '#9A9A9A' : '#3A3A3A', transition: 'color 0.12s' }}>{f.body}</p>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}

// ─── How it works ─────────────────────────────────────────────────────────────
function HowItWorks() {
  const steps = [
    { n: '01', title: 'GET YOUR COOKIE', body: 'Open claude.ai, launch DevTools (Cmd+Option+I), go to Network tab, reload, click any request, copy the full "Cookie" header value.' },
    { n: '02', title: 'ADD AN ACCOUNT', body: 'Click the menu bar icon, hit "+", paste the cookie, give it a label. Repeat for every Claude account you want to track.' },
    { n: '03', title: 'WATCH THE RINGS', body: 'Rings update automatically. Outer fills with weekly usage, inner fills with session. Reset countdowns shown below each account.' },
  ]
  return (
    <section style={{ borderBottom: '2px solid #0A0A0A', padding: '72px 24px', background: '#0A0A0A' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(242,240,235,0.12)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: '#F2F0EB' }}>HOW IT WORKS</h2>
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#555', letterSpacing: '0.1em', textTransform: 'uppercase' }}>03 STEPS</span>
        </div>
        <div className="grid-3col" style={{ border: '1px solid rgba(242,240,235,0.15)' }}>
          {steps.map((s, i) => (
            <div key={s.n} style={{ padding: 40, borderRight: i < 2 ? '1px solid rgba(242,240,235,0.15)' : 'none' }}>
              <p style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 64, color: '#E61919', lineHeight: 1, marginBottom: 20, letterSpacing: '-0.04em' }}>{s.n}</p>
              <p style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 15, letterSpacing: '-0.01em', textTransform: 'uppercase', color: '#F2F0EB', marginBottom: 14 }}>{s.title}</p>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, lineHeight: 1.75, color: '#777' }}>{s.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

// ─── FAQ ─────────────────────────────────────────────────────────────────────
function FAQ() {
  return (
    <section id="faq" style={{ borderBottom: '2px solid #0A0A0A', padding: '72px 24px' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(10,10,10,0.2)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: '#0A0A0A' }}>FAQ</h2>
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: '#6B6B6B', letterSpacing: '0.1em', textTransform: 'uppercase' }}>{String(FAQS.length).padStart(2, '0')} ENTRIES</span>
        </div>
        <div>
          {FAQS.map((faq, i) => (
            <div key={i} className="faq-item" style={{ borderTop: i === 0 ? '1px solid #0A0A0A' : 'none', borderBottom: '1px solid #0A0A0A', padding: '22px 22px 22px 18px', display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: 32 }}>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, fontWeight: 700, letterSpacing: '0.06em', textTransform: 'uppercase', color: '#0A0A0A', lineHeight: 1.6 }}>
                <span style={{ color: '#E61919', marginRight: 8 }}>Q/</span>{faq.q}
              </p>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 13, lineHeight: 1.75, color: '#3A3A3A' }}>{faq.a}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

// ─── CTA Banner ───────────────────────────────────────────────────────────────
function CTABanner() {
  return (
    <section style={{ borderBottom: '2px solid #0A0A0A', padding: '80px 24px', background: '#E61919' }}>
      <div className="cta-inner" style={{ maxWidth: 1200, margin: '0 auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 32, flexWrap: 'wrap' }}>
        <div>
          <h2 style={{ fontFamily: 'Archivo Black, sans-serif', fontSize: 'clamp(40px, 6vw, 80px)', lineHeight: 0.88, letterSpacing: '-0.04em', textTransform: 'uppercase', color: '#F2F0EB', marginBottom: 16 }}>
            STOP<br />GUESSING.
          </h2>
          <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, color: 'rgba(242,240,235,0.7)', letterSpacing: '0.08em', textTransform: 'uppercase' }}>
            Free download &nbsp;·&nbsp; No signup &nbsp;·&nbsp; Open source
          </p>
        </div>
        <div style={{ display: 'flex' }}>
          <a href={RELEASES} target="_blank" rel="noopener noreferrer"
            style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: 12, letterSpacing: '0.08em', textTransform: 'uppercase', background: '#F2F0EB', color: '#0A0A0A', padding: '18px 32px', textDecoration: 'none', border: '2px solid #F2F0EB', transition: 'background 0.1s, color 0.1s, border-color 0.1s' }}
            onMouseEnter={e => { e.currentTarget.style.background = '#0A0A0A'; e.currentTarget.style.color = '#F2F0EB'; e.currentTarget.style.borderColor = '#0A0A0A' }}
            onMouseLeave={e => { e.currentTarget.style.background = '#F2F0EB'; e.currentTarget.style.color = '#0A0A0A'; e.currentTarget.style.borderColor = '#F2F0EB' }}
          >↓ Download for macOS</a>
          <a href={GITHUB} target="_blank" rel="noopener noreferrer"
            style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: 12, letterSpacing: '0.08em', textTransform: 'uppercase', background: 'transparent', color: '#F2F0EB', padding: '18px 32px', textDecoration: 'none', border: '2px solid rgba(242,240,235,0.5)', borderLeft: 'none', transition: 'border-color 0.1s, background 0.1s' }}
            onMouseEnter={e => { e.currentTarget.style.background = 'rgba(242,240,235,0.12)'; e.currentTarget.style.borderColor = '#F2F0EB' }}
            onMouseLeave={e => { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.borderColor = 'rgba(242,240,235,0.5)' }}
          >GitHub →</a>
        </div>
      </div>
    </section>
  )
}

// ─── Footer ───────────────────────────────────────────────────────────────────
function Footer() {
  return (
    <footer className="footer-inner" style={{ padding: '22px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 12, maxWidth: 1200, margin: '0 auto', width: '100%' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <Logo size={18} />
        <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: '#6B6B6B', letterSpacing: '0.06em' }}>
          © 2026 Claude Usage Monitor &nbsp;·&nbsp; MIT License
        </span>
      </div>
      <div style={{ display: 'flex' }}>
        {[{ label: 'GitHub', href: GITHUB }, { label: 'Releases', href: RELEASES }].map(({ label, href }) => (
          <a key={label} href={href} target="_blank" rel="noopener noreferrer"
            style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, letterSpacing: '0.08em', textTransform: 'uppercase', color: '#6B6B6B', textDecoration: 'none', padding: '0 14px', borderLeft: '1px solid rgba(10,10,10,0.2)', transition: 'color 0.1s' }}
            onMouseEnter={e => { e.currentTarget.style.color = '#E61919' }}
            onMouseLeave={e => { e.currentTarget.style.color = '#6B6B6B' }}
          >{label}</a>
        ))}
      </div>
    </footer>
  )
}

// ─── Root ─────────────────────────────────────────────────────────────────────
export default function App() {
  return (
    <>
      <Nav />
      <Hero />
      <Ticker />
      <AppMockup />
      <Features />
      <HowItWorks />
      <FAQ />
      <CTABanner />
      <Footer />
    </>
  )
}
