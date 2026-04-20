import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

import esCalendar from "./locales/es/calendar.json";
import enCalendar from "./locales/en/calendar.json";

/**
 * i18next setup — first slice is the Calendar screen. Other namespaces
 * (`dashboard`, `events`, …) will land here as they get extracted.
 *
 * Resolution order:
 *   1. Explicit localStorage preference (`i18nextLng`)
 *   2. Browser `navigator.language`
 *   3. Fallback to `es` (app's development language)
 */
void i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      es: { calendar: esCalendar },
      en: { calendar: enCalendar },
    },
    fallbackLng: "es",
    // "es-MX", "en-US", "es-AR" all collapse to the 2-letter base locale
    // we ship. Prevents empty translations for regional variants.
    load: "languageOnly",
    supportedLngs: ["es", "en"],
    ns: ["calendar"],
    defaultNS: "calendar",
    interpolation: {
      // React already escapes; turning i18next's escape off avoids double-
      // encoding of ampersands / quotes in translations.
      escapeValue: false,
    },
    detection: {
      order: ["localStorage", "navigator"],
      caches: ["localStorage"],
      lookupLocalStorage: "i18nextLng",
    },
  });

export default i18n;
