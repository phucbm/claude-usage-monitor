import { ICON } from '../constants'

export default function Logo({ size = 32 }: { size?: number }) {
  return <img src={ICON} alt="Claude Usage Monitor" width={size} height={size} className="block object-contain" />
}
