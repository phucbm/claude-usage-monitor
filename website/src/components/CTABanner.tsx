import { GITHUB, RELEASES } from '../constants'

export default function CTABanner() {
  return (
    <section id="cta" className="border-b-2 border-ink py-[80px] px-6 bg-primary">
      <div className="max-w-[1200px] mx-auto flex flex-col md:flex-row justify-between items-start md:items-center gap-8">
        <div>
          <h2 className="font-display text-[clamp(40px,6vw,80px)] leading-[0.88] tracking-[-0.04em] uppercase text-paper mb-4">
            STOP<br />GUESSING.
          </h2>
          <p className="font-mono text-xs text-paper/70 tracking-[0.08em] uppercase">
            Free download &nbsp;·&nbsp; No signup &nbsp;·&nbsp; Open source
          </p>
        </div>
        <div className="flex flex-col md:flex-row gap-[10px]">
          <a href={RELEASES} target="_blank" rel="noopener noreferrer"
            className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-paper text-ink py-[18px] px-8 border-2 border-paper transition-colors duration-100 hover:bg-ink hover:text-paper hover:border-ink"
          >↓ Download for macOS</a>
          <a href={GITHUB} target="_blank" rel="noopener noreferrer"
            className="font-mono font-bold text-xs tracking-[0.08em] uppercase no-underline bg-transparent text-paper py-[18px] px-8 border-2 border-paper/50 transition-colors duration-100 hover:bg-paper/[0.12] hover:border-paper"
          >GitHub →</a>
        </div>
      </div>
    </section>
  )
}
