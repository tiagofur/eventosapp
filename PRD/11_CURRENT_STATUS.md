# Current Status — Solennix

**Last Updated:** 2026-04-16 (cierre de Sprint 7.A + Portal Cliente MVP + Personal/Colaboradores Phase 1).
**Status:** 25+ commits pusheados hoy. Audit 2026-04-16 cerrado (30/38 findings). Portal Cliente MVP live en backend + web. Pricing foundation listo, espera dashboards externos. **Feature "Personal / Colaboradores" Phase 1 cerrada en los 4 stacks** (backend + web + iOS + Android) con hooks para Phase 2 (notifs Pro+) y Phase 3 (Business multi-user) ya en la migración 042 — pending deploy manual del backend + migración en la DB de producción.

---

## 1. Producción — qué está live hoy (2026-04-16)

### 1.1 Apps publicadas

| Plataforma | Versión | Store | Status |
|---|---|---|---|
| iOS | 1.0.2 | App Store MX — `id6760874129` | ✅ Live. **Sin cambios de hoy** (se envían en 1.0.4 cuando armes próximo build). |
| Android | 1.0.0 | Play Store | ✅ Live. **Sin cambios de hoy** (próximo APK firmado ya incluye los fixes). |
| Web | latest | `solennix.com` | ✅ Live. Pendiente deploy manual para incorporar cambios de hoy. |
| Backend | latest | `api.solennix.com` | ✅ Live. Pendiente deploy manual + migration 040+041. |

### 1.2 Auth status

| Flow | iOS | Android | Web | Backend |
|---|:-:|:-:|:-:|:-:|
| Email + password | ✅ | ✅ | ✅ | ✅ |
| Google Sign-In | ✅ | ✅ | ✅ | ✅ |
| Apple Sign-In (existing user) | ✅ | ✅ | ✅ | ✅ |
| Apple Sign-In (new user) | ✅ | ✅ | ✅ | ✅ *(arreglado hoy — ver §3.1)* |
| JWT refresh + rotation | ✅ | ✅ | ✅ | ✅ |
| Session persistence | ✅ | ✅ | ✅ | ✅ |
| Logout + token revoke | ✅ | ✅ | ✅ | ✅ |

---

## 2. Lo que se empujó hoy (commits en `main`)

25 commits firmados sin `Co-Authored-By` (per user preference global):

```
a3f425a  fix(android): silent migration of legacy checklist prefs
06d69ff  feat(web): Client Portal MVP — /client/:token + share card
8dff4f3  feat(backend): Portal Cliente MVP — tokenized link + public view
993719c  feat(web): Business tier card + paywall + plan param
8d521b2  feat(backend): Business tier + 14-day Stripe trial
8d99328  chore: .env.example completo con todas las vars
0284923  a11y(ios): VoiceOver pass on Dashboard cards + chart + buttons
62a5d6b  perf(ios): DateFormatter cache + hot-path migration
f960e02  fix(ios): Dashboard kpis preload (counts < 200ms)
d2b967e  fix(web): CalendarView fetch layer to React Query
9660842  docs(prd): backfill 10 PRD documents (sprint 5)
b4ad3e1  fix(ios): removePhoto undo + utf8 force-unwraps
5e4a900  fix(android): CSV filters + Calendar errors + encrypted checklist
3a72812  fix(backend): sort allowlist + rate limiter + admin errors
8335d5d  fix(web): Modal scroll lock + toast throttle + Settings guard
3b72e8e  fix(ios): Dashboard .task + static DateFormatter + safer regex
665c002  fix(android): observeEvent + lifecycle-aware Window + bounded fanout
8a3162f  fix(web): EventForm step validation + PublicEventForm AbortController
a8a8dd4  fix(backend): GetAll LIMIT + Apple token timeout
f1d0ef2  docs(prd): audit backlog + client-transparency roadmap
e5751ae  fix(web): EventForm fetchMissingCosts re-render loop
3bb1cba  fix(android): syncEventItems @Transaction
8277dc2  fix(ios): APIClient timeout + SwiftData error propagation
3ec4eba  fix(backend): restore Apple Sign-In for new users
```

**Volumen:** ~6000 líneas entre código y docs.

---

## 3. Audit 2026-04-16 — qué quedó abierto

