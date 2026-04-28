import { GITHUB, MONO, MUTED, PRIMARY, RELEASES } from '../constants'
import Logo from './Logo'

export default function Footer() {
  return (
    <footer id="footer" style={{ borderTop: `1px solid rgba(10,10,10,0.15)` }}>
      <div className="footer-inner" style={{ maxWidth: 1200, margin: '0 auto', padding: '22px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <Logo size={18} />
          <span style={{ fontFamily: MONO, fontSize: 10, color: MUTED, letterSpacing: '0.06em' }}>
            © 2026 Claude Usage Monitor &nbsp;·&nbsp; MIT License
          </span>
        </div>
        <div style={{ display: 'flex' }}>
          {[{ label: 'GitHub', href: GITHUB }, { label: 'Releases', href: RELEASES }].map(({ label, href }) => (
            <a key={label} href={href} target="_blank" rel="noopener noreferrer"
              style={{ fontFamily: MONO, fontSize: 10, letterSpacing: '0.08em', textTransform: 'uppercase', color: MUTED, textDecoration: 'none', padding: '0 14px', borderLeft: '1px solid rgba(10,10,10,0.2)', transition: 'color 0.1s' }}
              onMouseEnter={e => { e.currentTarget.style.color = PRIMARY }}
              onMouseLeave={e => { e.currentTarget.style.color = MUTED }}
            >{label}</a>
          ))}
        </div>
      </div>
    </footer>
  )
}
