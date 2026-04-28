import { FAQS } from '../data'

export default function FAQ() {
  return (
    <section id="faq" className="border-b-2 border-ink py-[72px] px-6">
      <div className="max-w-[1200px] mx-auto">
        <div className="flex justify-between items-baseline mb-9 border-b border-ink/20 pb-[14px]">
          <h2 className="font-display text-[clamp(26px,4vw,44px)] tracking-[-0.03em] uppercase text-ink">FAQ</h2>
          <span className="font-mono text-[11px] text-muted tracking-[0.1em] uppercase">{String(FAQS.length).padStart(2, '0')} ENTRIES</span>
        </div>
        <div>
          {FAQS.map((faq, i) => (
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
