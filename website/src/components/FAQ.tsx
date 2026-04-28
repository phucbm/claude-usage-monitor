import { useLanguage } from '../contexts/language'

export default function FAQ() {
  const { t } = useLanguage()
  return (
    <section id="faq" className="border-b-2 border-ink py-[72px]">
      <div className="container">
        <div className="flex justify-between items-baseline mb-9 border-b border-ink/20 pb-[14px]">
          <h2 className="font-display text-[clamp(26px,4vw,44px)] uppercase text-ink">{t.faq.heading}</h2>
          <span className="font-mono text-[11px] text-muted tracking-[0.1em] uppercase">{String(t.faq.items.length).padStart(2, '0')} ENTRIES</span>
        </div>
        <div>
          {t.faq.items.map((faq, i) => (
            <div key={i} className="faq-row">
              <p className="font-mono text-[11px] font-bold tracking-[0.06em] uppercase text-ink leading-[1.6]">
                <span className="text-primary mr-2">Q/</span>{faq.q}
              </p>
              <p className="font-mono text-[13px] leading-[1.75] text-[#3A3A3A]">{faq.a}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
