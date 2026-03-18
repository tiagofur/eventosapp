# PRD: Solennix Native — iOS, iPadOS & macOS

> **Version:** 1.0
> **Fecha:** 2026-03-17
> **Estado:** Aprobado para desarrollo
> **Autor:** Equipo Solennix + Claude

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Contexto y Motivacion](#2-contexto-y-motivacion)
3. [Plataformas Objetivo](#3-plataformas-objetivo)
4. [Stack Tecnologico](#4-stack-tecnologico)
5. [Arquitectura](#5-arquitectura)
6. [Estructura Modular del Proyecto](#6-estructura-modular-del-proyecto)
7. [Estrategia de App Universal](#7-estrategia-de-app-universal)
8. [Sistema de Navegacion](#8-sistema-de-navegacion)
9. [Design System (SolennixDesign)](#9-design-system-solennixdesign)
10. [Matriz de Paridad de Features](#10-matriz-de-paridad-de-features)
11. [Especificacion Pantalla por Pantalla](#11-especificacion-pantalla-por-pantalla)
12. [Mejoras Nativas Exclusivas](#12-mejoras-nativas-exclusivas)
13. [Capa de Datos](#13-capa-de-datos)
14. [Flujo de Autenticacion](#14-flujo-de-autenticacion)
15. [Suscripciones (Hibrido StoreKit 2 + RevenueCat)](#15-suscripciones)
16. [Generacion de PDFs (PDFKit Nativo)](#16-generacion-de-pdfs)
17. [Gestion de Fotos](#17-gestion-de-fotos)
18. [Notificaciones Push](#18-notificaciones-push)
19. [Accesibilidad](#19-accesibilidad)
20. [Localizacion](#20-localizacion)
21. [Estrategia de Testing](#21-estrategia-de-testing)
22. [CI/CD](#22-cicd)
23. [App Store Optimization](#23-app-store-optimization)
24. [Plan de Migracion](#24-plan-de-migracion)
25. [Cambios Requeridos en Backend](#25-cambios-requeridos-en-backend)
26. [Rollout por Fases](#26-rollout-por-fases)
27. [Metricas de Exito](#27-metricas-de-exito)
28. [Analisis de Riesgos](#28-analisis-de-riesgos)
29. [Apendices](#29-apendices)

---

## 1. Resumen Ejecutivo

### Que es este proyecto

Reescritura completa de la app movil Solennix como **app nativa Swift/SwiftUI** universal para iOS, iPadOS y macOS, reemplazando la actual app React Native (Expo SDK 55).

### Por que nativo

La app actual en React Native ya esta disenada *para* iOS — usa colores del sistema iOS, tipografia que replica Dynamic Type, haptics solo en iOS, y blur views nativos. Sin embargo, esta limitada por el puente JavaScript:

| Aspecto | React Native (actual) | Swift/SwiftUI (objetivo) |
|---------|----------------------|--------------------------|
| Arranque en frio | ~2.5s (motor JS + bundle) | < 0.8s (compilado nativo) |
| Tamano binario | ~45MB (Hermes + deps) | < 15MB (sin runtime JS) |
| Frame rate en scroll | 45-55 fps (puente JS) | 60 fps constante |
| Generacion PDF | ~3s (WebView oculto) | < 0.5s (PDFKit vectorial) |
| Memoria (Dashboard) | ~120MB | < 60MB |
| Widgets | Imposible | WidgetKit completo |
| Live Activities | Imposible | Dynamic Island + Lock Screen |
| Siri Shortcuts | Requiere modulo nativo fragil | App Intents first-class |
| Apple Watch | Imposible sin app nativa | watchOS companion |
| iPad sidebar | Simulado con drawer | NavigationSplitView nativo |
| Teclado fisico (iPad/Mac) | Limitado | Keyboard shortcuts nativos |

### Que se mantiene igual

- **Backend Go** (50+ endpoints REST, PostgreSQL) — sin cambios
- **App web React** — sin cambios
- **Modelo de datos** — identico
- **Branding** — mismos colores, logo, tipografia
- **Cuentas de usuario** — mismas credenciales, mismos datos

### Que se gana

1. **Performance premium** — arranque sub-segundo, scroll a 60fps, PDFs instantaneos
2. **Ecosistema Apple completo** — Widgets, Live Activities, Siri, Spotlight, Face ID
3. **iPad como herramienta de trabajo** — sidebar, 3 columnas, Stage Manager, teclado
4. **Mac como plataforma futura** — app nativa SwiftUI, no Catalyst
5. **Tamano minimo** — sin motor JavaScript, sin bridge, sin dependencias React Native

---

## 2. Contexto y Motivacion

### Que es Solennix

Solennix es una plataforma SaaS premium para organizadores de eventos (catering, banquetes, fiestas, decoracion) principalmente en Mexico. La plataforma permite gestionar clientes, crear cotizaciones, manejar inventario de ingredientes/equipo, generar contratos PDF, controlar pagos y planificar eventos en un calendario.

### Audiencia objetivo

Organizadores de eventos en Mexico que operan servicios de catering y banquetes. Trabajan en campo — necesitan acceso movil para consultar cotizaciones, registrar pagos, revisar checklists de carga, y ver el calendario en sitio.

### Estado actual del producto

| Plataforma | Estado | Tecnologia |
|-----------|--------|------------|
| Web | 97% completa | React 19, Vite, Tailwind CSS 4 |
| Mobile | 95% completa | React Native 0.83, Expo SDK 55 |
| Backend | 97% completo | Go 1.25, Chi v5, PostgreSQL 15 |
| Tests | 783 web, backend passing | Vitest, Go test |
| Feature parity | 97% web/mobile | — |

### Por que ahora

1. La app RN ya esta estabilizada — el MVP esta completo y testeado
2. Los usuarios principales (organizadores en campo) necesitan la mejor experiencia iOS posible
3. Las limitaciones de RN para widgets/notifications/offline son criticas para el caso de uso
4. SwiftUI en iOS 17+ ha madurado lo suficiente para una app de produccion completa
5. La inversion en nativo paga dividendos a largo plazo en mantenimiento y experiencia de usuario

---

## 3. Plataformas Objetivo

| Plataforma | Version Minima | Justificacion |
|-----------|----------------|---------------|
| **iOS** | 17.0+ | Interactive Widgets, App Intents, StandBy Mode, TipKit, String Catalogs |
| **iPadOS** | 17.0+ | Stage Manager mejorado, NavigationSplitView refinado |
| **macOS** | 14.0+ (Sonoma) | SwiftUI nativo (NO Catalyst) — menu bar, ventanas multiples, Preferences |

### Decision: SwiftUI nativo para macOS (NO Catalyst)

Catalyst produce una "iPad inflada". Para una herramienta SaaS premium, SwiftUI nativo en macOS da menu bar propio, ventanas multiples, y panel de Preferences. El costo es mas trabajo de layout, pero `#if os(macOS)` hace esto manejable. macOS es **Fase v2** (post-lanzamiento).

### Compatibilidad de dispositivos

| Dispositivo | Soporte | Layout |
|------------|---------|--------|
| iPhone SE (3rd gen) | Si | Compact width |
| iPhone 15/16 | Si | Compact width |
| iPhone 15/16 Pro Max | Si | Compact width |
| iPad (10th gen) | Si | Regular width, sidebar |
| iPad Air (M2) | Si | Regular width, sidebar, Stage Manager |
| iPad Pro (M4) | Si | Regular width, sidebar, Stage Manager |
| MacBook Air/Pro | v2 | Regular width, menu bar, multi-window |
| iMac | v2 | Regular width, menu bar, multi-window |

---

## 4. Stack Tecnologico

### Decisiones Clave

| Capa | Eleccion | Reemplaza (RN) | Justificacion |
|------|---------|----------------|---------------|
| Lenguaje | **Swift 6** (strict concurrency) | TypeScript | Type-safe, compilado, concurrencia nativa |
| UI Framework | **SwiftUI** (iOS 17+) | React Native 0.83 | Declarativo nativo, sin puente JS |
| Networking | **URLSession + async/await** | fetch API via `api.ts` | Nativo, background tasks, certificados |
| Auth Storage | **Keychain Services** | expo-secure-store | Enclave seguro del hardware |
| Cache Local | **SwiftData** | Ninguno | Offline-first, iCloud sync futuro |
| Suscripciones | **StoreKit 2 + RevenueCat backend** | react-native-purchases | UX nativa + analytics RevenueCat |
| PDF | **UIGraphicsPDFRenderer + PDFKit** | expo-print (HTML→PDF) | Vectorial, 5-10x mas rapido |
| Imagenes | **AsyncImage + Kingfisher** | expo-image | Cache nativa, decodificacion eficiente |
| Iconos | **SF Symbols 5** (5000+) | Lucide React Native (575) | Variantes de peso/escala, accesibles |
| Graficas | **Swift Charts** | victory-native | Framework nativo, accesible |
| Navegacion | **NavigationStack + NavigationSplitView** | React Navigation 7 | Type-safe, transiciones nativas |
| Estado | **@Observable** (Observation framework) | React Context + Zustand | Cero overhead, reactivo |
| Formularios | **SwiftUI Form + validacion custom** | react-hook-form + zod | Integrado, accesible |
| Haptics | **UIFeedbackGenerator** (directo) | expo-haptics | Sin overhead de bridge |
| Camara/Fotos | **PhotosUI (PhotosPicker)** | expo-image-picker | Nativo, seleccion multiple |
| Biometria | **LocalAuthentication** | No implementado | Face ID / Touch ID |
| Analytics | **OSLog + TelemetryDeck** | @sentry/react-native | Privacidad-first |
| Crash Reporting | **Sentry Swift SDK** | @sentry/react-native | Symbolication nativa |

### Decision: SwiftData vs Core Data

**SwiftData.** El modelo de datos es relativamente simple (8 entidades), todos los datos vienen del API, y el macro `@Model` con `@Query` es perfecto para cache offline. SwiftData tambien provee sync automatico con CloudKit para sincronizacion cross-device futura.

### Decision: StoreKit 2 + RevenueCat (Hibrido)

- **Cliente**: StoreKit 2 para flujo de compra, verificacion de transacciones, Family Sharing, Offer Codes
- **Backend**: Mantener webhook RevenueCat + dashboard para analytics de revenue, A/B testing de paywalls
- **RevenueCat SDK en cliente**: Solo para identificacion de usuario + posting de receipts (NO para UI de compra)
- **Beneficio**: UX de compra nativa + analytics de RevenueCat sin sacrificar ninguno

---

## 5. Arquitectura

### Patron: MVVM + Repository + Coordinator

```
+---------------------------------------------------+
|  View Layer (SwiftUI Views)                        |
|    - UI declarativa pura                           |
|    - @State para estado local de UI                |
|    - @Environment para dependencias compartidas    |
+---------------------------------------------------+
                       |
+---------------------------------------------------+
|  ViewModel Layer (@Observable classes)              |
|    - Logica de negocio por pantalla                |
|    - Llama metodos del Repository                  |
|    - Publica estado para las views                 |
+---------------------------------------------------+
                       |
+---------------------------------------------------+
|  Repository Layer (protocolos + implementaciones)  |
|    - Abstrae API + cache local                     |
|    - Decide: fetch de red o cache?                 |
|    - Maneja actualizaciones optimistas             |
+---------------------------------------------------+
                       |
          +------------+------------+
          |                         |
+-----------------+    +-------------------+
|  Network Layer  |    |  Persistence Layer|
|  (APIClient)    |    |  (SwiftData)      |
|  - URLSession   |    |  - @Model entities|
|  - async/await  |    |  - Offline reads  |
|  - JWT refresh  |    |  - Background sync|
|  - Interceptors |    |  - ModelContext    |
+-----------------+    +-------------------+
```

### Principios de Arquitectura

1. **Separacion estricta** — Views no llaman API directamente, siempre via ViewModel → Repository
2. **Protocol-oriented** — Repositories definen protocolos; implementaciones son intercambiables (mock para tests)
3. **Actor-safe networking** — APIClient es un `actor` de Swift; token refresh es thread-safe sin race conditions
4. **Offline-first reads** — SwiftData responde inmediatamente; API actualiza en background
5. **Dependency injection via @Environment** — Facilita testing y preview

### Flujo de Datos (Ejemplo: Listar Clientes)

```
ClientListView
  → ClientListViewModel.loadClients()
    → ClientRepository.getClients()
      → 1. Return cached from SwiftData (instant)
      → 2. Fetch from APIClient.get("/clients") (background)
      → 3. Update SwiftData with fresh data
      → 4. View auto-updates via @Observable
```

---

## 6. Estructura Modular del Proyecto

```
SolennixApp/
|
+-- App/                                # Target principal
|   +-- SolennixApp.swift               # @main entry point
|   +-- ContentView.swift               # Root: auth gate + tab/sidebar
|   +-- Info.plist
|   +-- Assets.xcassets/                # App icon, colors, images
|
+-- Packages/
|   |
|   +-- SolennixCore/                   # Modelos, protocolos, utilidades
|   |   +-- Sources/
|   |   |   +-- Models/                 # Codable structs (User, Client, Event, etc.)
|   |   |   +-- Protocols/             # Repository protocols
|   |   |   +-- Extensions/            # Date, String, Number formatters
|   |   |   +-- Finance/               # Calculos financieros (tax, discount, totals)
|   |   |   +-- ContractTemplate/      # Renderizado de plantillas de contrato
|   |   +-- Tests/
|   |
|   +-- SolennixNetwork/               # Cliente API, endpoints, auth
|   |   +-- Sources/
|   |   |   +-- APIClient.swift         # Actor-based URLSession client
|   |   |   +-- AuthManager.swift       # Keychain + biometric + token refresh
|   |   |   +-- Endpoints/             # Enum tipado de todos los endpoints
|   |   |   +-- Interceptors/          # Request/Response interceptors
|   |   +-- Tests/
|   |
|   +-- SolennixDesign/                 # Design system completo
|   |   +-- Sources/
|   |   |   +-- Colors/                # Tokens de color (Asset Catalog bridge)
|   |   |   +-- Typography/            # Font styles (Dynamic Type)
|   |   |   +-- Spacing/               # Grid de 4px
|   |   |   +-- Shadows/               # ViewModifier extensions
|   |   |   +-- Components/            # Componentes compartidos de UI
|   |   |   |   +-- PremiumButton.swift
|   |   |   |   +-- Avatar.swift
|   |   |   |   +-- KPICard.swift
|   |   |   |   +-- EmptyState.swift
|   |   |   |   +-- FormInput.swift
|   |   |   |   +-- StatusBadge.swift
|   |   |   |   +-- SwipeableRow.swift
|   |   |   |   +-- ConfirmDialog.swift
|   |   |   |   +-- SkeletonView.swift
|   |   |   |   +-- SortSelector.swift
|   |   |   |   +-- SegmentedControl.swift
|   |   |   |   +-- PhotoGallery.swift
|   |   |   |   +-- UpgradeBanner.swift
|   |   |   |   +-- SearchBar.swift
|   |   |   |   +-- ToastOverlay.swift
|   |
|   +-- SolennixFeatures/              # Modulos de features
|       +-- Sources/
|       |   +-- Auth/
|       |   |   +-- Views/             # LoginView, RegisterView, ForgotPasswordView, ResetPasswordView
|       |   |   +-- ViewModels/        # AuthViewModel
|       |   |   +-- Services/          # AuthService, AppleSignInService
|       |   |
|       |   +-- Dashboard/
|       |   |   +-- Views/             # DashboardView, KPISection, UpcomingEventsSection
|       |   |   +-- ViewModels/        # DashboardViewModel
|       |   |
|       |   +-- Calendar/
|       |   |   +-- Views/             # CalendarView, EventDayList
|       |   |   +-- ViewModels/        # CalendarViewModel
|       |   |
|       |   +-- Events/
|       |   |   +-- Views/             # EventFormView (wizard), EventDetailView, EventChecklistView
|       |   |   +-- ViewModels/        # EventFormViewModel, EventDetailViewModel
|       |   |   +-- PDFGenerators/     # 6 generadores de PDF nativos
|       |   |
|       |   +-- Clients/
|       |   |   +-- Views/             # ClientListView, ClientFormView, ClientDetailView
|       |   |   +-- ViewModels/        # ClientListViewModel, ClientFormViewModel
|       |   |
|       |   +-- Products/
|       |   |   +-- Views/             # ProductListView, ProductFormView, ProductDetailView
|       |   |   +-- ViewModels/        # ProductListViewModel, ProductFormViewModel
|       |   |
|       |   +-- Inventory/
|       |   |   +-- Views/             # InventoryListView, InventoryFormView, InventoryDetailView
|       |   |   +-- ViewModels/        # InventoryListViewModel
|       |   |
|       |   +-- Search/
|       |   |   +-- Views/             # SearchView
|       |   |   +-- ViewModels/        # SearchViewModel
|       |   |
|       |   +-- Settings/
|       |       +-- Views/             # SettingsView, EditProfileView, ChangePasswordView,
|       |       |                      # BusinessSettingsView, ContractDefaultsView,
|       |       |                      # PricingView, AboutView, PrivacyView, TermsView
|       |       +-- ViewModels/        # SettingsViewModel, BusinessSettingsViewModel
|       +-- Tests/
|
+-- SolennixWidgetExtension/           # WidgetKit target
|   +-- UpcomingEventsWidget.swift
|   +-- KPIWidget.swift
|   +-- LockScreenWidget.swift
|   +-- Assets.xcassets/
|
+-- SolennixIntents/                   # App Intents extension
|   +-- CreateEventIntent.swift
|   +-- ShowUpcomingEventsIntent.swift
|   +-- EventCountIntent.swift
|   +-- GenerateBudgetIntent.swift
|   +-- CheckInventoryIntent.swift
|
+-- Shared/                            # Shared App Group container
    +-- AppGroupContainer.swift        # UserDefaults suite para widget data
    +-- SharedModels.swift             # Modelos ligeros compartidos con widgets
```

### Justificacion de la estructura modular

- **Builds incrementales** — Cada package compila independientemente; cambios en SolennixFeatures/Events no recompila SolennixDesign
- **Testabilidad** — Cada package tiene su target de tests; repositories mockeables via protocolos
- **Reutilizacion cross-target** — SolennixCore y SolennixNetwork se comparten con Widget, Watch App e Intents
- **Separation of concerns** — Design system aislado del negocio; network aislado de la UI

---

## 7. Estrategia de App Universal

### iPhone (Compact Width)

```
+------------------------------+
|  Status Bar                   |
+------------------------------+
|  Navigation Header            |
|  Titulo | Accion              |
+------------------------------+
|                               |
|  ScrollView / List            |
|  bg: surfaceGrouped           |
|                               |
|  +-------------------------+  |
|  |  Card (bg-card)         |  |
|  |  rounded: 24pt          |  |
|  |  shadow: sm             |  |
|  +-------------------------+  |
|                               |
|  +-------------------------+  |
|  |  Card                   |  |
|  +-------------------------+  |
|                               |
+------------------------------+
|  [Home] [Cal] [+] [Cli] [Mas]|
|  Tab Bar (4 tabs + FAB)      |
+------------------------------+
```

- **TabView** con 4 tabs: Inicio, Calendario, Clientes, Mas
- **FAB central** (boton flotante) para "Nuevo Evento" — igual que la app RN actual
- **NavigationStack** dentro de cada tab para drill-down

### iPad (Regular Width)

```
+--------------------------------------------------+
|  Sidebar (240pt)  |  Content         |  Detail    |
|                   |                  |            |
|  [S] Solennix     |  Lista de        |  Detalle   |
|                   |  Clientes        |  Cliente   |
|  > Inicio         |                  |            |
|  > Calendario     |  +--------+     |  Nombre    |
|  > Clientes       |  | Card   |     |  Telefono  |
|  > Productos      |  +--------+     |  Email     |
|  > Inventario     |  | Card   |     |            |
|  > Buscar         |  +--------+     |  Eventos   |
|                   |                  |  [lista]   |
|  ---------        |                  |            |
|  > Ajustes        |                  |            |
+--------------------------------------------------+
```

- **NavigationSplitView** con sidebar colapsable
- **Layout 3 columnas** para flujos lista → detalle (Clientes, Eventos, Productos)
- **Stage Manager** — ventana redimensionable, multiples instancias
- **Keyboard shortcuts** completos (ver seccion 12)

### Mac (v2 — Post-lanzamiento)

```
+--------------------------------------------------+
|  [Menu Bar: Archivo  Editar  Ver  Evento  Ayuda] |
+--------------------------------------------------+
|  Sidebar (220pt)  |  Content         |  Detail    |
|  ...              |  ...             |  ...       |
+--------------------------------------------------+
```

- **NavigationSplitView** con sidebar permanente
- **Menu bar nativo** — Archivo > Nuevo Evento, Editar > Preferencias
- **Ventanas multiples** — abrir detalle de evento en ventana separada
- **Settings scene** de SwiftUI para Preferencias

### Codigo Adaptativo

```swift
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var authManager: AuthManager

    var body: some View {
        if !authManager.isAuthenticated {
            AuthFlowView()
        } else if sizeClass == .compact {
            CompactTabLayout()       // iPhone
        } else {
            SidebarSplitLayout()     // iPad + Mac
        }
    }
}
```

---

## 8. Sistema de Navegacion

### Navegacion actual en React Native

```
RootNavigator
+-- AuthStack
|   +-- Login, Register, ForgotPassword, ResetPassword
+-- DrawerNavigator
    +-- MainTabs (Bottom Tab Bar — 5 items)
    |   +-- HomeTab > HomeStack (Dashboard, EventForm, EventDetail, EventChecklist)
    |   +-- CalendarTab > CalendarStack (Calendar, EventDetail, EventForm)
    |   +-- CreateEventFAB (interceptado → navega a EventForm)
    |   +-- ClientTab > ClientStack (ClientList, ClientForm, ClientDetail)
    |   +-- MenuTab (abre Drawer)
    +-- ProductStack (ProductList, ProductForm, ProductDetail)
    +-- InventoryStack (InventoryList, InventoryForm, InventoryDetail)
    +-- SearchScreen
    +-- SettingsStack (Settings, EditProfile, ChangePassword, BusinessSettings,
                       ContractDefaults, Pricing, About, Privacy, Terms)
```

### Navegacion nativa SwiftUI

#### Enum de Rutas (Type-Safe)

```swift
enum Route: Hashable {
    // Events
    case eventDetail(id: String)
    case eventForm(id: String? = nil, clientId: String? = nil, date: Date? = nil)
    case eventChecklist(id: String)

    // Clients
    case clientDetail(id: String)
    case clientForm(id: String? = nil)

    // Products
    case productDetail(id: String)
    case productForm(id: String? = nil)

    // Inventory
    case inventoryDetail(id: String)
    case inventoryForm(id: String? = nil)

    // Settings
    case editProfile
    case changePassword
    case businessSettings
    case contractDefaults
    case pricing
    case about
    case privacy
    case terms
}
```

#### iPhone: TabView + NavigationStack

```swift
TabView(selection: $selectedTab) {
    NavigationStack(path: $homePath) {
        DashboardView()
            .navigationDestination(for: Route.self) { route in
                routeView(for: route)
            }
    }
    .tabItem { Label("Inicio", systemImage: "house.fill") }
    .tag(Tab.home)

    NavigationStack(path: $calendarPath) {
        CalendarView()
            .navigationDestination(for: Route.self) { route in
                routeView(for: route)
            }
    }
    .tabItem { Label("Calendario", systemImage: "calendar") }
    .tag(Tab.calendar)

    NavigationStack(path: $clientsPath) {
        ClientListView()
            .navigationDestination(for: Route.self) { route in
                routeView(for: route)
            }
    }
    .tabItem { Label("Clientes", systemImage: "person.2.fill") }
    .tag(Tab.clients)

    NavigationStack(path: $morePath) {
        MoreMenuView() // Products, Inventory, Search, Settings
            .navigationDestination(for: Route.self) { route in
                routeView(for: route)
            }
    }
    .tabItem { Label("Mas", systemImage: "ellipsis") }
    .tag(Tab.more)
}
.overlay(alignment: .bottom) {
    NewEventFAB() // Boton flotante central
}
```

#### iPad/Mac: NavigationSplitView

```swift
NavigationSplitView {
    SidebarView(selection: $selectedSection)
} content: {
    switch selectedSection {
    case .dashboard:  DashboardView()
    case .calendar:   CalendarView()
    case .clients:    ClientListView()
    case .products:   ProductListView()
    case .inventory:  InventoryListView()
    case .search:     SearchView()
    case .settings:   SettingsView()
    }
} detail: {
    // Detail view basado en seleccion de lista
}
```

### Deep Links

```swift
// Password reset via email link
// solennix://reset-password?token=abc123
.onOpenURL { url in
    if url.scheme == "solennix" && url.host == "reset-password" {
        let token = url.queryParameters["token"]
        navigate(to: .resetPassword(token: token))
    }
}
```

---

## 9. Design System (SolennixDesign)

### 9.1 Tokens de Color

Todos los tokens del archivo `mobile/src/theme/colors.ts` migrados a **Asset Catalog** con variantes Light/Dark automaticas.

#### Marca (Brand)

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `SolennixGold` (primary) | `#C4A265` | `#C4A265` | CTAs, iconos activos, badges, links, focus rings |
| `SolennixGoldDark` (primaryDark) | `#B8965A` | `#D4B87A` | Hover/pressed de primary, gradientes |
| `SolennixGoldLight` (primaryLight) | `#F5F0E8` | `#1B2A4A` | Fondos hover sutiles |
| `SolennixSecondary` | `#6B7B8D` | `#94A3B8` | Texto terciario, decorativo |

#### Superficies

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `Background` | `#FFFFFF` | `#000000` (OLED) | Fondo de pagina |
| `SurfaceGrouped` | `#F5F4F1` | `#0A0F1A` (navy tint) | Panel principal |
| `Surface` | `#FAF9F7` | `#1A2030` | Inputs, search bars |
| `SurfaceAlt` | `#F0EFEC` | `#252A35` | Hover, estados alternos |
| `Card` | `#FFFFFF` | `#111722` (navy tint) | Cards, contenedores |

#### Texto

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `PrimaryText` | `#1A1A1A` | `#F5F0E8` (crema) | Texto principal, titulos |
| `SecondaryText` | `#7A7670` | `#9A9590` | Labels, texto secundario |
| `TertiaryText` | `#A8A29E` | `#6B6560` | Placeholders, deshabilitado |
| `InverseText` | `#FFFFFF` | `#1A1A1A` | Texto sobre fondos solidos |

#### Bordes

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `Border` | `#E6E3DD` | `#252A35` | Bordes estandar |
| `BorderStrong` | `#D4D0C8` | `#3A3F4A` | Bordes enfatizados |
| `Separator` | `rgba(60,60,67,0.29)` | `rgba(84,84,88,0.65)` | Lineas divisoras iOS |

#### Semanticos

| Token | Light | Dark | Background Light | Background Dark |
|-------|-------|------|-----------------|-----------------|
| `Success` | `#2D6A4F` | `#52B788` | `#F0F7F4` | `#0B1D14` |
| `Warning` | `#FF9500` | `#FF9F0A` | `#FFF8F0` | `#2A1A00` |
| `Error` | `#FF3B30` | `#FF453A` | `#FFF0F0` | `#2A0A0A` |
| `Info` | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |

#### Status de Evento

| Status | Color Light | Color Dark | Bg Light | Bg Dark |
|--------|------------|------------|----------|---------|
| Quoted (Cotizado) | `#D97706` | `#FBBF24` | `#FFF8F0` | `#2A1A00` |
| Confirmed (Confirmado) | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |
| Completed (Completado) | `#2D6A4F` | `#52B788` | `#F0F7F4` | `#0B1D14` |
| Cancelled (Cancelado) | `#FF3B30` | `#FF453A` | `#FFF0F0` | `#2A0A0A` |

#### KPI

| Token | Color Light | Color Dark | Bg Light | Bg Dark |
|-------|------------|------------|----------|---------|
| KPI Green | `#34C759` | `#30D158` | `#EEFBF0` | `#0D2818` |
| KPI Orange | `#D97706` | `#FBBF24` | `#FFF8F0` | `#2A1A00` |
| KPI Blue | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |

#### Tab Bar

| Token | Light | Dark |
|-------|-------|------|
| Tab Background | `#FFFFFF` | `#111722` |
| Tab Active | `#C4A265` | `#C4A265` |
| Tab Inactive | `#A8A29E` | `#6B6560` |
| Tab Border | `#E6E3DD` | `#252A35` |

#### Avatar

Paleta de 8 colores profesionales (identica en light/dark):
`#5B8DEF`, `#E57373`, `#7DB38A`, `#D4B87A`, `#BA68C8`, `#F06292`, `#4DB6AC`, `#FF8A65`

### 9.2 Tipografia

La tipografia de la app RN ya esta alineada con Dynamic Type de Apple. La migracion es directa:

| Uso | RN Token | SwiftUI Font | Tamano | Peso |
|-----|----------|-------------|--------|------|
| Titulo de pagina | `h1Premium` | `.system(size: 28, weight: .black)` | 28pt | Black |
| Large Title | `largeTitle` | `.largeTitle` | 34pt | Regular |
| Title 1 | `title1` | `.title` | 28pt | Regular |
| Title 2 | `title2` | `.title2` | 22pt | Regular |
| Title 3 | `title3` | `.title3` | 20pt | Regular |
| Headline | `headline` | `.headline` | 17pt | Semibold |
| Body | `body` | `.body` | 17pt | Regular |
| Callout | `callout` | `.callout` | 16pt | Regular |
| Subheadline | `subheadline` | `.subheadline` | 15pt | Regular |
| Footnote | `footnote` | `.footnote` | 13pt | Regular |
| Caption 1 | `caption1` | `.caption` | 12pt | Regular |
| Caption 2 | `caption2` | `.caption2` | 11pt | Regular |

**Tipografia de marca** (Cinzel para headlines premium, usado en login/landing):

```swift
extension Font {
    static let solennixTitle = Font.custom("Cinzel-SemiBold", size: 32, relativeTo: .title)
    static let solennixSubtitle = Font.custom("Cinzel-Regular", size: 24, relativeTo: .title2)
}
```

### 9.3 Espaciado

Grid de 4px identico al actual `mobile/src/theme/spacing.ts`:

```swift
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}
```

### 9.4 Border Radius

| Uso | Valor | Equivalente RN |
|-----|-------|----------------|
| Badges, chips | 6pt | radius-sm |
| Inputs, botones | 10pt | radius-md |
| Cards (web) | 14pt | radius-lg |
| Cards principales (mobile) | 24pt | rounded-3xl |
| Modals | 20pt | radius-xl |

### 9.5 Sombras

```swift
extension View {
    func shadowSm() -> some View {
        shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    func shadowMd() -> some View {
        shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
    func shadowLg() -> some View {
        shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
    func shadowFab() -> some View {
        shadow(color: Color("SolennixGold").opacity(0.4), radius: 8, x: 0, y: 4)
    }
}
```

### 9.6 Gradiente Premium

```swift
let premiumGradient = LinearGradient(
    colors: [Color("SolennixGold"), Color("SolennixGoldDark")],
    startPoint: .leading,
    endPoint: .trailing
)
```

### 9.7 Mapeo de Iconos SF Symbols

| Icono Lucide (RN) | SF Symbol | Uso |
|-------------------|-----------|-----|
| Home | `house.fill` | Tab Inicio |
| CalendarDays | `calendar` | Tab Calendario |
| Users | `person.2.fill` | Tab Clientes |
| Menu / Ellipsis | `ellipsis` | Tab Mas |
| Plus | `plus` | FAB nuevo evento |
| Search | `magnifyingglass` | Busqueda |
| DollarSign | `dollarsign.circle.fill` | Pagos/KPI |
| Package | `shippingbox.fill` | Productos |
| Boxes | `archivebox.fill` | Inventario |
| AlertTriangle | `exclamationmark.triangle.fill` | Alertas |
| Edit2 / Pencil | `pencil` | Editar |
| Trash2 | `trash.fill` | Eliminar |
| Check | `checkmark` | Confirmar |
| Star | `star.fill` | Premium |
| Clock | `clock.fill` | Horario |
| MapPin | `mappin.and.ellipse` | Ubicacion |
| FileText | `doc.text.fill` | PDFs |
| CreditCard | `creditcard.fill` | Metodo pago |
| Camera | `camera.fill` | Captura foto |
| Download | `arrow.down.circle.fill` | Descargar |
| ChevronRight | `chevron.right` | Navegacion |
| Phone | `phone.fill` | Llamar |
| Mail | `envelope.fill` | Email |
| Eye / EyeOff | `eye` / `eye.slash` | Password |
| Settings | `gearshape.fill` | Ajustes |
| Person | `person.fill` | Perfil |
| Lock | `lock.fill` | Seguridad |
| Palette | `paintpalette.fill` | Marca |
| Crown | `crown.fill` | Premium |

### 9.8 Componentes del Design System

Cada componente del RN mapeado a su equivalente SwiftUI:

| Componente RN | Componente SwiftUI | Mejora Nativa |
|--------------|-------------------|---------------|
| `FormInput` | `SolennixTextField` | `.textContentType` para autofill, `@FocusState` |
| `Avatar` | `AvatarView` | SF Symbols fallback, AsyncImage |
| `LoadingSpinner` | `.redacted(reason: .placeholder)` | Skeleton nativo con modifier |
| `ConfirmDialog` | `.confirmationDialog` | Nativo iOS, haptics automaticos |
| `EmptyState` | `EmptyStateView` | SF Symbols animados |
| `AppBottomSheet` | `.sheet` + `.presentationDetents` | Gestos nativos, snapping |
| `SegmentedControl` | `Picker(.segmented)` | Control nativo del sistema |
| `SortSelector` | `Menu` con `Picker` | Menu contextual nativo |
| `SwipeableRow` | `.swipeActions` modifier | Una linea de codigo |
| `KPICard` | `KPICardView` | Swift Charts inline |
| `PremiumButton` | `PremiumButtonView` | Gradiente con animacion nativa |
| `PhotoGallery` | `PhotoGalleryView` | PhotosUI nativo |
| `UpgradeBanner` | `UpgradeBannerView` | StoreKit 2 overlay |
| `QuickClientSheet` | `QuickClientSheet` | `.sheet` con `.presentationDetents([.medium])` |
| `SkeletonList` | `.redacted(reason: .placeholder)` | Built-in modifier |
| `ToastContainer` | `ToastOverlay` | Overlay con animacion nativa |

---

## 10. Matriz de Paridad de Features

### Feature por feature: RN actual vs Native

| Feature | RN Implementation | SwiftUI Equivalent | Mejora |
|---------|-------------------|-------------------|--------|
| Login email/password | Formulario custom + Zod | SwiftUI Form + `.textContentType` | Autofill nativo |
| Registro | Formulario custom + Zod | SwiftUI Form + validacion | Autofill + Sign in with Apple |
| Reset password | Deep link `solennix://` | `.onOpenURL` | Nativo |
| Token JWT + SecureStore | expo-secure-store | Keychain Services | Hardware Secure Enclave |
| Token refresh | Promise singleton | Actor thread-safe | Sin race conditions |
| Tabs (4 + FAB) | @react-navigation/bottom-tabs | TabView + overlay FAB | Transiciones nativas |
| Drawer lateral | @react-navigation/drawer | NavigationSplitView | Sidebar nativo iPad/Mac |
| Dark mode | useTheme hook + SecureStore | `@Environment(\.colorScheme)` + Asset Catalog | Automatico, zero code |
| Theme toggle | SecureStore persistence | `@AppStorage` | iCloud sync gratis |
| Pull-to-refresh | RefreshControl | `.refreshable` modifier | Built-in |
| Haptics | expo-haptics (iOS only check) | UIImpactFeedbackGenerator | Sin bridge |
| PDF generation (6 tipos) | expo-print HTML→PDF via WebView | UIGraphicsPDFRenderer + PDFKit | 5-10x mas rapido, vectorial |
| Compartir PDF | expo-sharing | ShareLink | Nativo, AirDrop |
| Subir fotos | expo-image-picker | PhotosPicker (PhotosUI) | Multi-select, background upload |
| Mostrar imagenes | expo-image | AsyncImage + Kingfisher | Cache nativa |
| Calendario mes | Grid custom + date-fns | Grid custom + Foundation Date | Locale-aware automatico |
| Formularios + validacion | react-hook-form + zod | SwiftUI Form + custom validation | Integrado, accesible |
| Bottom sheets | @gorhom/bottom-sheet | `.sheet` + `.presentationDetents` | Gestos nativos |
| Blur effects | expo-blur BlurView | `.ultraThinMaterial` | Hardware-accelerated |
| Gradientes | expo-linear-gradient | LinearGradient | Zero dependency |
| Graficas (KPIs) | victory-native | Swift Charts | Nativo, accesible |
| App Store review | expo-store-review | SKStoreReviewController | Directo |
| In-app purchases | react-native-purchases (RevenueCat) | StoreKit 2 + RevenueCat backend | First-party + analytics |
| Animaciones | react-native-reanimated | withAnimation / matchedGeometryEffect | 60fps garantizado |
| Swipe actions | Custom SwipeableRow | `.swipeActions` modifier | Una linea |
| Skeleton loading | Custom SkeletonList | `.redacted(reason: .placeholder)` | Built-in |
| Busqueda | Custom SearchScreen | `.searchable` modifier | UI de busqueda del sistema |
| Date/Time pickers | @react-native-community/datetimepicker | DatePicker | Nativo, accesible |
| Iconos | lucide-react-native (575) | SF Symbols 5 (5000+) | Peso/escala variables |
| Onboarding tips | Custom OnboardingChecklist | TipKit | Sistema de tips nativo |
| Cotización Rápida (Quick Quote) | No disponible en Mobile RN | QuickQuoteViewModel + Sheet | Paridad con aplicación Web |
| Eventos Pendientes Alert | Solo lógico en listados | PendingEventsModalView overlay | Alarma visual preventiva automática |
| Notificaciones de Error | Toasts dispersos | ToastOverlay + APIClient direct pipe | Toasts automáticos en fallos globales |

---

## 11. Especificacion Pantalla por Pantalla

### 11.1 Autenticacion (4 pantallas)

#### LoginView

**Fuente RN:** `mobile/src/screens/auth/LoginScreen.tsx`

- **Layout:**
  - Logo Solennix animado (copa tulipan) con titulo en Cinzel
  - Tagline "CADA DETALLE IMPORTA" en Helvetica Neue Light, letter-spacing 5.5px
  - SwiftUI Form con Email y Password
  - Boton principal "Iniciar Sesion" con premium-gradient
  - Enlace "Olvidaste tu contrasena?"
  - Separador "o continua con"
  - **Boton "Sign in with Apple"** (NUEVO — AuthenticationServices)
  - Enlace "Crear cuenta"
  - Carousel de features de marca (Calendario, CRM, Reportes)
- **Campos:**
  - Email: `.textContentType(.emailAddress)`, `.keyboardType(.emailAddress)`, `.autocapitalization(.none)`
  - Password: `.textContentType(.password)`, SecureField con toggle de visibilidad
- **Validacion:** Email no vacio, password no vacio
- **Acciones:** POST `/auth/login` o Sign in with Apple
- **Despues de login exitoso:** Si biometria habilitada, ofrecer activar Face ID/Touch ID

#### RegisterView

**Fuente RN:** `mobile/src/screens/auth/RegisterScreen.tsx`

- **Layout:**
  - Nombre, Email, Password, Confirmar Password
  - Features showcase (Gratis, Seguro, Escalable)
  - Boton "Crear Cuenta" con premium-gradient
  - **"Sign in with Apple"** como alternativa
  - Links a Terms & Privacy
- **Validacion:**
  - Nombre: requerido, 2+ caracteres
  - Email: formato valido
  - Password: 6+ caracteres
  - Confirmar: debe coincidir
- **Accion:** POST `/auth/register`

#### ForgotPasswordView

**Fuente RN:** `mobile/src/screens/auth/ForgotPasswordScreen.tsx`

- Email input + boton "Enviar enlace"
- Estado de exito con instrucciones
- Link "Volver a Login"
- **Accion:** POST `/auth/forgot-password`

#### ResetPasswordView

**Fuente RN:** `mobile/src/screens/auth/ResetPasswordScreen.tsx`

- Recibe token via deep link `.onOpenURL`
- New Password + Confirm Password
- Estado de exito
- **Accion:** POST `/auth/reset-password`

---

### 11.2 Dashboard (1 pantalla compleja)

**Fuente RN:** `mobile/src/screens/home/DashboardScreen.tsx`

#### Secciones (en orden de scroll):

1. **Header de saludo**
   - "Hola, {firstName}" + fecha formateada en espanol
   - Quick action buttons: "Nuevo Evento", "Nuevo Cliente", "Cotización Rápida" (Quick Quote)

2. **Onboarding Checklist** (solo nuevos usuarios, reemplazado por TipKit)
   - 3 pasos: Agregar cliente, Agregar producto, Crear evento
   - Progreso visual, dismissable

3. **Upgrade Banner** (solo plan basic)
   - Indicador de eventos restantes (3/mes limit)
   - Link a PricingView

4. **KPI Cards** (scroll horizontal con `.containerRelativeFrame`)
   - Ventas Netas del Mes: `.toLocaleString('es-MX', { minimumFractionDigits: 2 })`
   - Cobrado del Mes: monto total de pagos
   - IVA Cobrado: suma de tax en eventos pagados
   - IVA Pendiente: suma de tax en eventos no pagados
   - Eventos Este Mes: conteo
   - Stock Bajo: conteo de items bajo minimo

5. **Grafica de Status de Eventos** (Swift Charts)
   - Barra horizontal por status (Cotizado, Confirmado, Completado, Cancelado)

6. **Stock Bajo** (si hay items)
   - Lista de items con current_stock < minimum_stock
   - Icono de alerta naranja

7. **Proximos Eventos** (5 items)
   - Card por evento: cliente, fecha, tipo, status badge
   - Touch → EventDetailView

8. **Modal de Eventos Pendientes** (overlay)
   - Eventos cotizados sin confirmar

- **Refresh:** `.refreshable` que recarga todos los datos
- **Widget data:** Escribe KPIs y proximos eventos en App Group shared container

---

### 11.3 Calendario (1 pantalla)

**Fuente RN:** `mobile/src/screens/calendar/CalendarScreen.tsx`

- **Vista dual** (SegmentedControl):
  - Vista Calendario: Grid de mes con dots por evento (coloreados por status)
  - Vista Lista: FlatList cronologica de eventos
- **Controles:**
  - Navegacion mes anterior/siguiente
  - Filtro de status: All/Cotizado/Confirmado/Completado/Cancelado
  - Busqueda (`.searchable`)
- **Seleccion de dia:** Muestra eventos del dia en lista inferior
- **Tapping evento:** Navega a EventDetailView

---

### 11.4 Eventos (3 pantallas)

#### EventFormView (Wizard de 5 pasos)

**Fuente RN:** `mobile/src/screens/events/EventFormScreen.tsx`

El formulario mas complejo de la app. 5 pasos en `TabView(.page)`:

**Paso 1 — General:**
- Cliente picker (busqueda + boton "Agregar Cliente Rapido" via sheet)
- Fecha (DatePicker)
- Hora inicio / Hora fin (DatePicker en modo time)
- Tipo de servicio (texto libre)
- Numero de personas
- Status (Cotizado/Confirmado/Completado/Cancelado)
- Ubicacion (texto)
- Ciudad (texto)
- Notas

**Paso 2 — Productos:**
- Lista de productos agregados (nombre, cantidad, precio unitario, descuento)
- Boton "Agregar Producto" → sheet con lista de productos del catalogo
- Busqueda de productos
- Edicion inline de cantidad, precio, descuento
- Subtotal automatico

**Paso 3 — Extras:**
- Lista de extras (descripcion, costo, precio, excluir utilidad toggle)
- Agregar extras libre

**Paso 4 — Equipo e Insumos:**
- **Equipo sugerido** basado en recetas de productos seleccionados
- **Deteccion de conflictos** — POST `/events/equipment/conflicts`
  - Si equipo ya esta reservado en esa fecha, muestra alerta con evento conflictivo
- **Insumos sugeridos** — POST `/events/supplies/suggestions`
  - Calcula cantidades basado en recetas × personas
- Fuente de insumo: stock vs compra
- Excluir costo toggle

**Paso 5 — Finanzas:**
- Descuento (% o monto fijo, toggle tipo descuento)
- IVA toggle (requires_invoice)
- Tasa de IVA (default 16%)
- Deposito % (default del perfil)
- Dias de cancelacion (default del perfil)
- Reembolso % (default del perfil)
- **Resumen financiero automatico:**
  - Subtotal productos
  - Subtotal extras
  - Descuento aplicado
  - IVA calculado
  - **Total**

**Acciones:**
- Crear: POST `/events` + PUT `/events/{id}/items`
- Editar: PUT `/events/{id}` + PUT `/events/{id}/items`

#### EventDetailView

**Fuente RN:** `mobile/src/screens/events/EventDetailScreen.tsx`

- **Header:** Status badge con `.contextMenu` para cambio rapido
- **Info del evento:** Fecha, hora, ubicacion, personas, tipo
- **Info del cliente:** Nombre, telefono (link tel:), email (link mailto:)
- **Productos:** Tabla con nombre, cantidad, precio, subtotal
- **Extras:** Tabla con descripcion, precio
- **Equipo:** Lista con nombre, cantidad, notas
- **Insumos:** Lista con nombre, cantidad, fuente (stock/compra)
- **Finanzas:** Subtotal, descuento, IVA, total
- **Pagos:**
  - Barra de progreso de cobro (total pagado / total evento)
  - Lista de pagos con fecha, metodo, monto
  - Boton "Registrar Pago" → sheet
  - Boton "Pagar Restante" (quick action)
- **Galeria de fotos:** Grid de imagenes del evento + upload
- **PDFs (6 botones):**
  - Presupuesto
  - Contrato
  - Lista de Compras
  - Checklist de Carga
  - Reporte de Pagos
  - Factura
- **Acciones:** Editar, Eliminar (con confirmacion)

#### EventChecklistView

**Fuente RN:** `mobile/src/screens/events/EventChecklistScreen.tsx`

- **4 secciones con checkboxes:**
  - Productos: nombre + cantidad
  - Equipo: nombre + cantidad + notas
  - Insumos para llevar: nombre + cantidad + unidad
  - Extras: descripcion
- Estado de checks guardado localmente (`@AppStorage` o UserDefaults)
- Persiste entre sesiones
- **Integracion Live Activity:** Progreso del checklist visible en Dynamic Island

---

### 11.5 Clientes (3 pantallas)

#### ClientListView

**Fuente RN:** `mobile/src/screens/clients/ClientListScreen.tsx`

- **Lista:** Nombre, telefono, email, avatar (foto o iniciales)
- **Header/Toolbar:** Botón "Cotización Rápida" (abre modal Quick Quote)
- **Busqueda:** `.searchable` modifier
- **Ordenamiento:** Menu con opciones:
  - Fecha actualizacion (default desc)
  - Nombre (A-Z)
  - Total eventos
  - Total gastado
  - Fecha creacion
- **Swipe actions:**
  - Trailing: Editar (azul), Eliminar (rojo)
  - Leading: Llamar (verde), Email (azul)
- **Plan limits:** Basic: 50 clientes max, Pro: ilimitado
- **Loading:** `.redacted(reason: .placeholder)` skeleton
- **Empty state:** Ilustracion + "No hay clientes aun" + CTA
- **FAB:** Boton + para nuevo cliente

#### ClientFormView

**Fuente RN:** `mobile/src/screens/clients/ClientFormScreen.tsx`

- SwiftUI Form con secciones:
  - Foto: PhotosPicker circular con crop
  - Nombre (requerido)
  - Telefono (requerido, 10+ digitos)
  - Email (opcional)
  - Direccion (opcional)
  - Ciudad (opcional)
  - Notas (opcional, TextEditor)
- Modo crear/editar detectado por presencia de clientId
- Validacion inline con `@FocusState`

#### ClientDetailView

**Fuente RN:** `mobile/src/screens/clients/ClientDetailScreen.tsx`

- **Header:** Avatar grande + nombre + contacto
- **Acciones directas:** Boton llamar (tel:), boton email (mailto:)
- **Estadisticas:** Total eventos, Total gastado (KPI cards)
- **Historial de eventos:** Lista de todos los eventos con este cliente
  - Status badge, fecha, tipo
  - Touch → EventDetailView
- **Acciones:** Editar, Eliminar (con confirmacion)
- `.refreshable` para pull-to-refresh

---

### 11.6 Productos (3 pantallas)

#### ProductListView

**Fuente RN:** `mobile/src/screens/catalog/ProductListScreen.tsx`

- **Grid/Lista** toggle
- Cada producto: imagen, nombre, categoria, precio base
- **Busqueda** por nombre
- **Filtro por categoria** (chips)
- **Ordenamiento:** Nombre, Precio, Categoria
- **Swipe actions:** Editar, Eliminar
- **Plan limits:** Basic: 20 items max
- **FAB:** Nuevo producto

#### ProductFormView

**Fuente RN:** `mobile/src/screens/catalog/ProductFormScreen.tsx`

- Nombre (requerido)
- Categoria (autocompletado de existentes)
- Precio base
- Imagen (PhotosPicker)
- Activo toggle
- **Receta/Ingredientes:**
  - Agregar ingredientes del inventario
  - Cantidad requerida por unidad
  - Equipo necesario con capacidad
  - "Llevar al evento" toggle
- **Acciones:** PUT `/products/{id}/ingredients` para actualizar receta

#### ProductDetailView

**Fuente RN:** `mobile/src/screens/catalog/ProductDetailScreen.tsx`

- Info: Imagen, nombre, categoria, precio, estado activo
- **Forecast de demanda** (Swift Charts):
  - Proximos eventos que usan este producto
  - Cantidades proyectadas por evento
  - Personas por evento
- **Receta:** Lista de ingredientes con cantidades
- **Acciones:** Editar, Eliminar

---

### 11.7 Inventario (3 pantallas)

#### InventoryListView

**Fuente RN:** `mobile/src/screens/catalog/InventoryListScreen.tsx`

- **SectionList** por tipo: Ingredientes, Equipo, Insumos
- Cada item: nombre, stock actual, stock minimo, indicador de estado
- **Indicador rojo** si current_stock < minimum_stock
- **Busqueda** por nombre
- **Toggle "Solo Stock Bajo"**
- **Ordenamiento:** Nombre, Stock actual, Stock minimo, Costo unitario
- **Swipe actions:** Editar, Eliminar
- **Ajuste manual de stock** via sheet (increment/decrement)

#### InventoryFormView

**Fuente RN:** `mobile/src/screens/catalog/InventoryFormScreen.tsx`

- Nombre (requerido)
- Tipo selector: Ingrediente / Equipo / Insumo
- Stock actual (requerido)
- Stock minimo
- Unidad (picker agrupado):
  - Peso: kg, g, oz, lb
  - Volumen: L, ml, galon
  - Conteo: piezas, unidades, docenas, porciones
- Costo unitario (opcional)

#### InventoryDetailView

**Fuente RN:** `mobile/src/screens/catalog/InventoryDetailsScreen.tsx`

- Info completa del item
- Indicador de stock (verde/rojo)
- Fecha de ultima actualizacion
- **Ajuste de stock** modal (sheet)
- **Acciones:** Editar, Eliminar

---

### 11.8 Busqueda (1 pantalla)

**Fuente RN:** `mobile/src/screens/home/SearchScreen.tsx`

- `.searchable` modifier con auto-focus
- Busqueda global via GET `/search?q={query}`
- Resultados agrupados por tipo:
  - Clientes (icono person.2)
  - Eventos (icono calendar)
  - Productos (icono shippingbox)
  - Inventario (icono archivebox)
- Touch en resultado → navega al detalle correspondiente
- **Mejora nativa:** Core Spotlight indexing para busqueda desde iOS system search

---

### 11.9 Ajustes (8 pantallas)

#### SettingsView

**Fuente RN:** `mobile/src/screens/profile/SettingsScreen.tsx`

SwiftUI Form con secciones agrupadas:

- **Cuenta:**
  - Avatar + Nombre + Email
  - Plan badge (Basic/Pro)
  - → Edit Profile
  - → Change Password

- **Negocio:**
  - → Business Settings
  - → Contract Defaults

- **Suscripcion:**
  - → Pricing/Plans

- **Preferencias:**
  - Dark mode toggle (`@AppStorage("appearance")`)
  - Biometric unlock toggle (NUEVO)

- **Legal:**
  - → About
  - → Privacy Policy
  - → Terms of Service

- **Acciones:**
  - Sincronizar datos
  - Cerrar Sesion (destructivo, con confirmacion)

#### EditProfileView
- Nombre (Form, requerido, 2+ chars)
- PUT `/users/me`

#### ChangePasswordView
- Password actual, nuevo, confirmar
- POST `/auth/change-password`

#### BusinessSettingsView

**Fuente RN:** `mobile/src/screens/profile/BusinessSettingsScreen.tsx`

- **Nombre de negocio** (opcional)
- **Color de marca:** ColorPicker nativo de SwiftUI (reemplaza los 8 swatches del RN)
  - Preset swatches: `#C4A265`, `#007AFF`, `#2D6A4F`, `#FF3B30`, `#FF9500`, `#AF52DE`, `#5856D6`, `#000000`
  - Custom hex tambien disponible
- **Logo:** PhotosPicker para upload (2MB max, crop cuadrado)
  - Display de logo actual
  - Opcion de remover
- **Toggle:** Mostrar nombre de negocio en PDFs

#### ContractDefaultsView

**Fuente RN:** `mobile/src/screens/profile/ContractDefaultsScreen.tsx`

- Deposito default % (0-100)
- Dias de cancelacion (0-365)
- Reembolso default % (0-100)
- **Plantilla de contrato:**
  - TextEditor multilinea
  - Plantilla default provista
  - Placeholders soportados ({client_name}, {event_date}, etc.)
  - Hints de placeholders disponibles

#### PricingView

**Fuente RN:** `mobile/src/screens/profile/PricingScreen.tsx`

- **Comparacion de planes:**
  - **Basic (Gratis):** 3 eventos/mes, 50 clientes, 20 items catalogo, PDFs, calendario
  - **Pro (Pago):** Ilimitado todo, control de pagos, analytics avanzados, soporte prioritario
- **StoreKit 2 UI:**
  - Boton de compra con precio localizado
  - Opcion mensual + anual (NUEVO)
  - Indicador de plan actual
  - Restaurar compras
  - Family Sharing badge
- **RevenueCat:** Posting de receipt en background para analytics

#### AboutView, PrivacyPolicyView, TermsView
- Contenido estatico con scroll
- Version de la app via `Bundle.main.infoDictionary`

---

## 12. Mejoras Nativas Exclusivas

Estas capacidades son **imposibles o impracticas** en React Native y justifican la reescritura:

### 12.1 WidgetKit (Home Screen + Lock Screen + StandBy)

#### Widget de Proximos Eventos

| Tamano | Contenido |
|--------|-----------|
| **Small** (systemSmall) | Proximo evento: fecha, cliente, status badge |
| **Medium** (systemMedium) | Proximos 2-3 eventos con fecha, cliente, tipo |
| **Large** (systemLarge) | Vista semanal con dots + lista de proximos |

#### Widget de KPIs

| Tamano | Contenido |
|--------|-----------|
| **Small** | Revenue del mes (numero grande) |
| **Medium** | Revenue + eventos + stock bajo |

#### Lock Screen Widgets

| Tipo | Contenido |
|------|-----------|
| **Circular** (accessoryCircular) | Dias hasta proximo evento |
| **Rectangular** (accessoryRectangular) | Proximo evento: cliente + fecha |
| **Inline** (accessoryInline) | "3 eventos esta semana" |

#### StandBy Mode (iOS 17+)
- Formato reloj con countdown al proximo evento

#### Interactive Widgets (iOS 17+)
- Marcar evento como "completado" directamente desde widget
- Quick-add pago desde widget

**Data flow:** App escribe datos en App Group shared `UserDefaults` → Widget lee de ahi → Timeline refresh cada 15 min o on-demand via `WidgetCenter.shared.reloadTimelines(ofKind:)`

### 12.2 Live Activities + Dynamic Island

**Activacion:** Cuando un evento esta ocurriendo (entre `start_time` y `end_time`)

| Surface | Contenido |
|---------|-----------|
| **Dynamic Island compact** | Timer del evento + nombre del cliente |
| **Dynamic Island expanded** | Detalles completos del evento + progreso del checklist |
| **Lock Screen** | Countdown/progress bar del evento |

**Trigger:** La app detecta que un evento de hoy esta en rango horario y activa el Live Activity.

### 12.3 App Intents + Siri Shortcuts

```swift
struct CreateEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Crear Evento"

    @Parameter(title: "Cliente") var clientName: String
    @Parameter(title: "Fecha") var date: Date

    func perform() async throws -> some IntentResult {
        // Navega a EventFormView con datos prellenados
    }
}

struct ShowUpcomingEventsIntent: AppIntent {
    static var title: LocalizedStringResource = "Mostrar Proximos Eventos"

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let events = try await eventRepository.getUpcoming()
        return .result(dialog: "Tienes \(events.count) eventos proximos")
    }
}

struct EventCountIntent: AppIntent {
    static var title: LocalizedStringResource = "Eventos Este Mes"
    // Returns count dialog
}

struct GenerateBudgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Generar Presupuesto"
    @Parameter(title: "Evento") var eventName: String
    // Generates and shares PDF
}

struct CheckInventoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Revisar Inventario"
    // Returns low stock items
}
```

Estos intents aparecen automaticamente en la app Shortcuts y como sugerencias de Siri.

### 12.4 Core Spotlight Indexing

```swift
// Indexar todas las entidades buscables
func indexClient(_ client: Client) {
    let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
    attributeSet.title = client.name
    attributeSet.contentDescription = [client.phone, client.email, client.city]
        .compactMap { $0 }.joined(separator: " - ")
    attributeSet.phoneNumbers = [client.phone]

    let item = CSSearchableItem(
        uniqueIdentifier: "client-\(client.id)",
        domainIdentifier: "com.creapolis.solennix.clients",
        attributeSet: attributeSet
    )
    CSSearchableIndex.default().indexSearchableItems([item])
}
```

Entidades indexadas: Clientes (nombre, telefono, email, ciudad), Eventos (tipo, cliente, fecha, status), Productos (nombre, categoria, precio), Inventario (nombre, tipo).

### 12.5 Quick Actions (Home Screen Long Press)

```swift
UIApplicationShortcutItem(type: "newEvent",
    localizedTitle: "Nuevo Evento",
    localizedSubtitle: nil,
    icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"))

UIApplicationShortcutItem(type: "search",
    localizedTitle: "Buscar",
    icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"))

UIApplicationShortcutItem(type: "calendar",
    localizedTitle: "Calendario",
    icon: UIApplicationShortcutIcon(systemImageName: "calendar"))

UIApplicationShortcutItem(type: "newClient",
    localizedTitle: "Nuevo Cliente",
    icon: UIApplicationShortcutIcon(systemImageName: "person.badge.plus"))
```

### 12.6 Focus Filters

```swift
struct SolennixFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "Solennix"

    @Parameter(title: "Mostrar notificaciones de eventos")
    var showEventNotifications: Bool

    func perform() async throws -> some IntentResult {
        // Configura que notificaciones mostrar segun Focus mode
    }
}
```

### 12.7 Keyboard Shortcuts (iPad/Mac)

```swift
.keyboardShortcut("n", modifiers: .command)         // Nuevo Evento
.keyboardShortcut("n", modifiers: [.command, .shift]) // Nuevo Cliente
.keyboardShortcut("f", modifiers: .command)           // Buscar
.keyboardShortcut("1", modifiers: .command)           // Tab Inicio
.keyboardShortcut("2", modifiers: .command)           // Tab Calendario
.keyboardShortcut("3", modifiers: .command)           // Tab Clientes
.keyboardShortcut("4", modifiers: .command)           // Tab Mas
.keyboardShortcut("p", modifiers: .command)           // Generar PDF
.keyboardShortcut(",", modifiers: .command)           // Ajustes
.keyboardShortcut("r", modifiers: .command)           // Refrescar datos
```

### 12.8 TipKit (Reemplaza Onboarding Custom)

```swift
struct AddFirstClientTip: Tip {
    var title: Text { Text("Agrega tu primer cliente") }
    var message: Text? { Text("Los clientes te permiten crear cotizaciones rapidamente") }
    var image: Image? { Image(systemName: "person.badge.plus") }

    var rules: [Rule] {
        #Rule(Self.$clientCount) { $0 == 0 }
    }

    @Parameter static var clientCount: Int = 0
}
```

### 12.9 Biometric Authentication (Face ID / Touch ID)

```swift
func authenticateWithBiometrics() async throws -> Bool {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        return false
    }

    return try await context.evaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        localizedReason: "Desbloquea Solennix"
    )
}
```

- Activable en Settings
- Se ejecuta al abrir la app si esta habilitado
- Fallback a password del dispositivo

---

## 13. Capa de Datos

### 13.1 Modelos Swift (Codable)

Mapeados directamente desde `mobile/src/types/entities.ts`:

```swift
// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    var businessName: String?
    var logoUrl: String?
    var brandColor: String?
    var showBusinessNameInPdf: Bool?
    var defaultDepositPercent: Double?
    var defaultCancellationDays: Double?
    var defaultRefundPercent: Double?
    var contractTemplate: String?
    let plan: Plan
    var stripeCustomerId: String?
    let createdAt: String
    let updatedAt: String

    enum Plan: String, Codable {
        case basic, premium
    }

    enum CodingKeys: String, CodingKey {
        case id, email, name, plan
        case businessName = "business_name"
        case logoUrl = "logo_url"
        case brandColor = "brand_color"
        case showBusinessNameInPdf = "show_business_name_in_pdf"
        case defaultDepositPercent = "default_deposit_percent"
        case defaultCancellationDays = "default_cancellation_days"
        case defaultRefundPercent = "default_refund_percent"
        case contractTemplate = "contract_template"
        case stripeCustomerId = "stripe_customer_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Client
struct Client: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let phone: String
    var email: String?
    var address: String?
    var city: String?
    var notes: String?
    var photoUrl: String?
    var totalEvents: Int?
    var totalSpent: Double?
    let createdAt: String
    let updatedAt: String
    // CodingKeys with snake_case mapping...
}

// MARK: - Event
struct Event: Codable, Identifiable {
    let id: String
    let userId: String
    let clientId: String
    let eventDate: String
    var startTime: String?
    var endTime: String?
    let serviceType: String
    let numPeople: Int
    let status: EventStatus
    let discount: Double
    let discountType: DiscountType
    let requiresInvoice: Bool
    let taxRate: Double
    let taxAmount: Double
    let totalAmount: Double
    var location: String?
    var city: String?
    var depositPercent: Double?
    var cancellationDays: Double?
    var refundPercent: Double?
    var notes: String?
    var photos: String?  // JSON array of URLs
    let createdAt: String
    let updatedAt: String

    enum EventStatus: String, Codable {
        case quoted, confirmed, completed, cancelled
    }
    enum DiscountType: String, Codable {
        case percent, fixed
    }
    // CodingKeys...
}

// MARK: - Product
struct Product: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let category: String
    let basePrice: Double
    var recipe: AnyCodable?  // JSON
    var imageUrl: String?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    // CodingKeys...
}

// MARK: - InventoryItem
struct InventoryItem: Codable, Identifiable {
    let id: String
    let userId: String
    let ingredientName: String
    let currentStock: Double
    let minimumStock: Double
    let unit: String
    var unitCost: Double?
    let lastUpdated: String
    let type: InventoryType

    enum InventoryType: String, Codable {
        case ingredient, equipment, supply
    }
    // CodingKeys...
}

// MARK: - Junction Types
struct EventProduct: Codable, Identifiable { /* ... */ }
struct EventExtra: Codable, Identifiable { /* ... */ }
struct EventEquipment: Codable, Identifiable { /* ... */ }
struct EventSupply: Codable, Identifiable { /* ... */ }
struct ProductIngredient: Codable, Identifiable { /* ... */ }
struct Payment: Codable, Identifiable { /* ... */ }
struct EquipmentConflict: Codable { /* ... */ }
struct SupplySuggestion: Codable, Identifiable { /* ... */ }
struct EquipmentSuggestion: Codable, Identifiable { /* ... */ }
```

**JSONDecoder configurado globalmente:**
```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

### 13.2 APIClient (Actor-based)

```swift
actor APIClient {
    private let session: URLSession
    private let baseURL: URL
    private let authManager: AuthManager

    init(baseURL: URL, authManager: AuthManager) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.baseURL = baseURL
        self.authManager = authManager
    }

    func get<T: Decodable>(_ endpoint: String,
                            params: [String: String]? = nil) async throws -> T {
        let request = try await buildRequest(endpoint, method: "GET", params: params)
        return try await execute(request)
    }

    func post<T: Decodable>(_ endpoint: String,
                             body: some Encodable) async throws -> T {
        var request = try await buildRequest(endpoint, method: "POST")
        request.httpBody = try JSONEncoder().encode(body)
        return try await execute(request)
    }

    func put<T: Decodable>(_ endpoint: String,
                            body: some Encodable) async throws -> T {
        var request = try await buildRequest(endpoint, method: "PUT")
        request.httpBody = try JSONEncoder().encode(body)
        return try await execute(request)
    }

    func delete(_ endpoint: String) async throws {
        let request = try await buildRequest(endpoint, method: "DELETE")
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }

    func upload(_ endpoint: String, fileURL: URL) async throws -> UploadResponse {
        var request = try await buildRequest(endpoint, method: "POST")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)",
                        forHTTPHeaderField: "Content-Type")
        let body = try createMultipartBody(fileURL: fileURL, boundary: boundary)
        request.httpBody = body
        return try await execute(request)
    }

    // Token refresh automatico en 401 (thread-safe via actor)
    private var isRefreshing = false

    private func execute<T: Decodable>(_ request: URLRequest,
                                        isRetry: Bool = false) async throws -> T {
        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 401, !isRetry {
            // Intentar refresh
            let refreshed = try await authManager.refreshToken()
            if refreshed {
                var retryRequest = request
                let token = try await authManager.getAccessToken()
                retryRequest.setValue("Bearer \(token)",
                                    forHTTPHeaderField: "Authorization")
                return try await execute(retryRequest, isRetry: true)
            }
            // Refresh fallido → logout
            await authManager.clearTokens()
            throw APIError.unauthorized
        }

        try validateResponse(response)

        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 204 {
            // swiftlint:disable:next force_cast
            return EmptyResponse() as! T
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
```

### 13.3 Endpoints API Completos

Todos los endpoints del backend Go que la app nativa consume:

```swift
enum Endpoint {
    // Auth
    static let register = "/auth/register"
    static let login = "/auth/login"
    static let logout = "/auth/logout"
    static let refresh = "/auth/refresh"
    static let forgotPassword = "/auth/forgot-password"
    static let resetPassword = "/auth/reset-password"
    static let me = "/auth/me"
    static let changePassword = "/auth/change-password"
    static let appleAuth = "/auth/apple"  // NUEVO

    // Clients
    static let clients = "/clients"
    static func client(_ id: String) -> String { "/clients/\(id)" }

    // Events
    static let events = "/events"
    static let upcomingEvents = "/events/upcoming"
    static func event(_ id: String) -> String { "/events/\(id)" }
    static func eventProducts(_ id: String) -> String { "/events/\(id)/products" }
    static func eventExtras(_ id: String) -> String { "/events/\(id)/extras" }
    static func eventItems(_ id: String) -> String { "/events/\(id)/items" }
    static func eventEquipment(_ id: String) -> String { "/events/\(id)/equipment" }
    static func eventSupplies(_ id: String) -> String { "/events/\(id)/supplies" }
    static let equipmentConflicts = "/events/equipment/conflicts"
    static let equipmentSuggestions = "/events/equipment/suggestions"
    static let supplySuggestions = "/events/supplies/suggestions"

    // Products
    static let products = "/products"
    static func product(_ id: String) -> String { "/products/\(id)" }
    static func productIngredients(_ id: String) -> String { "/products/\(id)/ingredients" }
    static let batchIngredients = "/products/ingredients/batch"

    // Inventory
    static let inventory = "/inventory"
    static func inventoryItem(_ id: String) -> String { "/inventory/\(id)" }

    // Payments
    static let payments = "/payments"
    static func payment(_ id: String) -> String { "/payments/\(id)" }

    // Unavailable Dates
    static let unavailableDates = "/unavailable-dates"
    static func unavailableDate(_ id: String) -> String { "/unavailable-dates/\(id)" }

    // Search
    static let search = "/search"

    // Uploads
    static let uploadImage = "/uploads/image"

    // User Profile
    static let updateProfile = "/users/me"

    // Subscriptions
    static let subscriptionStatus = "/subscriptions/status"

    // Device Registration (NUEVO)
    static let registerDevice = "/devices/register"
    static let unregisterDevice = "/devices/unregister"
}
```

### 13.4 Estrategia de Cache (SwiftData)

```swift
@Model
class CachedClient {
    @Attribute(.unique) var id: String
    var name: String
    var phone: String
    var email: String?
    var photoUrl: String?
    var totalEvents: Int
    var totalSpent: Double
    var lastSynced: Date  // Para calcular staleness

    init(from apiClient: Client) {
        self.id = apiClient.id
        self.name = apiClient.name
        // ... map all fields
        self.lastSynced = Date()
    }
}
```

**Reglas de cache:**
- Listas: validas por 5 minutos
- Detalles: validos por 1 minuto
- Escrituras: API first, luego actualizar cache
- Background refresh al cambiar `.scenePhase`
- Banner visual cuando esta offline (via `NWPathMonitor`)

---

## 14. Flujo de Autenticacion

### 14.1 Flujo Actual (RN) → Nativo

1. App abre → Check Keychain por tokens almacenados
2. **Gate biometrico** (si habilitado): Prompt Face ID / Touch ID
3. Validar token con `GET /auth/me`
4. Si 401 → Intentar refresh con `POST /auth/refresh`
5. Si refresh falla → Limpiar Keychain, mostrar LoginView
6. Si exito → Set user state, inicializar RevenueCat

### 14.2 Sign in with Apple (NUEVO)

```swift
struct AppleSignInButton: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                handleAuthorization(authorization)
            case .failure(let error):
                handleError(error)
            }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 50)
        .cornerRadius(10)
    }
}
```

**Backend flow:**
1. Cliente envia `identity_token` + `authorization_code` + `full_name` a `POST /auth/apple`
2. Backend verifica token con Apple's public keys
3. Busca usuario por Apple User ID o email
4. Si no existe → crea cuenta nueva
5. Si existe → vincula Apple ID a cuenta existente
6. Retorna JWT tokens (mismos que login normal)

### 14.3 Biometric Unlock

- Guardado en `@AppStorage("biometricEnabled")`
- Al activar, verifica que el dispositivo soporta biometria
- Al abrir la app, si habilitado, muestra blur overlay + prompt biometrico
- Fallback a re-login si biometria falla 3 veces

---

## 15. Suscripciones

### Modelo Hibrido: StoreKit 2 (Cliente) + RevenueCat (Backend)

#### Cliente (StoreKit 2)

```swift
@Observable
class SubscriptionManager {
    var isPremium: Bool = false
    var currentPlan: Plan = .basic
    var availableProducts: [Product] = []
    var currentSubscription: Product.SubscriptionInfo?

    // Cargar productos de App Store Connect
    func loadProducts() async {
        let productIds = [
            "com.creapolis.solennix.pro_monthly",
            "com.creapolis.solennix.pro_annual"  // NUEVO
        ]
        availableProducts = try? await Product.products(for: Set(productIds))
    }

    // Comprar con StoreKit 2
    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await syncWithRevenueCat(transaction)
            return transaction
        case .userCancelled:
            throw SubscriptionError.cancelled
        case .pending:
            throw SubscriptionError.pending
        }
    }

    // Restaurar compras
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                updateEntitlements(transaction)
            }
        }
    }

    // Escuchar updates de transacciones
    func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                updateEntitlements(transaction)
                await syncWithRevenueCat(transaction)
            }
        }
    }

    // Sync con RevenueCat backend
    private func syncWithRevenueCat(_ transaction: Transaction) async {
        // Post receipt a RevenueCat para analytics
        Purchases.shared.syncPurchases { customerInfo, error in
            // RevenueCat actualiza su dashboard
        }
    }
}
```

#### Tiers

| Plan | Precio | Producto App Store Connect | Features |
|------|--------|--------------------------|----------|
| **Basic** | Gratis | — | 3 eventos/mes, 50 clientes, 20 items |
| **Pro Mensual** | $99 MXN/mes | `com.creapolis.solennix.pro_monthly` | Ilimitado todo |
| **Pro Anual** (NUEVO) | $899 MXN/ano (~25% descuento) | `com.creapolis.solennix.pro_annual` | Ilimitado todo |

#### RevenueCat Backend

- Mantener webhook existente `POST /subscriptions/webhook/revenuecat`
- RevenueCat SDK en cliente SOLO para `Purchases.shared.logIn(userId)` y `syncPurchases()`
- Dashboard de RevenueCat sigue funcionando para analytics de revenue
- NO usar RevenueCat para UI de compra (StoreKit 2 nativo)

---

## 16. Generacion de PDFs

### 6 tipos de PDF replicados con UIGraphicsPDFRenderer

Cada PDF replica exactamente el contenido y layout del HTML generado en `mobile/src/lib/pdfGenerator.ts`, pero renderizado en vectorial nativo.

#### 16.1 Presupuesto (Budget PDF)

**Secciones:**
1. **Header:** Logo (si existe) + nombre de negocio (si habilitado) + titulo "Presupuesto"
2. **Grid de info:** Cliente, telefono, email, fecha, horario, personas
3. **Tabla de productos:** Descripcion, cantidad, precio unitario, total (qty * price - discount)
4. **Tabla de extras:** Descripcion, cantidad (1), precio, total
5. **Resumen financiero:** Subtotal, descuento (si aplica), IVA (si aplica), **Total**
6. **Footer:** "Este presupuesto tiene una validez de 15 dias."

**Formato moneda:** `NumberFormatter` con locale `es_MX`, currency `MXN`

#### 16.2 Contrato (Contract PDF)

**Secciones:**
1. **Header:** Logo + nombre + titulo "Contrato de Servicios"
2. **Cuerpo:** Renderizado desde `profile.contract_template` con variables reemplazadas
3. **Firmas:** Dos cajas lado a lado — "EL PROVEEDOR" + "EL CLIENTE"

#### 16.3 Lista de Compras (Shopping List PDF)

**Secciones:**
1. **Header:** Logo + nombre + titulo "Lista de Insumos"
2. **Info del evento:** Tipo, fecha, personas
3. **Tabla:** Insumo, cantidad (2 decimales), unidad

#### 16.4 Checklist de Carga (Checklist PDF)

**Secciones:**
1. **Header:** Logo + nombre + titulo "Checklist de Carga"
2. **Info del evento:** Tipo, fecha, hora, cliente, lugar
3. **Productos:** Checkbox + nombre + cantidad
4. **Equipo:** Checkbox + nombre + cantidad + notas
5. **Insumos para llevar:** Checkbox + nombre + cantidad + unidad
6. **Extras:** Checkbox + descripcion
7. **Notas:** Dos lineas en blanco para notas manuscritas

#### 16.5 Reporte de Pagos (Payment Report PDF)

**Secciones:**
1. **Header:** Logo + nombre + titulo "Reporte de Pagos"
2. **Info:** Cliente, evento, fecha, total del evento
3. **Tabla de pagos:** Fecha, metodo (traducido), nota, monto
4. **Resumen:** Total pagado, saldo pendiente (rojo) o completado (verde)
5. **Firma:** Caja con nombre del negocio

**Traduccion de metodos:** cash→Efectivo, transfer→Transferencia, card→Tarjeta, check→Cheque, other→Otro

#### 16.6 Factura (Invoice PDF)

**Secciones:**
1. **Header:** Logo + nombre + titulo "Factura"
2. **Metadatos:** No. factura (`INV-{eventId[0:8]}`), fecha emision
3. **Emisor:** Razon social, email, RFC (pendiente), regimen fiscal (pendiente)
4. **Receptor:** Cliente, telefono, email, direccion
5. **Evento:** Fecha, servicio, personas, ubicacion
6. **Conceptos:** Descripcion, cantidad, precio unitario, descuento, subtotal
7. **Resumen:** Subtotal, descuento, IVA, **TOTAL** (con color de marca)
8. **Footer:** Forma de pago, nota sobre factura simplificada, fecha de generacion

#### Implementacion Nativa

```swift
struct PDFGenerator {
    let profile: User?
    let brandColor: UIColor

    func generateBudget(event: Event, client: Client,
                        products: [EventProduct], extras: [EventExtra]) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        return renderer.pdfData { context in
            context.beginPage()
            drawHeader(in: context, title: "Presupuesto")
            drawClientInfo(in: context, client: client, event: event)
            drawProductsTable(in: context, products: products)
            drawExtrasTable(in: context, extras: extras)
            drawFinancialSummary(in: context, event: event)
            drawFooter(in: context, text: "Este presupuesto tiene una validez de 15 dias.")
        }
    }
    // ... otros 5 generadores con patron similar
}
```

**Compartir:**
```swift
ShareLink(item: pdfData, preview: SharePreview("Presupuesto", image: Image(systemName: "doc.fill")))
```

---

## 17. Gestion de Fotos

### Reemplazos nativos

| RN (actual) | SwiftUI (nativo) |
|-------------|-----------------|
| expo-image-picker | PhotosPicker (PhotosUI) |
| expo-file-system upload | URLSession.uploadTask |
| expo-image-manipulator (crop) | CIFilter / CoreImage |
| expo-image (display) | AsyncImage + Kingfisher |

### PhotosPicker

```swift
@State private var selectedPhotos: [PhotosPickerItem] = []

PhotosPicker(selection: $selectedPhotos,
             maxSelectionCount: 10,
             matching: .images) {
    Label("Agregar Fotos", systemImage: "photo.on.rectangle.angled")
}
.onChange(of: selectedPhotos) { items in
    Task {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await uploadImage(data)
            }
        }
    }
}
```

### Background upload

```swift
func uploadImage(_ data: Data) async throws -> UploadResponse {
    // URLSession background upload sigue funcionando cuando la app esta en background
    let task = session.uploadTask(with: request, from: multipartData)
    task.resume()
}
```

---

## 18. Notificaciones Push

### Arquitectura

```
[App] → POST /devices/register {token, platform: "ios"} → [Backend Go]
[Backend Go] → APNs → [Dispositivo iOS]
```

### Tipos de notificaciones

| Tipo | Trigger | Contenido | Categoria |
|------|---------|-----------|-----------|
| Event Reminder (1 dia) | Cron job diario | "Manana: {evento} con {cliente}" | `eventReminder` |
| Event Reminder (1 hora) | Cron job por hora | "En 1 hora: {evento}" | `eventReminder` |
| Payment Received | Al registrar pago | "Pago de ${monto} recibido para {evento}" | `paymentReceived` |
| Low Stock Alert | Al bajar de minimo | "{item} esta bajo: {stock}/{minimo}" | `stockAlert` |
| Subscription Change | Webhook | "Tu plan ha sido actualizado" | `subscription` |

### Notification Categories (Quick Actions)

```swift
let eventReminderCategory = UNNotificationCategory(
    identifier: "eventReminder",
    actions: [
        UNNotificationAction(identifier: "viewEvent", title: "Ver Evento"),
        UNNotificationAction(identifier: "openChecklist", title: "Checklist")
    ],
    intentIdentifiers: []
)

let paymentCategory = UNNotificationCategory(
    identifier: "paymentReceived",
    actions: [
        UNNotificationAction(identifier: "viewPayment", title: "Ver Pago"),
        UNNotificationAction(identifier: "viewEvent", title: "Ver Evento")
    ],
    intentIdentifiers: []
)
```

### Rich Notifications

- Event reminder con imagen del evento (si tiene foto)
- Notification grouping por tipo (threading identifier)

---

## 19. Accesibilidad

### VoiceOver

- Todas las pantallas auditadas para VoiceOver
- Labels significativos en todos los elementos interactivos
- Hints para acciones no obvias
- Traits correctos (.button, .header, .image, etc.)

### Dynamic Type

- Todas las fuentes via `.font()` de SwiftUI — escalan automaticamente
- Layouts adaptables que no se rompen con texto grande
- `.minimumScaleFactor` solo donde sea estrictamente necesario

### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    // animacion
}
```

### Custom Rotors

```swift
.accessibilityRotor("Eventos por status") {
    ForEach(events.filter { $0.status == .confirmed }) { event in
        AccessibilityRotorEntry(event.serviceType, id: event.id)
    }
}
```

### Contraste

- Minimo 4.5:1 en todos los textos
- High contrast variants en Asset Catalog
- Testeo automatico con XCUITest accessibility audit

---

## 20. Localizacion

### String Catalogs

- Formato: `.xcstrings` (String Catalogs de Xcode 15+)
- Idioma base: **Espanol (Mexico)** — `es-MX`
- Preparado para expansion futura: English (`en`), Portugues Brasil (`pt-BR`)
- Todas las cadenas user-facing extraidas con macro `String(localized:)`

### Formato de datos

```swift
// Moneda
let currencyFormat = Decimal.FormatStyle.Currency(code: "MXN", locale: Locale(identifier: "es_MX"))
// Resultado: $1,234.56

// Fechas
let dateFormat = Date.FormatStyle()
    .locale(Locale(identifier: "es_MX"))
    .day().month(.wide).year()
// Resultado: 17 de marzo de 2026

// Numeros
let numberFormat = FloatingPointFormatStyle<Double>
    .number.locale(Locale(identifier: "es_MX"))
    .precision(.fractionLength(2))
```

---

## 21. Estrategia de Testing

| Tipo | Herramienta | Target Coverage | Que testea |
|------|------------|-----------------|------------|
| **Unit Tests** | XCTest + Swift Testing | 80% ViewModels, Services | Logica de negocio, validaciones, formateo |
| **UI Tests** | XCUITest | Flujos criticos | Login, crear evento, registrar pago, generar PDF |
| **Snapshot Tests** | swift-snapshot-testing | Todas las pantallas | Light/dark, iPhone/iPad, cada pantalla |
| **Integration Tests** | XCTest + URLProtocol mock | APIClient, AuthManager | Networking, token refresh, error handling |
| **Performance Tests** | XCTest `.measure {}` | Operaciones criticas | Generacion PDF, scroll de listas, busqueda |
| **Accessibility Tests** | XCUITest accessibility audit | Todas las pantallas | VoiceOver, Dynamic Type, contraste |

### Mocking Strategy

```swift
protocol ClientRepositoryProtocol {
    func getClients() async throws -> [Client]
    func getClient(id: String) async throws -> Client
    func createClient(_ client: ClientInsert) async throws -> Client
    func updateClient(id: String, _ client: ClientUpdate) async throws -> Client
    func deleteClient(id: String) async throws
}

// Produccion
class ClientRepository: ClientRepositoryProtocol {
    let apiClient: APIClient
    // ... implementacion real
}

// Tests
class MockClientRepository: ClientRepositoryProtocol {
    var clientsToReturn: [Client] = []
    var shouldThrow: Error?
    // ... implementacion mock
}
```

---

## 22. CI/CD

### Xcode Cloud

| Trigger | Accion | Resultado |
|---------|--------|-----------|
| Push a `develop` | Build + Unit tests + Lint | Feedback en PR |
| Push a `main` | Build + All tests + Archive | TestFlight automatico |
| Tag `v*` | Build + Archive + Submit | App Store submission |

### Configuracion

```yaml
# ci_post_clone.sh
#!/bin/bash
# Instalar dependencias de Swift packages
swift package resolve

# Configurar signing
# (Xcode Cloud maneja signing automaticamente con Apple Developer account)
```

### Alternativa: Fastlane (si Xcode Cloud no es suficiente)

```ruby
lane :tests do
    scan(scheme: "Solennix", clean: true)
end

lane :beta do
    build_app(scheme: "Solennix")
    upload_to_testflight
end

lane :release do
    build_app(scheme: "Solennix")
    deliver(submit_for_review: true)
end
```

---

## 23. App Store Optimization

### Metadata

| Campo | Valor |
|-------|-------|
| **Nombre** | Solennix - Event Planner |
| **Subtitulo** | Eventos, Catering y Banquetes |
| **Categoria primaria** | Business |
| **Categoria secundaria** | Productivity |
| **Precio** | Gratis (con in-app purchases) |
| **Bundle ID** | com.creapolis.solennix |
| **Age Rating** | 4+ |

### Keywords

`eventos, catering, banquetes, cotizaciones, contratos, PDF, inventario, pagos, clientes, calendario, factura, organizador, fiestas, presupuesto, recetas`

### Screenshots requeridos

| Dispositivo | Tamano | Cantidad |
|------------|--------|----------|
| iPhone 6.7" (16 Pro Max) | 1320 x 2868 px | 6-10 |
| iPhone 6.1" (16) | 1179 x 2556 px | 6-10 |
| iPad 12.9" (Pro) | 2048 x 2732 px | 6-10 |

### Screenshots sugeridos

1. Dashboard con KPIs
2. Calendario con eventos
3. Formulario de evento (wizard)
4. Detalle de evento con PDF
5. Lista de clientes
6. Widget en Home Screen
7. Dark mode
8. iPad con sidebar

### App Preview Video

- 30 segundos maximo
- Flujo: Login → Dashboard → Crear evento → Generar PDF → Compartir
- Grabado en iPhone 16 Pro Max

### Privacy Nutrition Label

| Tipo de dato | Vinculado a identidad | Proposito |
|-------------|----------------------|-----------|
| Email | Si | Funcionalidad de la app |
| Nombre | Si | Funcionalidad de la app |
| Info de pago | Si | Compras in-app |
| Contenido del usuario | Si | Fotos, notas, eventos |

---

## 24. Plan de Migracion

### Fase 1: Publicacion Paralela

- App nativa publicada en App Store con **mismo Bundle ID** (`com.creapolis.solennix`)
- Esto reemplaza automaticamente la app RN existente via actualizacion
- Mismas credenciales de App Store Connect

### Migracion de datos

**No se necesita migracion de datos** — todos los datos viven en el servidor (PostgreSQL). El usuario:

1. Actualiza la app (o descarga nueva si no tenia la RN)
2. Se loguea con sus credenciales existentes (email/password) o Sign in with Apple
3. Todos sus datos estan inmediatamente disponibles
4. Los tokens de Keychain son nuevos (fresh login requerido)

### Migracion de suscripciones

- Suscriptores existentes via RevenueCat son auto-detectados via App Store receipt
- El backend mantiene ambos webhooks (RevenueCat + App Store) durante transicion
- RevenueCat SDK en la app nativa sincroniza estado automaticamente

### Timeline

| Semana | Accion |
|--------|--------|
| Pre-launch | TestFlight beta con usuarios internos |
| Launch | App nativa publicada, reemplaza RN via update |
| +2 semanas | Monitoreo de crash-free rate y reviews |
| +4 semanas | Evaluacion de desactivar webhook RevenueCat (si todo OK) |

---

## 25. Cambios Requeridos en Backend

### 25.1 `POST /auth/apple` — Sign in with Apple

**Request:**
```json
{
    "identity_token": "eyJhbGciOiJSUzI1NiIs...",
    "authorization_code": "c1234567890abcdef...",
    "full_name": {
        "given_name": "Juan",
        "family_name": "Perez"
    },
    "email": "juan@icloud.com"
}
```

**Logica:**
1. Verificar `identity_token` con las public keys de Apple (`https://appleid.apple.com/auth/keys`)
2. Extraer `sub` (Apple User ID) del token decodificado
3. Buscar usuario por `apple_user_id` en tabla users
4. Si no existe → buscar por `email`
   - Si existe por email → vincular `apple_user_id` a cuenta existente
   - Si no existe → crear nueva cuenta con datos provistos
5. Generar JWT tokens (access + refresh)
6. Retornar tokens + user data

**Response (200):**
```json
{
    "access_token": "eyJ...",
    "refresh_token": "eyJ...",
    "user": { /* User object */ }
}
```

**Cambios en DB:**
- Agregar columna `apple_user_id VARCHAR(255) UNIQUE` a tabla `users`
- Migration: `025_add_apple_auth.sql`

### 25.2 `POST /devices/register` — Registro de dispositivo para push

**Request:**
```json
{
    "device_token": "abc123def456...",
    "platform": "ios",
    "app_version": "1.0.0"
}
```

**Logica:**
1. Extraer `user_id` del JWT
2. Upsert en tabla `device_tokens` (user_id + device_token)
3. Si el token ya existe para otro usuario, reasignarlo

**Response (201):**
```json
{
    "id": "uuid",
    "registered": true
}
```

**Nueva tabla:**
```sql
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_token VARCHAR(255) NOT NULL,
    platform VARCHAR(10) NOT NULL DEFAULT 'ios',
    app_version VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(device_token)
);
CREATE INDEX idx_device_tokens_user ON device_tokens(user_id);
```

### 25.3 `POST /devices/unregister` — Desregistrar en logout

**Request:**
```json
{
    "device_token": "abc123def456..."
}
```

**Logica:** DELETE de tabla `device_tokens` donde `device_token` y `user_id` coinciden.

**Response:** 204 No Content

### 25.4 Push Notification Service

**Nuevo servicio Go:**

```go
type PushService struct {
    apnsClient *apns2.Client
    db         *pgxpool.Pool
}

func (s *PushService) SendEventReminder(ctx context.Context, event Event, client Client) error {
    tokens, err := s.getDeviceTokens(ctx, event.UserID)
    if err != nil { return err }

    notification := &apns2.Notification{
        DeviceToken: token,
        Topic:       "com.creapolis.solennix",
        Payload: payload.NewPayload().
            AlertTitle("Recordatorio de Evento").
            AlertBody(fmt.Sprintf("Manana: %s con %s", event.ServiceType, client.Name)).
            Category("eventReminder").
            Custom("event_id", event.ID),
    }

    for _, token := range tokens {
        notification.DeviceToken = token
        s.apnsClient.Push(notification)
    }
    return nil
}
```

**Dependencia Go:** `github.com/sideshow/apns2`

**Environment variables nuevas:**
- `APNS_KEY_ID` — Key ID del Apple Developer account
- `APNS_TEAM_ID` — Team ID
- `APNS_KEY_FILE` — Path al archivo .p8
- `APNS_TOPIC` — Bundle ID (`com.creapolis.solennix`)

### 25.5 Background Job: Event Reminders

**Cron job** (similar al existente para plan expiry):

```go
func (s *PushService) ScheduleReminders(ctx context.Context) {
    // Cada hora, buscar eventos de manana y enviar reminder de 1 dia
    tomorrow := time.Now().AddDate(0, 0, 1).Format("2006-01-02")
    events := s.db.Query("SELECT * FROM events WHERE event_date = $1 AND status IN ('quoted','confirmed')", tomorrow)

    for _, event := range events {
        s.SendEventReminder(ctx, event, event.Client)
    }

    // Buscar eventos de hoy en la proxima hora y enviar reminder de 1 hora
    // ...
}
```

### 25.6 Resumen de Migrations Nuevas

| # | Migration | Descripcion |
|---|-----------|-------------|
| 025 | `add_apple_auth` | Agrega `apple_user_id` a users |
| 026 | `create_device_tokens` | Tabla de device tokens para push |

---

## 26. Rollout por Fases

### v1: Fases 1-6 (~20 semanas)

#### Fase 1: Foundation (Semanas 1-4)

**Entregable:** App compilable con auth funcional y navegacion.

- [ ] Crear proyecto Xcode con estructura de packages
- [ ] Implementar SolennixDesign (colores, tipografia, spacing, componentes base)
- [ ] Implementar SolennixNetwork (APIClient actor, AuthManager, endpoints)
- [ ] Implementar SolennixCore (modelos Codable, protocolos, utilidades)
- [ ] Auth screens: Login, Register, Forgot/Reset Password
- [ ] Sign in with Apple (+ endpoint backend `POST /auth/apple`)
- [ ] Biometric unlock (Face ID / Touch ID)
- [ ] Navegacion: TabView (iPhone) + NavigationSplitView (iPad)
- [ ] Deep linking (`solennix://reset-password`)
- [ ] Dark mode (automatico via Asset Catalog)
- [ ] CI/CD: Xcode Cloud basico (build + test on push)

#### Fase 2: Core Screens (Semanas 5-8)

**Entregable:** Dashboard, calendario, clientes y busqueda funcionales.

- [ ] DashboardView (KPIs, Swift Charts, proximos eventos, stock bajo, onboarding TipKit)
- [ ] CalendarView (grid de mes, dots, vista dual, filtros, busqueda)
- [ ] ClientListView (busqueda, sort, swipe actions, skeleton)
- [ ] ClientFormView (PhotosPicker, validacion)
- [ ] ClientDetailView (stats, historial, contacto directo)
- [ ] SearchView (`.searchable`, resultados agrupados)
- [ ] Core Spotlight indexing (clientes, eventos)
- [ ] SwiftData setup (cache de clientes y eventos)
- [ ] Pull-to-refresh en todas las listas

#### Fase 3: Events (Semanas 9-12)

**Entregable:** Gestion completa de eventos con PDFs.

- [ ] EventFormView wizard de 5 pasos (la pantalla mas compleja)
  - [ ] Paso 1: General (client picker, date, time, location)
  - [ ] Paso 2: Productos (busqueda, agregar, precio, descuento)
  - [ ] Paso 3: Extras
  - [ ] Paso 4: Equipo/Insumos (conflict detection, suggestions)
  - [ ] Paso 5: Finanzas (discount, tax, deposit, cancellation)
- [ ] QuickClientSheet (crear cliente inline)
- [ ] EventDetailView (info completa, pagos, fotos, acciones)
- [ ] EventChecklistView (checkboxes, persistencia local)
- [ ] 6 PDF generators con UIGraphicsPDFRenderer:
  - [ ] Presupuesto
  - [ ] Contrato
  - [ ] Lista de Compras
  - [ ] Checklist de Carga
  - [ ] Reporte de Pagos
  - [ ] Factura
- [ ] ShareLink para compartir PDFs
- [ ] Photo gallery (upload + display)

#### Fase 4: Catalog & Settings (Semanas 13-15)

**Entregable:** Productos, inventario, ajustes y suscripciones.

- [ ] ProductListView (grid/list, categorias, busqueda, sort)
- [ ] ProductFormView (receta/ingredientes management)
- [ ] ProductDetailView (demand forecast con Swift Charts)
- [ ] InventoryListView (secciones por tipo, stock alerts)
- [ ] InventoryFormView (tipo, stock, unidades)
- [ ] InventoryDetailView (ajuste de stock)
- [ ] SettingsView (todas las secciones)
- [ ] BusinessSettingsView (ColorPicker nativo, logo, nombre)
- [ ] ContractDefaultsView (plantilla editable)
- [ ] PricingView (StoreKit 2 + RevenueCat hybrid)
- [ ] Plan limits enforcement (usePlanLimits equivalent)
- [ ] Core Spotlight indexing (productos, inventario)

#### Fase 5: Native Enhancements (Semanas 16-18)

**Entregable:** Features exclusivas nativas que justifican la reescritura.

- [ ] WidgetKit:
  - [ ] Upcoming Events widget (S/M/L)
  - [ ] KPI widget (S/M)
  - [ ] Lock Screen widgets (circular, rectangular, inline)
  - [ ] StandBy mode
  - [ ] Interactive widgets
- [ ] Live Activities + Dynamic Island (evento activo)
- [ ] App Intents (5 intents para Siri Shortcuts)
- [ ] Push Notifications:
  - [ ] Backend: device registration + APNs service
  - [ ] Event reminders (1 dia, 1 hora)
  - [ ] Payment received
  - [ ] Low stock alerts
  - [ ] Notification categories + quick actions
- [ ] Quick Actions (long-press icon)
- [ ] Focus Filters
- [ ] Keyboard shortcuts (iPad)

#### Fase 6: Polish & Launch (Semanas 19-20)

**Entregable:** App lista para App Store.

- [ ] iPad optimization (3-column layout, sidebar refinement)
- [ ] Accessibility audit completo (VoiceOver, Dynamic Type, contraste)
- [ ] Performance optimization (Instruments profiling)
- [ ] String Catalog review (todas las cadenas en es-MX)
- [ ] Snapshot tests (todas las pantallas, light/dark, iPhone/iPad)
- [ ] TestFlight beta (usuarios internos + beta testers)
- [ ] App Store listing (screenshots, descripcion, keywords, video)
- [ ] App Store submission
- [ ] Monitor crash-free rate y reviews post-launch

### v2: Post-Launch

| Feature | Descripcion | Prioridad |
|---------|-------------|-----------|
| Mac app nativa | SwiftUI para macOS, menu bar, ventanas multiples | Alta |
| Apple Watch | Complicacion, checklist, eventos de hoy | Media |
| App Clips | QR para pago de evento por clientes | Media |
| SharePlay | Colaboracion en FaceTime para planificacion | Baja |
| iCloud Sync | SwiftData + CloudKit cross-device | Baja |
| Offline mode completo | Queue de escrituras + sync | Media |
| i18n (English) | String Catalog traducido | Media |

---

## 27. Metricas de Exito

### Performance

| Metrica | Actual (RN) | Objetivo (Nativo) | Metodo de medicion |
|---------|-------------|-------------------|-------------------|
| Arranque en frio | ~2.5s | < 0.8s | Instruments (App Launch) |
| Tamano binario | ~45MB | < 15MB | Xcode archive |
| Scroll FPS | 45-55 fps | 60 fps constante | Instruments (Core Animation) |
| Generacion PDF | ~3s | < 0.5s | XCTest `.measure {}` |
| Crash-free rate | ~98% | > 99.5% | Sentry / App Store Connect |
| Memoria (Dashboard) | ~120MB | < 60MB | Instruments (Memory) |
| Consumo bateria | Alto (motor JS) | Bajo (nativo) | Instruments (Energy) |

### Producto

| Metrica | Objetivo | Timeline |
|---------|----------|----------|
| App Store rating | 4.7+ | 3 meses post-launch |
| Crash-free sessions | > 99.5% | Launch day |
| Widget adoption | 30% de usuarios | 3 meses |
| Siri Shortcuts usage | 15% de usuarios | 6 meses |
| Push notification opt-in | > 60% | Launch day |
| Biometric unlock adoption | > 50% | 1 mes |
| Premium conversion (StoreKit 2) | >= actual RN | 3 meses |

---

## 28. Analisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Desarrollo toma mas de lo estimado | Alta | Medio | Rollout por fases — cada fase produce app usable. Priorizar fases 1-4 para MVP funcional. |
| Bugs/limitaciones de SwiftUI en versiones especificas de iOS | Media | Medio | UIKit fallback via `UIViewRepresentable` donde sea necesario. Testear en iOS 17.0-17.7+. |
| Migracion StoreKit 2 rompe suscripciones existentes | Media | Alto | Mantener webhook RevenueCat activo durante transicion. Verificar receipts por ambas vias. Periodo de coexistencia de 4+ semanas. |
| Mac UI requiere trabajo significativo extra | Media | Bajo | Mac es v2 post-lanzamiento. Priorizar iOS + iPad. |
| Backend necesita cambios para Apple auth + push | Baja | Bajo | Solo 2-3 endpoints nuevos. Migrations simples. Dependencia Go para APNs es madura. |
| Usuarios resisten nueva app (UI diferente) | Media | Medio | Mantener lenguaje visual identico (mismos colores, mismo layout). Comunicar mejoras de performance. |
| App Store rejection | Baja | Alto | Seguir HIG estrictamente. Sign in with Apple incluido. Privacy manifest correcto. No mencionar pagos externos. |
| iOS 17 minimum excluye algunos usuarios | Baja | Bajo | Adopcion de iOS 17 es >85% a Q1 2026. Usuarios con iOS 16 siguen usando web. |
| SwiftData + CloudKit reliability | Media | Medio | CloudKit sync es v2. SwiftData solo como cache local en v1 — fallback a API siempre disponible. |

---

## 29. Apendices

### A. Modelo de Datos Completo (TypeScript → Swift Reference)

Ver `mobile/src/types/entities.ts` para tipos completos. La seccion 13.1 de este PRD contiene el mapeo a Swift Codable structs.

### B. API Endpoints Completos

Ver `backend/internal/router/router.go`. La seccion 13.3 de este PRD lista todos los endpoints como enum Swift.

### C. Database Schema

24 migrations existentes en `backend/internal/database/migrations/` + 2 nuevas (025, 026) definidas en seccion 25.

### D. Documentos de Referencia

| Documento | Ubicacion | Contenido |
|-----------|-----------|-----------|
| PRD Mobile (RN) original | `docs/mobile/PRD.md` | PRD de la app React Native |
| Brand Manual | `marketing/brand-manual/BRAND-MANUAL.md` | Identidad de marca, logo, paleta |
| UI Design Guide | `docs/design/ui-design-guide.md` | Tokens, componentes, patrones |
| System Overview | `docs/architecture/system-overview.md` | Arquitectura del sistema |
| Status / Roadmap | `docs/roadmap/status.md` | Estado actual del proyecto |
| Cross-Platform Improvements | `docs/roadmap/cross-platform-improvements.md` | Paridad web/mobile |

### E. Glosario

| Termino | Definicion |
|---------|-----------|
| **FAB** | Floating Action Button — boton flotante central para crear evento |
| **KPI** | Key Performance Indicator — metricas del dashboard |
| **HIG** | Human Interface Guidelines — guias de diseno de Apple |
| **APNs** | Apple Push Notification service |
| **StoreKit 2** | Framework de Apple para in-app purchases y suscripciones |
| **SwiftData** | Framework de persistencia de Apple (reemplaza Core Data) |
| **WidgetKit** | Framework para widgets de Home Screen, Lock Screen y StandBy |
| **App Intents** | Framework para integracion con Siri y Shortcuts |
| **Core Spotlight** | Framework para indexar contenido en la busqueda del sistema |
| **Live Activities** | Contenido en tiempo real en Lock Screen y Dynamic Island |
| **NavigationSplitView** | Vista de navegacion con sidebar para iPad y Mac |
| **TipKit** | Framework de Apple para tips contextuales de onboarding |

---

> **"CADA DETALLE IMPORTA"** — Este PRD documenta cada detalle de la app nativa Solennix.
> La excelencia en la planificacion precede la excelencia en la ejecucion.

---

*PRD v1.0 — Marzo 2026*
*Solennix Native iOS/iPadOS/macOS*
