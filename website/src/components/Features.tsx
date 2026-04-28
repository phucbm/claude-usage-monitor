import { useState } from 'react'
import { DISPLAY, INK, MONO, MUTED, PAPER, PRIMARY } from '../constants'
import { FEATURES } from '../data'

export default function Features() {
  const [hov, setHov] = useState<number | null>(null)
  return (
    <section id="features" style={{ borderBottom: `2px solid ${INK}`, padding: '72px 24px' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(10,10,10,0.2)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: DISPLAY, fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: INK }}>WHAT IT DOES</h2>
          <span style={{ fontFamily: MONO, fontSize: 11, color: MUTED, letterSpacing: '0.1em', textTransform: 'uppercase' }}>06 MODULES</span>
        </div>
        <div className="grid-3col" style={{ border: `2px solid ${INK}` }}>
          {FEATURES.map((f, i) => {
            const on = hov === i
            return (
              <div key={f.id}
                onMouseEnter={() => setHov(i)} onMouseLeave={() => setHov(null)}
                style={{ padding: 32, background: on ? INK : 'transparent', borderRight: i % 3 !== 2 ? `1px solid ${INK}` : 'none', borderBottom: i < 3 ? `1px solid ${INK}` : 'none', transition: 'background 0.12s', cursor: 'default' }}
              >
                <p style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, color: PRIMARY, letterSpacing: '0.1em', marginBottom: 12 }}>[{f.id}]</p>
                <p style={{ fontFamily: DISPLAY, fontSize: 15, textTransform: 'uppercase', color: on ? PAPER : INK, marginBottom: 12, transition: 'color 0.12s' }}>{f.label}</p>
                <p style={{ fontFamily: MONO, fontSize: 12, lineHeight: 1.75, color: on ? '#9A9A9A' : '#3A3A3A', transition: 'color 0.12s' }}>{f.body}</p>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
