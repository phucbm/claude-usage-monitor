import { useState } from 'react'
import { GITHUB, INK, MONO, PAPER, PRIMARY, RELEASES } from '../constants'
import Logo from './Logo'

export default function Nav() {
  const [open, setOpen] = useState(false)
  const navLinks = [
    { label: 'Features', href: '#features' },
    { label: 'FAQ',      href: '#faq' },
    { label: 'GitHub',   href: GITHUB, ext: true },
  ]
  const close = () => setOpen(false)

  return (
    <>
      <nav id="nav" style={{ borderBottom: `2px solid ${INK}`, position: 'sticky', top: 0, background: PAPER, zIndex: 100 }}>
        <div style={{ maxWidth: 1200, margin: '0 auto', padding: '0 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 56 }}>
          <a href="#" style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none', color: INK }}>
            <Logo size={26} />
            <span style={{ fontFamily: MONO, fontWeight: 700, fontSize: 12, letterSpacing: '0.06em', textTransform: 'uppercase' }}>
              Claude Usage Monitor
            </span>
          </a>

          {/* Desktop links */}
          <div className="nav-links" style={{ display: 'flex', alignItems: 'center' }}>
            {navLinks.map(({ label, href, ext }) => (
              <a key={label} href={href} target={ext ? '_blank' : undefined} rel={ext ? 'noopener noreferrer' : undefined}
                style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', textDecoration: 'none', color: INK, padding: '0 18px', height: 56, display: 'flex', alignItems: 'center', borderLeft: `1px solid ${INK}`, transition: 'background 0.1s, color 0.1s' }}
                onMouseEnter={e => { e.currentTarget.style.background = PRIMARY; e.currentTarget.style.color = '#fff' }}
                onMouseLeave={e => { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.color = INK }}
              >{label}</a>
            ))}
            <a href={RELEASES} target="_blank" rel="noopener noreferrer"
              style={{ fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: '0.1em', textTransform: 'uppercase', textDecoration: 'none', color: '#fff', padding: '0 20px', height: 56, display: 'flex', alignItems: 'center', background: PRIMARY, borderLeft: `2px solid ${PRIMARY}`, transition: 'background 0.1s' }}
              onMouseEnter={e => { e.currentTarget.style.background = INK; e.currentTarget.style.borderColor = INK }}
              onMouseLeave={e => { e.currentTarget.style.background = PRIMARY; e.currentTarget.style.borderColor = PRIMARY }}
            >Download</a>
          </div>

          {/* Hamburger */}
          <button className={`hamburger${open ? ' open' : ''}`} onClick={() => setOpen(o => !o)} aria-label="Menu">
            <span /><span /><span />
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      <div className={`mobile-menu${open ? ' open' : ''}`}>
        {navLinks.map(({ label, href, ext }) => (
          <a key={label} href={href} target={ext ? '_blank' : undefined} rel={ext ? 'noopener noreferrer' : undefined} onClick={close}>{label}</a>
        ))}
        <a href={RELEASES} target="_blank" rel="noopener noreferrer" className="primary" onClick={close}>↓ Download for macOS</a>
      </div>
    </>
  )
}