Del audit original de 38 findings:
- **P0:** 8 → 7 arreglados, 1 inválido.
- **P1:** 12 → 11 arreglados, 1 skipeado con rationale.
- **P2:** 11 → 8 arreglados, 3 diferidos con rationale.
- **P3:** 7 → 4 arreglados, 3 diferidos con rationale.

**Neto:** 30 resueltos, 7 diferidos, 1 inválido.

### 3.1 P0 críticos (TODOS cerrados)

- **P0-BE-1/2/3** (Apple Sign-In): ✅ Arreglado en `3ec4eba`. `CreateWithOAuth` + `Plan: "basic"` + check de `GenerateTokenPair` errors en las 3 branches de `AppleCallback`.
- **P0-iOS-1** (addPhotos @MainActor): ⚠️ Audit inválido — el atributo YA estaba presente. Documentado.
- **P0-iOS-2** (APIClient timeout): ✅ Arreglado en `8277dc2`. `timeoutIntervalForResource = 60`.
- **P0-iOS-3** (SolennixModelContainer fatalError): ✅ Arreglado en `8277dc2`. `throws` + caller captura a Sentry.
- **P0-AND-1** (syncEventItems `@Transaction`): ✅ Arreglado en `3bb1cba`.
- **P0-WEB-1** (fetchMissingCosts loop): ✅ Arreglado en `e5751ae`.

### 3.2 P1 (11 de 12)

Todos cerrados **excepto P1-iOS-2** (`@Observable` + `didSet`): skipeado porque Apple docs contradicen el audit — el macro preserva property observers. Documentado en commit `3b72e8e`. Se reabre solo con repro concreto.

### 3.3 P2 (8 de 11)

**Diferidos con rationale:**

- **P2-WEB-1 (CalendarView → React Query):** ✅ cerrado hoy en `d2b967e`.
- **P2-BE-1 (MaxBytesReader nil):** ⏳ Diferido. Go 1.25 stdlib no panickea; 40 call-sites a cambiar para cero beneficio. Revisitar si Go 1.26 cambia contrato.
- **P2-iOS-3 (Dashboard 8 GETs):** 🟡 Parcial en `f960e02` — preload `/dashboard/kpis` llena counts en <200ms. Migración completa a endpoint único que devuelva listas aún pendiente (requiere backend change).
- **Otros P2-iOS/P2-AND:** arreglados en `b4ad3e1` + `5e4a900`.

### 3.4 P3 (4 de 7)

**Diferidos:**
- **P3-iOS-1 (DateFormatter en 14 views):** 🟡 Parcial en `62a5d6b` — top 6 files migrados. PDF generators y ViewModels quedan.
- **P3-iOS-2 (VoiceOver coverage):** 🟡 Parcial en `0284923` — Dashboard cubierto. EventDetail tabs, settings y charts restantes.
- Resto cerrado.

---

## 4. Portal Cliente MVP (PRD/12 feature A) — nuevo hoy

### 4.1 Qué se shipeó

**Backend (commit `8dff4f3`):**
- Migration 041 `event_public_links` + partial unique index.
- Modelo `EventPublicLink`, repositorio con Create/GetActive/GetByToken/Revoke.
- Handler `EventPublicLinkHandler` con 4 endpoints:
  - `POST /api/events/{id}/public-link` (autenticado, rota token si existe activo).
  - `GET  /api/events/{id}/public-link` (autenticado).
  - `DELETE /api/events/{id}/public-link` (autenticado).
  - `GET  /api/public/events/{token}` (público, sin auth, rate limited 10/min).
- Respuesta pública curada: evento (sin notas internas), organizer branding, cliente (nombre), payment summary (total/paid/remaining).
- 410 Gone para revoked/expired (web puede distinguir "URL mal copiada" de "organizer deshabilitó").
- Auto-revoke si el evento fue borrado mientras el link estaba activo.

**Web (commit `06d69ff`):**
- Ruta pública `/client/:token` → `ClientPortalPage.tsx`.
- `ClientPortalUnavailable` con copy para 404 y 410 distintos.
- `eventPublicLinkService` wrap de los 3 endpoints autenticados.
- `ClientPortalShareCard` en EventSummary: Copy + WhatsApp share + Rotate + Revoke.
- App.tsx route lazy registrada.

### 4.2 Qué queda para completar feature A

