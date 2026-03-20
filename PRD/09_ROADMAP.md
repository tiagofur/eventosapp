# Roadmap Unificado — Solennix (iOS + Android + Web + Backend)

**Fecha:** Marzo 2026
**Version:** 1.0

---

## 1. Supuestos

- **Desarrollador:** Tiago (solo) + Claude Code Max
- **Horas/semana:** 20-30 horas
- **Plataformas en paralelo:** Las 4 plataformas se desarrollan simultaneamente (no secuencialmente)
- **Backend Go:** Compartido entre todas las plataformas; funcional y con API completa
- **Web React:** Funcional con todas las paginas principales
- **iOS:** En desarrollo activo con features principales + widgets + LiveActivity
- **Android:** En desarrollo activo con architecture modular y features principales
- **Reutilizacion estimada:** ~30% del diseno y logica de negocio se comparte conceptualmente entre plataformas (modelos de dominio, flujos de UX, validaciones)

---

## 2. Estimacion de Esfuerzo Comparativa

| Area | Backend (h) | Web (h) | iOS (h) | Android (h) | Notas |
|------|-------------|---------|---------|-------------|-------|
| Eventos CRUD + form multi-step | 30 | 40 | 50 | 50 | Form wizard mas complejo en mobile |
| Clientes CRUD | 15 | 20 | 25 | 25 | Incluye quick client creation |
| Productos + recetas | 20 | 25 | 30 | 30 | Recetas con ingredientes |
| Inventario (equipo + insumos) | 15 | 20 | 25 | 25 | Stock tracking, tipos |
| Calendario + blackout dates | 10 | 20 | 20 | 20 | Unavailable dates API |
| Auth (email + OAuth + biometric) | 25 | 20 | 30 | 30 | Apple/Google Sign-In, Face ID |
| Dashboard + KPIs | 5 | 25 | 20 | 20 | Charts, pending events |
| Pagos + Stripe | 25 | 20 | 15 | 10 | Stripe web, StoreKit iOS |
| PDFs (7 tipos) | - | 20 | 40 | 40 | Client-side generation |
| Busqueda global + Spotlight | 10 | 15 | 20 | 15 | CoreSpotlight solo iOS |
| Widgets + Live Activity | - | - | 35 | 25 | WidgetKit, Glance |
| Suscripciones + gating | 20 | 15 | 20 | 25 | Play Billing mas complejo |
| Admin panel | 10 | 30 | - | - | Solo web |
| Settings + business config | 5 | 15 | 20 | 20 | Branding, contratos |
| Onboarding | - | 5 | 15 | 15 | Welcome flow |
| Deep linking | 5 | 5 | 10 | 10 | URL scheme solennix:// |
| Offline cache | - | - | 20 | 20 | SwiftData / Room |
| Testing | 30 | 20 | 25 | 25 | Unit + integration |
| CI/CD + deploy | 15 | 10 | 10 | 15 | Docker, Fastlane, GitHub Actions |
| Polish + QA | 20 | 15 | 25 | 30 | Fragmentacion Android |
| **Total estimado** | **~260** | **~340** | **~475** | **~470** | |

**Conclusion:** Las apps moviles requieren ~40% mas esfuerzo que web/backend debido a widgets, PDF generation nativa, offline cache y suscripciones in-app.

---

## 3. Fases — Backend (Go)

### Fase 1: Foundation (Completada)

- ✅ Setup Go + Chi + PostgreSQL + Docker
- ✅ Auth completa (register, login, refresh, forgot/reset, Google, Apple)
- ✅ CRUD: eventos, clientes, productos, inventario
- ✅ Event items: products, extras, equipment, supplies
- ✅ Middleware stack (auth, CORS, rate limiting, security headers, recovery, logger)
- ✅ 26 migrations aplicadas
- ✅ File uploads (imagenes)
- ✅ Search global

### Fase 2: Monetizacion (Completada)

- ✅ Stripe integration (checkout sessions, webhooks, customer portal)
- ✅ RevenueCat webhooks
- ✅ Subscription management
- ✅ Admin panel endpoints

### Fase 3: Mejoras Pendientes (~60h)

| Tarea | Horas | Prioridad |
|-------|-------|-----------|
| Push notifications (Firebase/APNS) | 20h | Alta |
| Email notifications (eventos proximos, pagos) | 15h | Media |
| Export CSV/Excel de datos | 10h | Baja |
| Reportes financieros avanzados | 15h | Media |

---

## 4. Fases — Web (React)

### Fase 1: Foundation (Completada)

