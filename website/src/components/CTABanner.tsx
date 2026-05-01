import {GITHUB, RELEASES} from '../constants'
import {useLanguage} from '../contexts/language'

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
        <div className="flex flex-col gap-4">
          <div className="flex flex-col md:flex-row gap-[10px]">
            <a href={RELEASES} target="_blank" rel="noopener noreferrer"
              className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-paper text-ink py-[18px] px-8 border-2 border-paper transition-colors duration-100 hover:bg-ink hover:text-paper hover:border-ink"
            >{t.cta.downloadBtn}</a>
            <a href={GITHUB} target="_blank" rel="noopener noreferrer"
              className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-transparent text-paper py-[18px] px-8 border-2 border-paper/50 transition-colors duration-100 hover:bg-paper/[0.12] hover:border-paper"
            >{t.cta.githubBtn}</a>
          </div>
            <div className="flex items-start gap-2 flex-wrap mt-4">
                <a className="inline-block"
                   href="https://www.producthunt.com/products/claude-usage-monitor-3?embed=true&amp;utm_source=badge-featured&amp;utm_medium=badge&amp;utm_campaign=badge-claude-usage-monitor-3"
                   target="_blank" rel="noopener noreferrer"><img
                    alt="Claude Usage Monitor - Multiple Claude.ai accounts tracked from your Mac menu bar. | Product Hunt"
                    width="200" height="43"
                    src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=1136430&amp;theme=neutral&amp;t=1777628906554"/></a>
                <a href="https://launch.j2team.dev/products/claude-usage-monitor" target="_blank"
                   rel="noopener noreferrer" className="inline-block">
                    <img src="https://launch.j2team.dev/badge/claude-usage-monitor/neutral"
                         alt="Claude Usage Monitor - Launched on J2TEAM Launch" width="200" height="43"
                         loading="lazy"/>
                </a>
            </div>
        </div>
      </div>
    </section>
  )
}
