import { useState } from 'react'
import { GITHUB, RELEASES } from '../constants'
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
      <nav id="nav" className="border-b-2 border-ink sticky top-0 bg-paper z-[100]">
        <div className="max-w-[1200px] mx-auto px-6 flex items-center justify-between h-14">
          <a href="#" className="flex items-center gap-[10px] no-underline text-ink">
            <Logo size={26} />
            <span className="font-mono font-bold text-[12px] tracking-[0.06em] uppercase">
              Claude Usage Monitor
            </span>
          </a>

          {/* Desktop links */}
          <div className="hidden md:flex items-center">
            {navLinks.map(({ label, href, ext }) => (
              <a key={label} href={href}
                target={ext ? '_blank' : undefined}
                rel={ext ? 'noopener noreferrer' : undefined}
                className="font-mono text-[11px] font-bold tracking-[0.1em] uppercase no-underline text-ink px-[18px] h-14 flex items-center border-l border-ink transition-colors duration-100 hover:bg-primary hover:text-white"
              >{label}</a>
            ))}
            <a href={RELEASES} target="_blank" rel="noopener noreferrer"
              className="font-mono text-[11px] font-bold tracking-[0.1em] uppercase no-underline text-white px-5 h-14 flex items-center bg-primary border-l-2 border-primary transition-colors duration-100 hover:bg-ink hover:border-ink"
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
