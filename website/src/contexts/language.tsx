import { createContext, useContext, useEffect, useState } from 'react'
import { en } from '../locales/en'
import { vi } from '../locales/vi'
import type { Translations } from '../locales/en'

type Lang = 'en' | 'vi'

const LOCALES: Record<Lang, Translations> = { en, vi }
const STORAGE_KEY = 'lang'

function detectLang(): Lang {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored === 'en' || stored === 'vi') return stored
  return navigator.language.startsWith('vi') ? 'vi' : 'en'
}

interface LangContext {
  lang: Lang
  t: Translations
  setLang: (l: Lang) => void
}

const LanguageContext = createContext<LangContext | null>(null)

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLangState] = useState<Lang>(detectLang)

  const setLang = (l: Lang) => {
    localStorage.setItem(STORAGE_KEY, l)
    setLangState(l)
  }

  useEffect(() => {
    document.documentElement.lang = lang
  }, [lang])

  return (
    <LanguageContext.Provider value={{ lang, t: LOCALES[lang], setLang }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const ctx = useContext(LanguageContext)
  if (!ctx) throw new Error('useLanguage must be used inside LanguageProvider')
  return ctx
}
