import { useEffect, useRef, useState } from 'react'
import { INK, MONO, PRIMARY } from '../constants'

interface Props {
  sessionPct: number
  weeklyPct: number
  resetTime: string
}

export default function RingsMockup({ sessionPct, weeklyPct, resetTime }: Props) {
  const r1 = 70; const r2 = 46; const cx = 100; const cy = 100
  const c1 = 2 * Math.PI * r1; const c2 = 2 * Math.PI * r2
  const [visible, setVisible] = useState(false)
  const ref = useRef<SVGSVGElement>(null)

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setVisible(true) }, { threshold: 0.3 })
    if (ref.current) obs.observe(ref.current)
    return () => obs.disconnect()
  }, [])

  useEffect(() => { setVisible(false); const t = setTimeout(() => setVisible(true), 80); return () => clearTimeout(t) }, [sessionPct, weeklyPct])

  return (
    <svg ref={ref} viewBox="0 0 200 200" width="148" height="148" className="block shrink-0">
      <circle cx={cx} cy={cy} r={r1} fill="none" stroke={INK} strokeWidth="11" strokeOpacity="0.08" />
      <circle cx={cx} cy={cy} r={r2} fill="none" stroke={INK} strokeWidth="11" strokeOpacity="0.08" />
      <circle cx={cx} cy={cy} r={r1} fill="none" stroke={PRIMARY} strokeWidth="11" strokeLinecap="square"
        strokeDasharray={`${(visible ? weeklyPct : 0) * c1} ${c1}`}
        transform={`rotate(-90 ${cx} ${cy})`}
        style={{ transition: 'stroke-dasharray 1.2s cubic-bezier(0.4,0,0.2,1)' }} />
      <circle cx={cx} cy={cy} r={r2} fill="none" stroke={INK} strokeWidth="11" strokeLinecap="square"
        strokeDasharray={`${(visible ? sessionPct : 0) * c2} ${c2}`}
        transform={`rotate(-90 ${cx} ${cy})`}
        style={{ transition: 'stroke-dasharray 1.2s cubic-bezier(0.4,0,0.2,1) 0.15s' }} />
      <text x={cx} y={cy + 5} textAnchor="middle" fontFamily={MONO} fontSize="14" fontWeight="700" fill={INK} letterSpacing="-0.02em">{resetTime}</text>
    </svg>
  )
}
