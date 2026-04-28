import { DISPLAY, GITHUB, INK, MONO, PAPER, PRIMARY, RELEASES } from '../constants'

export default function CTABanner() {
  return (
    <section id="cta" style={{ borderBottom: `2px solid ${INK}`, padding: '80px 24px', background: PRIMARY }}>
      <div className="cta-inner" style={{ maxWidth: 1200, margin: '0 auto', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 32 }}>
        <div>
          <h2 style={{ fontFamily: DISPLAY, fontSize: 'clamp(40px, 6vw, 80px)', lineHeight: 0.88, letterSpacing: '-0.04em', textTransform: 'uppercase', color: PAPER, marginBottom: 16 }}>
            STOP<br />GUESSING.
          </h2>
          <p style={{ fontFamily: MONO, fontSize: 12, color: 'rgba(242,240,235,0.7)', letterSpacing: '0.08em', textTransform: 'uppercase' }}>
            Free download &nbsp;·&nbsp; No signup &nbsp;·&nbsp; Open source
          </p>
        </div>
        <div className="cta-buttons" style={{ display: 'flex', gap: 10 }}>
          <a href={RELEASES} target="_blank" rel="noopener noreferrer"
            style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, letterSpacing: '0.08em', textTransform: 'uppercase', background: PAPER, color: INK, padding: '18px 32px', textDecoration: 'none', border: `2px solid ${PAPER}`, transition: 'background 0.1s, color 0.1s, border-color 0.1s' }}
            onMouseEnter={e => { e.currentTarget.style.background = INK; e.currentTarget.style.color = PAPER; e.currentTarget.style.borderColor = INK }}
            onMouseLeave={e => { e.currentTarget.style.background = PAPER; e.currentTarget.style.color = INK; e.currentTarget.style.borderColor = PAPER }}
          >↓ Download for macOS</a>
          <a href={GITHUB} target="_blank" rel="noopener noreferrer"
            style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, letterSpacing: '0.08em', textTransform: 'uppercase', background: 'transparent', color: PAPER, padding: '18px 32px', textDecoration: 'none', border: `2px solid rgba(242,240,235,0.5)`, transition: 'border-color 0.1s, background 0.1s' }}
            onMouseEnter={e => { e.currentTarget.style.background = 'rgba(242,240,235,0.12)'; e.currentTarget.style.borderColor = PAPER }}
            onMouseLeave={e => { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.borderColor = 'rgba(242,240,235,0.5)' }}
          >GitHub →</a>
        </div>
      </div>
    </section>
  )
}
