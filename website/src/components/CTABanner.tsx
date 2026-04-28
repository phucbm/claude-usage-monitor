import { GITHUB, RELEASES } from '../constants'
import { useLanguage } from '../contexts/language'

export default function CTABanner() {
  const { t } = useLanguage()
  const [line1, line2] = t.cta.heading.split('\n')
  return (
    <section id="cta" className="border-b-2 border-ink py-[80px] bg-primary">
      <div className="container flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
        <div>
          <h2 className="font-display text-[clamp(40px,6vw,80px)] leading-[0.88] uppercase text-paper mb-4">
            {line1}<br />{line2}
          </h2>
          <p className="font-mono text-xs text-paper/70 tracking-[0.08em] uppercase">
            {t.cta.meta}
          </p>
        </div>
        <div className="flex flex-col md:flex-row gap-[10px]">
          <a href={RELEASES} target="_blank" rel="noopener noreferrer"
            className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-paper text-ink py-[18px] px-8 border-2 border-paper transition-colors duration-100 hover:bg-ink hover:text-paper hover:border-ink"
          >{t.cta.downloadBtn}</a>
          <a href={GITHUB} target="_blank" rel="noopener noreferrer"
            className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-transparent text-paper py-[18px] px-8 border-2 border-paper/50 transition-colors duration-100 hover:bg-paper/[0.12] hover:border-paper"
          >{t.cta.githubBtn}</a>
        </div>
      </div>
    </section>
  )
}
