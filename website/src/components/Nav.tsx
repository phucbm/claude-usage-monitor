import { useState } from 'react'
import { GITHUB, RELEASES } from '../constants'
import { useLanguage } from '../contexts/language'
import Logo from './Logo'

export default function Nav() {
  const { t, lang, setLang } = useLanguage()
  const [open, setOpen] = useState(false)
  const navLinks = [
    { label: t.nav.features, href: '#features' },
    { label: t.nav.faq,      href: '#faq' },
    { label: t.nav.github,   href: GITHUB, ext: true },
  ]
  const close = () => setOpen(false)

  return (
    <>
      <nav id="nav" className="border-b-2 border-ink sticky top-0 bg-paper z-[100]">
        <div className="container flex items-center justify-between h-14">
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
            {/* Language switcher */}
            <div className="flex items-center border-l border-ink h-14">
              {(['en', 'vi'] as const).map((l) => (
                <button key={l} onClick={() => setLang(l)}
                  className={`font-mono text-[11px] font-bold tracking-[0.1em] uppercase px-3 h-14 border-0 bg-transparent cursor-pointer transition-colors duration-100 ${lang === l ? 'text-primary' : 'text-ink hover:text-primary'}`}
                >{l.toUpperCase()}</button>
              ))}
            </div>
            <a href={RELEASES} target="_blank" rel="noopener noreferrer"
              className="font-mono text-[11px] font-bold tracking-[0.1em] uppercase no-underline text-white px-5 h-14 flex items-center bg-primary border-l-2 border-primary transition-colors duration-100 hover:bg-ink hover:border-ink"
            >{t.nav.download}</a>
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
        <div className="flex gap-3 px-6 py-3">
          {(['en', 'vi'] as const).map((l) => (
            <button key={l} onClick={() => { setLang(l); close() }}
              className={`font-mono text-[11px] font-bold tracking-[0.1em] uppercase border-0 bg-transparent cursor-pointer ${lang === l ? 'text-primary' : 'text-ink'}`}
            >{l.toUpperCase()}</button>
          ))}
        </div>
        <a href={RELEASES} target="_blank" rel="noopener noreferrer" className="primary" onClick={close}>↓ {t.nav.download} for macOS</a>
      </div>
    </>
  )
}