- ✅ Setup React + Vite + Tailwind + TypeScript
- ✅ Auth flow (login, register, forgot/reset password)
- ✅ CRUD completo: eventos, clientes, productos, inventario
- ✅ Dashboard con KPIs y charts (recharts)
- ✅ Calendario con unavailable dates
- ✅ Settings, business config, pricing

### Fase 2: Features Avanzadas (Completada)

- ✅ Admin panel (dashboard, user management)
- ✅ PDF generation (jsPDF)
- ✅ Quick quote
- ✅ Search global
- ✅ Stripe checkout + payment success flow
- ✅ Landing page + pricing page

### Fase 3: Polish Pendiente (~50h)

| Tarea | Horas | Prioridad |
|-------|-------|-----------|
| Responsive mobile improvements | 10h | Media |
| PWA support (offline basico) | 15h | Baja |
| Performance optimization (lazy loading, code splitting) | 10h | Media |
| E2E tests con Playwright (cobertura completa) | 15h | Media |

---

## 5. Fases — iOS (SwiftUI)

### Fase 1: Foundation (Completada)

- ✅ Setup Xcode + SPM packages + project.yml
- ✅ MVVM con @Observable + actor-based APIClient
- ✅ Auth (login, register, biometric, forgot password, Apple Sign-In)
- ✅ Eventos (list, detail, form 6-step, checklist, photos)
- ✅ Clientes (list, detail, form, quick quote)
- ✅ Productos + Inventario CRUD
- ✅ Calendario
- ✅ Dashboard + KPIs + pending events

### Fase 2: Apple Ecosystem (Completada)

