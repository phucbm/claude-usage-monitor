import { useLanguage } from '../contexts/language'

export default function Features() {
  const { t } = useLanguage()
  return (
    <section id="features" className="border-b-2 border-ink py-[72px]">
      <div className="container">
        <div className="flex justify-between items-baseline mb-9 border-b border-ink/20 pb-[14px]">
          <h2 className="font-display text-[clamp(26px,4vw,44px)] uppercase text-ink">{t.features.heading}</h2>
          <span className="font-mono text-[11px] text-muted tracking-[0.1em] uppercase">{t.features.count}</span>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 border-2 border-ink">
          {t.features.items.map((f, i) => (
            <div key={f.id}
              className={[
                'group p-8 transition-colors duration-[120ms] cursor-default hover:bg-ink',
                i % 2 !== 1 ? 'md:border-r border-ink' : '',
                i < t.features.items.length - 1 ? 'border-b border-ink' : '',
                i >= 2 ? 'md:border-b-0' : '',
              ].join(' ')}
            >
              <p className="font-mono text-[11px] font-bold text-primary tracking-[0.1em] mb-3">[{f.id}]</p>
              <p className="font-display text-[15px] uppercase text-ink group-hover:text-paper mb-3 transition-colors duration-[120ms]">{f.label}</p>
              <p className="font-mono text-xs leading-[1.75] text-[#3A3A3A] group-hover:text-[#9A9A9A] transition-colors duration-[120ms]">{f.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
