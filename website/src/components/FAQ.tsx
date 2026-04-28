import { DISPLAY, INK, MONO, MUTED, PRIMARY } from '../constants'
import { FAQS } from '../data'

export default function FAQ() {
  return (
    <section id="faq" style={{ borderBottom: `2px solid ${INK}`, padding: '72px 24px' }}>
      <div style={{ maxWidth: 1200, margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 36, borderBottom: '1px solid rgba(10,10,10,0.2)', paddingBottom: 14 }}>
          <h2 style={{ fontFamily: DISPLAY, fontSize: 'clamp(26px, 4vw, 44px)', letterSpacing: '-0.03em', textTransform: 'uppercase', color: INK }}>FAQ</h2>
          <span style={{ fontFamily: MONO, fontSize: 11, color: MUTED, letterSpacing: '0.1em', textTransform: 'uppercase' }}>{String(FAQS.length).padStart(2, '0')} ENTRIES</span>
        </div>
        <div>
          {FAQS.map((faq, i) => (
            <div key={i} className="faq-row">
              <p style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: '0.06em', textTransform: 'uppercase', color: INK, lineHeight: 1.6 }}>
                <span style={{ color: PRIMARY, marginRight: 8 }}>Q/</span>{faq.q}
              </p>
              <p style={{ fontFamily: MONO, fontSize: 13, lineHeight: 1.75, color: '#3A3A3A' }}>{faq.a}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