- ✅ Navigation adaptive (CompactTabLayout + SidebarSplitLayout)
- ✅ Widgets (4 tipos: upcoming events, KPIs, lock screen, interactive)
- ✅ Live Activity + Dynamic Island
- ✅ Core Spotlight indexing
- ✅ Deep linking (URL scheme solennix://)
- ✅ PDF generation (7 tipos)
- ✅ Offline cache (SwiftData)

### Fase 3: Premium + Polish (~120h)

| Tarea | Horas | Claude Code |
|-------|-------|-------------|
| StoreKit 2 purchase flow completo | 20h | Medio |
| Feature gating enforcement completo | 15h | Alto |
| Push notifications (APNs) | 15h | Medio |
| iPad/macOS layouts optimizados | 20h | Alto |
| Accessibility audit (VoiceOver, Dynamic Type) | 10h | Alto |
| Performance optimization | 10h | Medio |
| Unit + UI tests | 15h | Alto |
| App Store screenshots + metadata + ASO | 15h | Medio |

### Fase 4: Launch (~40h)

| Tarea | Horas | Claude Code |
|-------|-------|-------------|
| TestFlight beta | 8h | N/A |
| Bug fixes de beta | 20h | Alto |
| App Store submission | 4h | N/A |
| Post-launch monitoring | 8h | Medio |

---

## 6. Fases — Android (Kotlin/Compose)

### Fase 1: Foundation (Completada)

- ✅ Setup multi-module (5 core + 9 feature + widget)
- ✅ Hilt DI + Navigation Compose
- ✅ Ktor client + bearer auth
- ✅ Auth (login, register, biometric gate)
- ✅ Eventos (list, detail, form 4-step)
- ✅ Clientes, Productos, Inventario CRUD
- ✅ Calendario, Dashboard, Search
- ✅ Adaptive navigation (bottom nav + rail)

### Fase 2: Ecosystem + Polish (~150h)

| Tarea | Horas | Claude Code |
|-------|-------|-------------|
| Home screen widgets (Glance) | 25h | Medio |
| PDF generation nativa | 30h | Medio |
| Room database + offline cache | 20h | Alto |
| Deep linking completo | 10h | Alto |
| Play Billing (suscripciones) | 25h | Bajo |
| Feature gating enforcement | 10h | Alto |
| Push notifications (Firebase) | 15h | Medio |
| Material You dynamic theming | 10h | Alto |
| Accessibility (TalkBack, font scaling) | 5h | Medio |

### Fase 3: Launch (~60h)

| Tarea | Horas | Claude Code |
|-------|-------|-------------|
| Internal testing track | 10h | N/A |
| Bug fixes | 20h | Alto |
| OEM testing (Samsung, Pixel, Xiaomi) | 15h | N/A |
| Play Store listing + ASO | 10h | Medio |
| Staged rollout | 5h | N/A |

---

## 7. Timeline Visual

```
2026:
        Ene     Feb     Mar     Abr     May     Jun     Jul     Ago     Sep
Backend:[== F1 completada ==][== F2 completada ==][ F3 mejoras ]
Web:    [== F1 completada ==][== F2 completada ==][ F3 polish  ]
iOS:    [== F1 completada ==][== F2 completada ==][== F3 premium ==][F4 launch]
Android:[===== F1 completada =====][====== F2 ecosystem ======][= F3 launch =]

Leyenda:
  F1 = Foundation       (completada en todas las plataformas)
  F2 = Features/Ecosystem (completada en backend/web/iOS, en progreso Android)
  F3 = Polish/Premium    (fase actual para iOS, proxima para Android)
  F4 = Launch           (target: iOS Q2 2026, Android Q3 2026)
```

**Notas del timeline:**
- Backend y Web estan funcionales — focus en mejoras incrementales
- iOS esta mas avanzado que Android — target de App Store Q2 2026
- Android target de Play Store Q3 2026
- El trabajo en paralelo es posible: polish iOS mientras se completa ecosystem Android

---

## 8. Camino Critico

### iOS — Camino Critico

```
StoreKit 2 purchase flow ──> Feature gating completo ──> Beta testing
                                      |
Push notifications (APNs) ──────────> App Store submission
                                      |
iPad/macOS optimization ──> Accessibility audit ──> Polish
```

**Riesgo principal:** StoreKit 2 + feature gating son prerequisitos para monetizacion. Sin esto, no tiene sentido lanzar.

### Android — Camino Critico

```
Glance widgets + Room cache ──> PDF generation
                                      |
Play Billing ──> Feature gating ──> Internal testing
                        |
Firebase push ──> OEM testing ──> Play Store submission
```

**Riesgo principal:** Play Billing es el cuello de botella. Mas complejo que StoreKit 2 y requiere configuracion en Play Console.

---

## 9. Efectividad Claude Code

| Fase | Backend % | Web % | iOS % | Android % | Mejor para |
|------|-----------|-------|-------|-----------|------------|
| Foundation | 70% | 75% | 65% | 65% | Scaffolding, CRUD, boilerplate |
| Features/Ecosystem | 60% | 65% | 50% | 55% | Widgets, PDF templates, tests |
| Polish/Premium | 50% | 55% | 45% | 50% | Accessibility, localizacion, bug fixes |
| Launch | 30% | 40% | 35% | 30% | Store descriptions, landing page |
| **Overall** | **~55%** | **~60%** | **~50%** | **~50%** | |

**Impacto estimado:** Claude Code ahorra ~300-350 horas en total entre las 4 plataformas.

---

## 10. Riesgos y Mitigaciones

### Backend

| Riesgo | Impacto | Mitigacion |
|--------|---------|------------|
| Push notifications requieren integracion con APNS + Firebase | +1-2 semanas | Implementar un servicio unificado de notificaciones |
| Escalabilidad de PostgreSQL con muchos usuarios | Medio | Connection pooling ya configurado con pgx |
| Seguridad de file uploads | Alto | Validacion de tipos, limites de tamano ya implementados |

### Web

| Riesgo | Impacto | Mitigacion |
|--------|---------|------------|
| Bundle size crece con dependencias | Bajo | Code splitting + lazy loading |
| SEO limitado (SPA) | Medio | Landing page estatica + meta tags |

### iOS

| Riesgo | Impacto | Mitigacion |
|--------|---------|------------|
| StoreKit 2 edge cases (restore, family sharing) | +1 semana | Testing exhaustivo en sandbox |
| App Store rejection por metadata/screenshots | +1 semana | Seguir guidelines al pie de la letra |
| iPad/macOS layouts requieren mucho polish | +1-2 semanas | Priorizar iPhone, iPad como fast-follow |

### Android

| Riesgo | Impacto | Mitigacion |
|--------|---------|------------|
| Play Billing 7 complejidad | +2 semanas | Empezar temprano, usar billing-ktx samples |
| OEMs matando procesos en background | +1 semana | dontkillmyapp.com + educacion al usuario |
| Fragmentacion de dispositivos | +1 semana | Testing en emuladores variados + Firebase Test Lab |
| Glance (widgets) limitaciones de API | +0.5 semanas | Widgets simples primero, iterar |

### Compartidos

| Riesgo | Impacto | Mitigacion |
|--------|---------|------------|
| Solo developer = bus factor de 1 | Alto | PRD exhaustivo + Claude Code como knowledge base |
| Burnout a 25h/semana | Alto | Fases claras con milestones celebrables |
| Paridad cross-platform se desincroniza | Medio | Tabla de paridad en PRD + verificacion por sesion |
| Pricing LATAM no genera suficiente revenue | Medio | A/B testing de precios, tier intermedio |

**Buffer total de riesgo:** +3-5 semanas por plataforma movil
**Timeline realista:** iOS App Store Q2-Q3 2026, Android Play Store Q3-Q4 2026
