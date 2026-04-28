import { TICKER_ITEMS } from '../data'

export default function Ticker() {
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS]
  return (
    <div id="ticker" className="border-t-2 border-b-2 border-ink bg-ink overflow-hidden py-[10px]">
      <div className="ticker-track">
        {items.map((item, i) => (
          <span key={i} className="text-paper font-mono text-[11px] font-bold tracking-[0.12em] uppercase px-7">
            {item}<span className="text-primary ml-7">///</span>
          </span>
        ))}
      </div>
    </div>
  )
}