| Item | Plataforma | Tracking |
|---|---|---|
| iOS `ClientPortalShareSheet.swift` en EventDetailView | iOS | Sprint 8 |
| Android `ClientPortalShareBottomSheet.kt` en EventDetailScreen | Android | Sprint 8 |
| OpenAPI docs de los 4 endpoints | Backend | Follow-up (lo agrego junto con Sprint 7.B) |
| PIN opcional (extra layer de privacy) | Backend + clientes | Backlog |
| Field-level `visibleToClient` toggles | Backend + clientes | Backlog |
| Plan limit (Gratis 1 portal / Pro ∞) | Backend | Sprint 7.C (enforcement matrix) |

---

## 5. Pricing foundation (Sprint 7.A) — listo, espera tu setup

### 5.1 Backend (✅ listo para cobrar)

- `.env.example` completo con 30+ vars.
- Migration 040 permite `plan = 'business'` en DB.
- `CreateCheckoutSession` acepta body opcional `{plan: "pro"|"business", skip_trial: bool}`.
- Stripe Subscription metadata propaga el `plan` label → webhook distingue Pro vs Business.
- 14-day trial default en web (paridad con mobile IAP trial).

### 5.2 Web (✅ listo para cobrar)

- `Pricing.tsx` con 3 cards (Básico / Pro / Business).
- `api.ts` detecta `403 plan_limit_exceeded` → toast + CustomEvent.
- Layout listener redirige a `/pricing` post-error 800ms.
- Service acepta `plan` param.

### 5.3 iOS / Android (⏳ espera dashboards externos)

Código ya existe (SubscriptionManager + RC SDK wired + fallback StoreKit). **Falta solo**:
1. Crear productos en App Store Connect + Google Play.
2. Conectarlos en RevenueCat.
3. Reemplazar la key de Test Store por la de App Store (live) en `ios/Config/Secrets.xcconfig`. Ver `PRD/04` §11 para cómo verificar.

**Sin estas tareas externas, mobile NO cobra** (pero tampoco crashea — `SubscriptionManager` detecta offerings vacías y cae al fallback).

---

## 6. Deploy / Build Status

| Component | Versión | Environment | Status |
|-----------|---------|-------------|--------|
| iOS | 1.0.2+ (project.yml marca 1.0.4) | App Store MX | ✅ Live — `https://apps.apple.com/mx/app/solennix/id6760874129` |
| Android | 1.0.0 | Play Store | ✅ Live — release APK firmado con `solennix.jks` |
| Web | Latest merged to `main` | `solennix.com` | ✅ Live (pendiente deploy manual para incorporar hoy) |
| Backend | Latest merged to `main` | `api.solennix.com` | ✅ Live (pendiente deploy manual + migration 040 + 041) |
| CI Pipeline | — | GitHub Actions | ✅ backend + web tests + typecheck + lint + E2E Playwright |
| Deploy workflow | — | GitHub Actions | 🟡 **Prepared, NOT activated** — deploy manual por decisión del usuario. |

**Deploy pipeline:** `.github/workflows/deploy.yml` existe con comentarios claros. Falla en cada push a main con "missing server host" porque los secrets VPS no están cargados — **por diseño, no es un bug**. Activación queda para cuando el usuario decida migrar de manual → auto-deploy (Sprint 4, deferido).

---

## 7. Próximo deploy manual — checklist

Cuando hagas `git pull && docker-compose up -d --build` en el VPS:

- [ ] Backup del DB antes (snapshot o `pg_dump`).
- [ ] Verificar que las migrations 040 y 041 corran (o aplicarlas manual).
- [ ] Smoke test post-deploy:
  - [ ] `GET /health` → `{"status":"ok","db":"connected"}`.
  - [ ] Login email + password funciona.
  - [ ] **Crear cuenta NUEVA con Apple Sign-In funciona** (el bug P0 más importante de hoy).
  - [ ] Dashboard web carga KPIs.
  - [ ] Calendar web navega entre meses sin spinner entre navegaciones cache-hit.
  - [ ] En un evento existente, generar portal link → abrirlo en incógnito → ver página → rotarlo → la vieja URL da 410.

---

## 8. Testing Checklist

### Funcional (cross-platform)

