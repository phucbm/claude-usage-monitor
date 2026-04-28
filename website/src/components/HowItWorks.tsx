import { DISPLAY, INK, MONO, PAPER, PRIMARY } from '../constants'

const STEPS = [
  { n: '01', title: 'GET YOUR COOKIE', body: 'Open claude.ai, launch DevTools (Cmd+Option+I), go to Network tab, reload, click any request, copy the full "Cookie" header value.' },
  { n: '02', title: 'ADD AN ACCOUNT',  body: 'Click the menu bar icon, hit "+", paste the cookie, give it a label. Repeat for every Claude account you want to track.' },
  { n: '03', title: 'WATCH THE RINGS', body: 'Rings update automatically. Outer fills with weekly usage, inner fills with session. Reset countdowns shown below each account.' },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" style={{ borderBottom: `2px solid ${INK}`, padding: '72px 24px', background: INK }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(242,240,235,0.12)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: DISPLAY, fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: PAPER }}>HOW IT WORKS</h2>
          <span style={{ fontFamily: MONO, fontSize: 11, color: '#555', letterSpacing: '0.1em', textTransform: 'uppercase' }}>03 STEPS</span>
        </div>
        <div className="grid-3col hiw-grid" style={{ border: '1px solid rgba(242,240,235,0.15)' }}>
          {STEPS.map((s, i) => (
            <div key={s.n} style={{ padding: 40, borderRight: i < 2 ? '1px solid rgba(242,240,235,0.15)' : 'none' }}>
              <p style={{ fontFamily: DISPLAY, fontSize: 64, color: PRIMARY, lineHeight: 1, marginBottom: 20, letterSpacing: '-0.04em' }}>{s.n}</p>
              <p style={{ fontFamily: DISPLAY, fontSize: 15, textTransform: 'uppercase', color: PAPER, marginBottom: 14 }}>{s.title}</p>
              <p style={{ fontFamily: MONO, fontSize: 12, lineHeight: 1.75, color: '#777' }}>{s.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
