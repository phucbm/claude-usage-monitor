import { INK, MONO, PAPER, PRIMARY } from '../constants'
import { TICKER_ITEMS } from '../data'

export default function Ticker() {
  const items = [...TICKER_ITEMS, ...TICKER_ITEMS]
  return (
    <div id="ticker" style={{ borderTop: `2px solid ${INK}`, borderBottom: `2px solid ${INK}`, background: INK, overflow: 'hidden', padding: '10px 0' }}>
      <div className="ticker-track">
        {items.map((item, i) => (
          <span key={i} style={{ color: PAPER, fontFamily: MONO, fontSize: 11, fontWeight: 700, letterSpacing: '0.12em', textTransform: 'uppercase', padding: '0 28px' }}>
            {item}<span style={{ color: PRIMARY, marginLeft: 28 }}>///</span>
          </span>
        ))}
      </div>
    </div>
  )
}
