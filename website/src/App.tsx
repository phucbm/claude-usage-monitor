import './index.css'
import CTABanner from './components/CTABanner'
import FAQ from './components/FAQ'
import Features from './components/Features'
import Footer from './components/Footer'
import Hero from './components/Hero'
import HowItWorks from './components/HowItWorks'
import Nav from './components/Nav'
import Ticker from './components/Ticker'

export default function App() {
  return (
    <>
      <Nav />
      <Hero />
      <Ticker />
      <Features />
      <HowItWorks />
      <FAQ />
      <CTABanner />
      <Footer />
    </>
  )
}
