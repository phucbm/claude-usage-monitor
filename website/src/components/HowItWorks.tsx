import guide1 from '../assets/guide-1.png'
import guide2 from '../assets/guide-2.png'
import guide3 from '../assets/guide-3.png'
import guide4 from '../assets/guide-4.png'

const STEPS = [
  {
    n: '01',
    title: 'OPEN USAGE SETTINGS',
    body: 'Go to claude.ai/settings/usage — this is where Claude shows your current session and weekly usage limits.',
    img: guide1,
  },
  {
    n: '02',
    title: 'OPEN DEVTOOLS NETWORK TAB',
    body: 'Press Cmd+Option+I to open Developer Tools, then click the Network tab. Make sure "Fetch/XHR" filter is selected.',
    img: guide2,
  },
  {
    n: '03',
    title: 'COPY THE COOKIE',
    body: 'Refresh the page, click the "usage" request in the list, go to the Headers tab, and copy the full "Cookie" value from Request Headers.',
    img: guide3,
  },
  {
    n: '04',
    title: 'ADD ACCOUNT TO THE APP',
    body: 'Open Claude Usage Monitor from your menu bar, click "+", give the account a label, paste the cookie, and hit Save Account.',
    img: guide4,
  },
]

interface StepProps {
  step: typeof STEPS[number]
  index: number
  last: boolean
}

function Step({ step, index, last }: StepProps) {
  const isEven = index % 2 === 0
  const isDark = !isEven

  return (
    <div className={`grid grid-cols-1 md:grid-cols-2 min-h-[420px] ${last ? '' : 'border-b-2 border-ink'}`}>
      {/* Text side */}
      <div className={[
        'flex flex-col justify-center px-8 py-10 md:px-14 md:py-16',
        isEven
          ? 'order-first md:border-r-2 md:border-ink'
          : 'order-first md:order-last bg-ink md:border-l-2 md:border-ink',
      ].join(' ')}>
        <p className="font-display text-[72px] text-primary leading-none mb-6 tracking-[-0.04em]">{step.n}</p>
        <p className={`font-display text-[20px] uppercase mb-4 tracking-[-0.01em] ${isDark ? 'text-paper' : 'text-ink'}`}>{step.title}</p>
        <p className={`font-mono text-[13px] leading-[1.8] max-w-[380px] ${isDark ? 'text-[#777]' : 'text-[#3A3A3A]'}`}>{step.body}</p>
      </div>

      {/* Image side */}
      <div className={[
        'flex items-center justify-center p-10',
        isEven ? 'order-last bg-[#f0f0f0]' : 'order-last md:order-first bg-[#1a1a1a]',
      ].join(' ')}>
        <div className="w-full max-w-[560px] border-2 border-ink overflow-hidden"
          style={{ boxShadow: `4px 4px 0 #0A0A0A` }}>
          {/* Browser chrome */}
          <div className="bg-[#e8e8e8] border-b border-black/15 px-3 py-2 flex items-center gap-[6px]">
            <span className="w-[10px] h-[10px] bg-[#ff5f57] border border-black/10 inline-block" />
            <span className="w-[10px] h-[10px] bg-[#febc2e] border border-black/10 inline-block" />
            <span className="w-[10px] h-[10px] bg-[#28c840] border border-black/10 inline-block" />
            <div className="flex-1 bg-white border border-black/12 h-5 ml-2 flex items-center pl-2">
              <span className="font-mono text-[9px] text-muted">claude.ai/settings/usage</span>
            </div>
          </div>
          <img src={step.img} alt={step.title} className="w-full block object-cover" />
        </div>
      </div>
    </div>
  )
}

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="border-b-2 border-ink pb-12">
      <div className="container">
        <div className="flex justify-between items-baseline pt-12 pb-9 border-b border-ink/20">
          <h2 className="font-display text-[clamp(26px,4vw,44px)] tracking-[-0.03em] uppercase text-ink">SETUP GUIDE</h2>
          <span className="font-mono text-[11px] text-muted tracking-[0.1em] uppercase">04 STEPS</span>
        </div>
      </div>

      {STEPS.map((step, i) => (
        <div key={step.n} className="container">
          <Step step={step} index={i} last={i === STEPS.length - 1} />
        </div>
      ))}
    </section>
  )
}
