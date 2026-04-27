import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

// --- Locale bundles ---------------------------------------------------
// Each namespace maps to a JSON file under locales/{lang}/{ns}.json.
// Add new namespaces here as screens get internationalised.
import esCommon from "./locales/es/common.json";
import enCommon from "./locales/en/common.json";

import esAuth from "./locales/es/auth.json";
import enAuth from "./locales/en/auth.json";

import esCalendar from "./locales/es/calendar.json";
import enCalendar from "./locales/en/calendar.json";

import esDashboard from "./locales/es/dashboard.json";
import enDashboard from "./locales/en/dashboard.json";

import esClients from "./locales/es/clients.json";
import enClients from "./locales/en/clients.json";

import esProducts from "./locales/es/products.json";
import enProducts from "./locales/en/products.json";

import esInventory from "./locales/es/inventory.json";
import enInventory from "./locales/en/inventory.json";

import esEvents from "./locales/es/events.json";
import enEvents from "./locales/en/events.json";

import esQuotes from "./locales/es/quotes.json";
import enQuotes from "./locales/en/quotes.json";

/**
 * i18next setup — namespaces are added incrementally as each screen is
 * internationalised. `common` holds shared strings (buttons, nav, errors).
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
      es: {
        common: esCommon,
        auth: esAuth,
        calendar: esCalendar,
        dashboard: esDashboard,
        clients: esClients,
        products: esProducts,
        inventory: esInventory,
        events: esEvents,
        quotes: esQuotes,
      },
      en: {
        common: enCommon,
        auth: enAuth,
        calendar: enCalendar,
        dashboard: enDashboard,
        clients: enClients,
        products: enProducts,
        inventory: enInventory,
        events: enEvents,
        quotes: enQuotes,
      },
    },
    fallbackLng: "es",
    // "es-MX", "en-US", "es-AR" all collapse to the 2-letter base locale
    // we ship. Prevents empty translations for regional variants.
    load: "languageOnly",
    supportedLngs: ["es", "en"],
    ns: ["common", "auth", "calendar", "dashboard"],
    defaultNS: "common",
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