- [x] Auth flows Google/Apple (iOS, Android, Web) — ⚠️ Apple new-user backend path ahora arreglado.
- [x] Session persistence cross-platform.
- [x] Logout en todas las plataformas.
- [x] Sprint 1-3 fixes validados en tests de backend (✅ all green).
- [x] Sprint 6 fixes validados en web tests (1129+ passing).
- [ ] **iOS/Android manual QA post-fix** — pendiente cuando armes próxima release.

### Portal Cliente MVP

- [ ] Generar link desde EventSummary web.
- [ ] Abrir `/client/:token` en incógnito.
- [ ] Ver countdown + estado + pagos reflejados correctamente.
- [ ] Rotar → la URL vieja da 410 Gone con copy "disabled by organizer".
- [ ] Revocar → idem.
- [ ] Borrar el evento desde la app → intentar abrir el link → 410 Gone con copy "event no longer exists".

### Pricing foundation

- [ ] Web: clickear tarjeta Pro → redirect a Stripe Checkout (modo test por ahora).
- [ ] Web: clickear tarjeta Business sin `STRIPE_BUSINESS_PRICE_ID` → 400 con mensaje claro (comportamiento esperado).
- [ ] Web: alcanzar un plan limit → ver toast + redirect a `/pricing` (verificar con el debug endpoint si hace falta).

---

## 9. Known Issues

**Técnicos abiertos (ninguno P0 ni P1):**

- **P2-BE-1:** `http.MaxBytesReader(nil, ...)` en `helpers.go`. No panickea en Go 1.25, 40 call-sites a cambiar → diferido.
- **P2-iOS-3:** Dashboard aún hace 8 GETs secuenciales (ahora acompañados por preload kpis que paint counts en <200ms, pero las listas siguen siendo secuenciales por el tema HTTP/2 de nginx). Refactor completo requiere endpoint backend agregado.
- **P3-iOS-1:** DateFormatter allocation en PDF generators y ViewModels (no hot-path de renders, acceptable).
- **P3-iOS-2:** VoiceOver coverage en EventDetail tabs + settings pendiente.

**Producto abiertos (no bugs, features pendientes):**

- Portal Cliente iOS + Android (share card nativa) — Sprint 8.
- OpenAPI docs de endpoints Portal Cliente — follow-up.
- Enforcement matrix server-side completo (staff seats, portal limit, advanced analytics gating) — Sprint 7.C.
- Plan expiry cron job (downgrade automático post `plan_expires_at`) — Sprint 7.C.

**Dependencias externas bloqueando activación total de billing:**
- Productos en Stripe Dashboard live.
- Productos en App Store Connect (con trial 14d) + submit for review.
- Productos en Google Play Console (con trial 14d) + publish a closed track.
- RevenueCat: entitlement + offerings + verify public keys live.
- Ver `PRD/04` §11 para checklist completo.

---

## 10. Resolved (histórico)

### 2026-04-16 — Sprint 1-7.A + Portal Cliente

Ver sección 2 (commits) y sección 3 (audit findings). 25 commits en un día.

### 2026-04-15 y anterior

- Authentication parity complete across all platforms (Google & Apple).
- Email notifications (4 types) fully wired.
- Device token registration verified iOS/Android/Web.
- Android Phase 1 + Phase 2 audits: 18 issues fixed.
- Contract product names issue (Android v5→v6 migration).
- iOS PDF generation (menu wired, share fix, token map unified).
- iOS plan enum (pro/business decoding fix).
- iOS BGTaskScheduler registration moved to AppDelegate.

---

## 11. Technical Debt

### Docs
- **OpenAPI:** los nuevos endpoints del Portal Cliente (4) NO están documentados en `backend/docs/openapi.yaml`. Web los llama con tipos manuales. Follow-up.
- **PRD/08 arch backend** menciona SMTP como email provider — corregir a Resend (ya el código lo usa).

### Código
- Dashboard iOS 8 GETs secuenciales (parcialmente mitigado).
- DateFormatter allocations inline en PDF generators iOS.
- VoiceOver sweep amplio pendiente.
- `Pricing.tsx` web tiene precios hardcoded en MXN (no fetcheados de Stripe). Divergen si movés precios en Stripe. Futura mejora: endpoint `/subscriptions/prices` que los sirve dinámicos.
- Android biometric gate NO existe (iOS tiene `BiometricGateView.swift`). Feature no priorizada.
