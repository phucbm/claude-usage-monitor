import { useEffect, useState } from 'react'
import { DISPLAY, GITHUB, INK, MONO, MUTED, PRIMARY, RELEASES } from '../constants'
import RingsMockup from './RingsMockup'

function randomTime() {
  const h = Math.floor(Math.random() * 5)
  const m = Math.floor(Math.random() * 60)
  return h > 0 ? `${h}h${m > 0 ? `${m}m` : ''}` : `${m}m`
}

export default function Hero() {
  const [s, setS] = useState(0.67)
  const [w, setW] = useState(0.42)
  const [t, setT] = useState('1h30m')
  const [s2, setS2] = useState(0.31)
  const [w2, setW2] = useState(0.78)
  const [t2, setT2] = useState('3h05m')

  const randomize = () => {
    setS(+(Math.random() * 0.88 + 0.06).toFixed(2)); setW(+(Math.random() * 0.88 + 0.06).toFixed(2)); setT(randomTime())
    setS2(+(Math.random() * 0.88 + 0.06).toFixed(2)); setW2(+(Math.random() * 0.88 + 0.06).toFixed(2)); setT2(randomTime())
  }

  useEffect(() => { const id = setInterval(randomize, 2000); return () => clearInterval(id) }, [])

  return (
    <section id="hero" style={{ borderBottom: `2px solid ${INK}` }}>
      <div style={{ maxWidth: 1200, margin: '0 auto', padding: '0 24px' }}>

        <div className="hero-grid">
          <div className="hero-text">
            <p style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: '0.15em', textTransform: 'uppercase', color: PRIMARY, marginBottom: 18 }}>
              /// FREE &amp; OPEN SOURCE MACOS APP
            </p>
            <h1 style={{ fontFamily: DISPLAY, fontSize: 'clamp(56px, 9vw, 116px)', lineHeight: 0.88, letterSpacing: '-0.04em', textTransform: 'uppercase', color: INK, marginBottom: 32 }}>
              CLAUDE<br />USAGE<br /><span style={{ color: PRIMARY }}>MONITOR</span>
            </h1>
            <p style={{ fontFamily: MONO, fontSize: 14, lineHeight: 1.75, color: '#3A3A3A', maxWidth: 460, marginBottom: 40 }}>
              Monitor Claude session &amp; weekly usage across <strong>multiple accounts</strong> from your macOS menu bar. Two rings. Always visible. Never surprised by a rate limit again.
            </p>
            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
              <a href={RELEASES} target="_blank" rel="noopener noreferrer" className="btn-primary" style={{ padding: '15px 32px', fontSize: 12 }}>
                ↓ Download .dmg
              </a>
              <a href={GITHUB} target="_blank" rel="noopener noreferrer" className="btn-ghost" style={{ padding: '15px 32px', fontSize: 12 }}>
                View on GitHub →
              </a>
            </div>
            <p style={{ marginTop: 14, fontFamily: MONO, fontSize: 11, color: MUTED, letterSpacing: '0.06em' }}>
              Free &nbsp;·&nbsp; MIT License &nbsp;·&nbsp; No account needed
            </p>
          </div>

          <div className="hero-logo-box" style={{ justifySelf: 'end', flexShrink: 0 }}>
            <div style={{ border: `2px solid ${INK}`, background: '#fff', width: '100%', maxWidth: 340 }}>
              <div style={{ borderBottom: `2px solid ${INK}`, padding: '9px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontFamily: MONO, fontSize: 10, fontWeight: 700, letterSpacing: '0.08em', textTransform: 'uppercase' }}>Claude Usage Monitor</span>
                <span style={{ fontFamily: MONO, fontSize: 10, color: '#22c55e', fontWeight: 700 }}>● LIVE</span>
              </div>
              <div style={{ borderBottom: '1px solid rgba(10,10,10,0.12)', padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700 }}>Personal</span>
                <span style={{ width: 8, height: 8, background: '#22c55e', border: '1px solid rgba(10,10,10,0.3)', display: 'inline-block' }} />
              </div>
              <div style={{ padding: '20px 16px', display: 'flex', gap: 16, alignItems: 'center' }}>
                <RingsMockup sessionPct={s} weeklyPct={w} resetTime={t} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Session</p>
                  <p style={{ fontFamily: DISPLAY, fontSize: 30, color: INK, lineHeight: 1, marginBottom: 3 }}>{Math.round(s * 100)}%</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, marginBottom: 14 }}>Resets in {t}</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Weekly</p>
                  <p style={{ fontFamily: DISPLAY, fontSize: 30, color: PRIMARY, lineHeight: 1, marginBottom: 3 }}>{Math.round(w * 100)}%</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED }}>Resets Mon 9:00 AM</p>
                </div>
              </div>
              <div style={{ borderTop: '1px solid rgba(10,10,10,0.12)', borderBottom: '1px solid rgba(10,10,10,0.12)', padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700 }}>Work</span>
                <span style={{ width: 8, height: 8, background: '#22c55e', border: '1px solid rgba(10,10,10,0.3)', display: 'inline-block' }} />
              </div>
              <div style={{ padding: '20px 16px', display: 'flex', gap: 16, alignItems: 'center' }}>
                <RingsMockup sessionPct={s2} weeklyPct={w2} resetTime={t2} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Session</p>
                  <p style={{ fontFamily: DISPLAY, fontSize: 30, color: INK, lineHeight: 1, marginBottom: 3 }}>{Math.round(s2 * 100)}%</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, marginBottom: 14 }}>Resets in {t2}</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED, letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 3 }}>Weekly</p>
                  <p style={{ fontFamily: DISPLAY, fontSize: 30, color: PRIMARY, lineHeight: 1, marginBottom: 3 }}>{Math.round(w2 * 100)}%</p>
                  <p style={{ fontFamily: MONO, fontSize: 9, color: MUTED }}>Resets Mon 9:00 AM</p>
                </div>
              </div>
              <div style={{ borderTop: '1px solid rgba(10,10,10,0.12)', padding: '8px 16px', display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ fontFamily: MONO, fontSize: 9, color: MUTED }}>Updated just now</span>
                <button onClick={randomize} style={{ fontFamily: MONO, fontSize: 9, color: PRIMARY, background: 'none', border: 'none', cursor: 'pointer', padding: 0, letterSpacing: '0.06em' }}>Randomize →</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
