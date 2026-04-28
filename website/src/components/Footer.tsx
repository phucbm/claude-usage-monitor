import { GITHUB, RELEASES } from '../constants'
import Logo from './Logo'

export default function Footer() {
  return (
    <footer id="footer" className="border-t border-ink/15">
      <div className="container py-[22px] flex flex-col md:flex-row justify-between items-start md:items-center gap-3">
        <div className="flex items-center gap-3">
          <Logo size={18} />
          <span className="font-mono text-[10px] text-muted tracking-[0.06em]">
            © 2026 Claude Usage Monitor &nbsp;·&nbsp; MIT License
          </span>
        </div>
        <div className="flex">
          {[{ label: 'GitHub', href: GITHUB }, { label: 'Releases', href: RELEASES }].map(({ label, href }) => (
            <a key={label} href={href} target="_blank" rel="noopener noreferrer"
              className="font-mono text-[10px] tracking-[0.08em] uppercase text-muted no-underline px-[14px] border-l border-ink/20 transition-colors duration-100 hover:text-primary"
            >{label}</a>
          ))}
        </div>
      </div>
    </footer>
  )
}
