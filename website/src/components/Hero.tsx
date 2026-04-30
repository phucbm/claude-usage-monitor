import { useEffect, useState } from 'react'
import { GITHUB, RELEASES } from '../constants'
import { useLanguage } from '../contexts/language'
import RingsMockup from './RingsMockup'

function randomTime() {
  const h = Math.floor(Math.random() * 5)
  const m = Math.floor(Math.random() * 60)
  return h > 0 ? `${h}h${m > 0 ? `${m}m` : ''}` : `${m}m`
}

export default function Hero() {
  const { t } = useLanguage()
  const [s, setS] = useState(0.67)
  const [w, setW] = useState(0.42)
  const [r1, setR1] = useState('1h30m')
  const [s2, setS2] = useState(0.31)
  const [w2, setW2] = useState(0.78)
  const [r2, setR2] = useState('3h05m')

  const randomize = () => {
    setS(+(Math.random() * 0.88 + 0.06).toFixed(2)); setW(+(Math.random() * 0.88 + 0.06).toFixed(2)); setR1(randomTime())
    setS2(+(Math.random() * 0.88 + 0.06).toFixed(2)); setW2(+(Math.random() * 0.88 + 0.06).toFixed(2)); setR2(randomTime())
  }

  useEffect(() => { const id = setInterval(randomize, 2000); return () => clearInterval(id) }, [])

  return (
    <section id="hero" className="border-b-2 border-ink">
      <div className="container">
        <div className="grid grid-cols-12 gap-6 lg:gap-8 items-end py-[40px] lg:pt-16 lg:pb-14">

          {/* Text */}
          <div className="col-span-12 lg:col-span-8">
            <p className="font-mono text-[11px] font-bold tracking-[0.15em] uppercase text-primary mb-[18px]">
              {t.hero.badge}
            </p>
            <h1 className="font-display text-[clamp(56px,9vw,116px)] leading-[0.88] uppercase text-ink mb-8">
              CLAUDE<br />USAGE<br /><span className="text-primary">MONITOR</span>
            </h1>
            <p className="font-mono text-sm leading-[1.75] text-[#3A3A3A] max-w-[460px] mb-10"
              dangerouslySetInnerHTML={{ __html: t.hero.description }}
            />
            <div className="flex gap-[10px] flex-wrap">
              <a href={RELEASES} target="_blank" rel="noopener noreferrer"
                className="inline-block bg-primary text-white border-2 border-primary font-mono font-bold uppercase tracking-[0.08em] py-[15px] px-8 text-xs no-underline transition-colors duration-100 hover:bg-ink hover:border-ink"
              >{t.hero.downloadBtn}</a>
              <a href={GITHUB} target="_blank" rel="noopener noreferrer"
                className="inline-block bg-transparent text-ink border-2 border-ink font-mono font-bold uppercase tracking-[0.08em] py-[15px] px-8 text-xs no-underline transition-colors duration-100 hover:bg-ink hover:text-paper"
              >{t.hero.githubBtn}</a>
            </div>
            <p className="mt-[14px] font-mono text-[11px] text-muted tracking-[0.06em]">
              {t.hero.meta}
            </p>
            <a href="https://launch.j2team.dev/products/claude-usage-monitor" target="_blank" rel="noopener noreferrer" className="inline-block mt-4">
              <img src="https://launch.j2team.dev/badge/claude-usage-monitor/neutral" alt="Claude Usage Monitor - Launched on J2TEAM Launch" width="200" height="43" loading="lazy" />
            </a>
          </div>

          {/* Mockup panel */}
          <div className="mockup-panel col-span-12 lg:col-span-4 flex flex-col">

            {/* Mockup menu bar */}
            <div className="w-full h-[26px] bg-ink/90 flex items-center justify-between px-3 mb-[-2px] border-2 border-ink">
              {/* Left: apple + app names */}
              <div className="flex items-center gap-3">
                <span className="text-white/80 text-[11px]">&#63743;</span>
                <span className="font-mono text-[10px] font-bold text-white/60 tracking-wide">Finder</span>
              </div>
              {/* Right: badge + clock */}
              <div className="flex items-center gap-3">
                <span className="font-mono text-[10px] font-bold text-white tracking-wide">
                  P {Math.round(s * 100)}% {r1}
                </span>
                <span className="font-mono text-[10px] font-bold text-white/50 tracking-wide">
                  W {Math.round(s2 * 100)}% {r2}
                </span>
                <span className="font-mono text-[10px] text-white/40">9:41</span>
              </div>
            </div>

            <div className="border-2 border-ink bg-white w-full">

              {/* Header */}
              <div className="border-b-2 border-ink py-[9px] px-4 flex justify-between items-center">
                <span className="font-mono text-[10px] font-bold tracking-[0.08em] uppercase">Claude Usage Monitor</span>
                <span className="font-mono text-[10px] text-green-500 font-bold">+ Add account</span>
              </div>

              {/* Account 1 */}
              <div className="border-b border-ink/12 py-2 px-4 flex justify-between items-center">
                <span className="font-mono text-[11px] font-bold">Personal</span>
                <span className="w-2 h-2 bg-green-500 border border-ink/30 inline-block" />
              </div>
              <div className="p-5 px-4 flex gap-4 items-center">
                <RingsMockup sessionPct={s} weeklyPct={w} resetTime={r1} />
                <div className="flex-1 min-w-0">
                  <p className="font-mono text-[9px] text-muted tracking-[0.08em] uppercase mb-[3px]">Session</p>
                  <p className="font-display text-[30px] text-ink leading-none mb-[3px]">{Math.round(s * 100)}%</p>
                  <p className="font-mono text-[9px] text-muted mb-[14px]">Resets in {r1}</p>
                  <p className="font-mono text-[9px] text-muted tracking-[0.08em] uppercase mb-[3px]">Weekly</p>
                  <p className="font-display text-[30px] text-primary leading-none mb-[3px]">{Math.round(w * 100)}%</p>
                  <p className="font-mono text-[9px] text-muted">Resets Mon 9:00 AM</p>
                </div>
              </div>

              {/* Account 2 */}
              <div className="border-t border-b border-ink/12 py-2 px-4 flex justify-between items-center">
                <span className="font-mono text-[11px] font-bold">Work</span>
                <span className="w-2 h-2 bg-green-500 border border-ink/30 inline-block" />
              </div>
              <div className="p-5 px-4 flex gap-4 items-center">
                <RingsMockup sessionPct={s2} weeklyPct={w2} resetTime={r2} />
                <div className="flex-1 min-w-0">
                  <p className="font-mono text-[9px] text-muted tracking-[0.08em] uppercase mb-[3px]">Session</p>
                  <p className="font-display text-[30px] text-ink leading-none mb-[3px]">{Math.round(s2 * 100)}%</p>
                  <p className="font-mono text-[9px] text-muted mb-[14px]">Resets in {r2}</p>
                  <p className="font-mono text-[9px] text-muted tracking-[0.08em] uppercase mb-[3px]">Weekly</p>
                  <p className="font-display text-[30px] text-primary leading-none mb-[3px]">{Math.round(w2 * 100)}%</p>
                  <p className="font-mono text-[9px] text-muted">Resets Mon 9:00 AM</p>
                </div>
              </div>

              {/* Footer */}
              <div className="border-t border-ink/12 py-2 px-4 flex justify-between">
                <span className="font-mono text-[9px] text-muted">Updated just now</span>
                <button onClick={randomize} className="font-mono text-[9px] text-primary bg-transparent border-0 cursor-pointer p-0 tracking-[0.06em]">
                  Randomize →
                </button>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
  )
}
