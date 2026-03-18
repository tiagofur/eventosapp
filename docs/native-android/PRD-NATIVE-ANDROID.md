# PRD: Solennix Native — Android & Tablets

> **Version:** 1.1
> **Fecha:** 2026-03-18
> **Estado:** Feature parity alcanzada — Pendiente: QA, performance tuning, Play Store
> **Autor:** Equipo Solennix + Antigravity

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Contexto y Motivacion](#2-contexto-y-motivacion)
3. [Plataformas Objetivo](#3-plataformas-objetivo)
4. [Stack Tecnologico](#4-stack-tecnologico)
5. [Arquitectura](#5-arquitectura)
6. [Estructura Modular del Proyecto](#6-estructura-modular-del-proyecto)
7. [Estrategia de App Adaptativa](#7-estrategia-de-app-adaptativa)
8. [Sistema de Navegacion](#8-sistema-de-navegacion)
9. [Design System (SolennixDesign)](#9-design-system-solennixdesign)
10. [Matriz de Paridad de Features](#10-matriz-de-paridad-de-features)
11. [Especificacion Pantalla por Pantalla](#11-especificacion-pantalla-por-pantalla)
12. [Mejoras Nativas Android Exclusivas](#12-mejoras-nativas-android-exclusivas)
13. [Capa de Datos](#13-capa-de-datos)
14. [Flujo de Autenticacion](#14-flujo-de-autenticacion)
15. [Suscripciones (Google Play Billing + RevenueCat)](#15-suscripciones)
16. [Generacion de PDFs (Canvas/iText Nativo)](#16-generacion-de-pdfs)
17. [Gestion de Fotos](#17-gestion-de-fotos)
18. [Notificaciones Push](#18-notificaciones-push)
19. [Accesibilidad](#19-accesibilidad)
20. [Localizacion](#20-localizacion)
21. [Estrategia de Testing](#21-estrategia-de-testing)
22. [CI/CD](#22-cicd)
23. [Google Play Store Optimization](#23-google-play-store-optimization)
24. [Plan de Migracion](#24-plan-de-migracion)
25. [Cambios Requeridos en Backend](#25-cambios-requeridos-en-backend)
26. [Rollout por Fases](#26-rollout-por-fases)
27. [Metricas de Exito](#27-metricas-de-exito)
28. [Analisis de Riesgos](#28-analisis-de-riesgos)
29. [Estado de Implementacion](#29-estado-de-implementacion-marzo-2026)
30. [Apendices](#30-apendices)

---

## 1. Resumen Ejecutivo

### Que es este proyecto

App nativa **Kotlin/Jetpack Compose** para Android phones y tablets, con la misma experiencia visual y funcional que la app iOS nativa de Solennix. La app mantiene identidad visual consistente para que usuarios con ambos dispositivos no sientan un impacto al cambiar de plataforma.

### Por que nativo Android

La app actual en React Native ya cubre Android, pero tiene las mismas limitaciones del puente JavaScript que motivaron la reescritura iOS. Android nativo con Kotlin y Jetpack Compose ofrece:

| Aspecto | React Native (actual) | Kotlin/Compose (objetivo) |
|---------|----------------------|---------------------------|
| Arranque en frio | ~2.8s (Hermes + bundle) | < 1.0s (compilado nativo, baseline profiles) |
| Tamano APK | ~50MB (Hermes + deps) | < 20MB (R8 minification) |
| Frame rate en scroll | 40-50 fps (puente JS) | 60 fps constante (GPU-accelerated) |
| Generacion PDF | ~3.5s (WebView oculto) | < 0.5s (Canvas/iText nativo) |
| Memoria (Dashboard) | ~130MB | < 65MB |
| Widgets | Imposible (Glance limitado en RN) | Glance + RemoteViews completo |
| Quick Settings Tiles | Imposible | Nativo |
| Google Assistant | Imposible | App Actions first-class |
| Foldables | Imposible | WindowManager + adaptive layouts |
| Tablets | Simulado con drawer | NavigationSuiteScaffold nativo |
| Bubble notifications | Imposible | Nativo Android 11+ |

### Que se mantiene igual

- **Backend Go** (50+ endpoints REST, PostgreSQL) — sin cambios
- **App web React** — sin cambios
- **App iOS nativa** — desarrollo paralelo
- **Modelo de datos** — identico
- **Branding** — mismos colores, logo, tipografia
- **Cuentas de usuario** — mismas credenciales, mismos datos

### Que se gana

1. **Performance premium** — arranque sub-segundo, scroll a 60fps, PDFs instantaneos
2. **Ecosistema Android completo** — Widgets, Quick Settings, Google Assistant, foldables
3. **Tablets como herramienta de trabajo** — NavigationSuiteScaffold, multi-window, stylus
4. **Material You** — colores dinamicos del wallpaper, theming del sistema
5. **Tamano minimo** — sin motor JavaScript, sin bridge, sin dependencias React Native

### Consistencia Cross-Platform con iOS

**Principio fundamental:** Un usuario de Solennix debe sentirse "en casa" sin importar si usa iPhone o Android.

| Aspecto | Consistencia | Adaptacion por Plataforma |
|---------|-------------|---------------------------|
| Paleta de colores | 100% identica | — |
| Iconografia | Mismos conceptos | SF Symbols → Material Symbols (mapped) |
| Layout de pantallas | Misma estructura | Bottom nav vs TabView, componentes nativos |
| Flujos de negocio | 100% identicos | — |
| Tipografia brand | Cinzel identica | System font: Roboto (Android) vs SF Pro (iOS) |
| Animaciones/transiciones | Mismo feel premium | Idiom nativo de cada plataforma |
| Dark mode | Misma paleta | Implementacion nativa de cada OS |

---

## 2. Contexto y Motivacion

### Que es Solennix

Solennix es una plataforma SaaS premium para organizadores de eventos (catering, banquetes, fiestas, decoracion) principalmente en Mexico. La plataforma permite gestionar clientes, crear cotizaciones, manejar inventario de ingredientes/equipo, generar contratos PDF, controlar pagos y planificar eventos en un calendario.

### Audiencia objetivo Android

Organizadores de eventos en Mexico que usan dispositivos Android. En Mexico, Android tiene ~75% del market share movil, por lo que esta app es **critica** para alcanzar la mayoria de usuarios potenciales. Muchos organizadores usan dispositivos Samsung Galaxy, Xiaomi y Motorola.

### Estado actual del producto

| Plataforma | Estado | Tecnologia |
|-----------|--------|------------|
| Web | 97% completa | React 19, Vite, Tailwind CSS 4 |
| Mobile (RN) | 95% completa | React Native 0.83, Expo SDK 55 |
| iOS Nativo | En desarrollo | Swift 6, SwiftUI, iOS 17+ |
| Backend | 97% completo | Go 1.25, Chi v5, PostgreSQL 15 |

### Por que ahora

1. Android es el 75% del mercado mexicano — no cubrir nativo limita el crecimiento
2. La app iOS nativa ya define el patron arquitectonico; Android lo sigue en paralelo
3. Jetpack Compose ha madurado (version 1.6+) para apps de produccion completas
4. Kotlin coroutines + Flow son el equivalente perfecto de Swift async/await + @Observable
5. Consistencia de experiencia entre plataformas es crucial para retention

---

## 3. Plataformas Objetivo

| Plataforma | Version Minima | Justificacion |
|-----------|----------------|---------------|
| **Android** | API 26 (8.0 Oreo) | Cubre 97%+ de dispositivos activos. Baseline para Compose, predictive back, etc. |
| **Android Tablets** | API 26+ | Adaptive layouts con WindowSizeClass, multi-window |
| **Foldables** | API 30+ (11.0) | Samsung Galaxy Z Fold/Flip con WindowManager |
| **ChromeOS** | Via Android API | Soporte de teclado y mouse nativo |

### Compatibilidad de dispositivos

| Dispositivo | Soporte | Layout |
|------------|---------|--------|
| Phones (< 600dp) | Si | Compact width, bottom nav |
| Samsung Galaxy S series | Si | Compact width |
| Motorola/Xiaomi midrange | Si | Compact width |
| Samsung Galaxy Tab S | Si | Medium/Expanded, NavigationRail |
| Google Pixel Tablet | Si | Medium/Expanded, NavigationRail |
| Samsung Galaxy Z Fold | Si | Foldable: compact → medium on unfold |
| Samsung Galaxy Z Flip | Si | Compact + Flex mode |
| ChromeOS | Si | Expanded, keyboard+mouse |

---

## 4. Stack Tecnologico

### Decisiones Clave

| Capa | Eleccion | Reemplaza (RN) | Justificacion |
|------|---------|----------------|---------------|
| Lenguaje | **Kotlin 2.0** | TypeScript | Type-safe, compilado, coroutines nativas |
| UI Framework | **Jetpack Compose** (Material 3) | React Native 0.83 | Declarativo nativo, sin puente JS |
| Networking | **Ktor Client + Kotlin Serialization** | fetch API via `api.ts` | Coroutines nativas, multiplataforma |
| Auth Storage | **EncryptedSharedPreferences + AndroidKeyStore** | expo-secure-store | Hardware-backed encryption |
| Cache Local | **Room Database** | Ninguno | Offline-first, Flow reactivo |
| Suscripciones | **Google Play Billing Library v7 + RevenueCat** | react-native-purchases | UX nativa + analytics RevenueCat |
| PDF | **Android Canvas + PdfDocument / iText7** | expo-print (HTML→PDF) | Vectorial, 5-10x mas rapido |
| Imagenes | **Coil 3** (Compose-native) | expo-image | Cache nativa, decodificacion eficiente |
| Iconos | **Material Symbols** (2500+, variable) | Lucide React Native (575) | Variantes de peso/fill, accesibles |
| Graficas | **Vico** (Compose charts) | victory-native | Compose-first, Material 3, accesible |
| Navegacion | **Navigation Compose** (type-safe) | React Navigation 7 | Compile-time safe, deep links |
| Estado | **ViewModel + StateFlow + MutableState** | React Context + Zustand | Lifecycle-aware, sobrevive config changes |
| Formularios | **Compose Forms + Kotlin validation** | react-hook-form + zod | Integrado, compose-native |
| Haptics | **HapticFeedbackType (Compose)** | expo-haptics | Sin overhead de bridge |
| Camara/Fotos | **ActivityResultContracts + Photo picker** | expo-image-picker | Nativo, privacy-first |
| Biometria | **BiometricPrompt (AndroidX)** | No implementado | Fingerprint / Face unlock |
| Analytics | **Firebase Analytics (privacy mode)** | @sentry/react-native | Google ecosystem integration |
| Crash Reporting | **Sentry Android SDK** | @sentry/react-native | Symbolication nativa |
| DI | **Hilt (Dagger)** | N/A | Compile-time DI, testeable |

### Decision: Room vs DataStore

**Room.** El modelo de datos es relacional (8 entidades con joins), Room provee DAOs con Flow reactivo, migrations, y es el estandar para cache offline en Android. DataStore se usa solo para key-value preferences (`appearance`, `biometricEnabled`).

### Decision: Google Play Billing + RevenueCat (Hibrido)

- **Cliente**: Google Play Billing Library v7 para flujo de compra, verificacion de transacciones
- **Backend**: Mantener webhook RevenueCat + dashboard para analytics de revenue, A/B testing
- **RevenueCat SDK en cliente**: Solo para identificacion de usuario + posting de purchases (NO para UI de compra)
- **Beneficio**: UX de compra nativa + analytics de RevenueCat sin sacrificar ninguno

---

## 5. Arquitectura

### Patron: MVVM + Repository + UseCases (Clean Architecture)

```
+---------------------------------------------------+
|  UI Layer (Jetpack Compose)                        |
|    - @Composable functions puras                   |
|    - remember / mutableStateOf para estado local   |
|    - collectAsStateWithLifecycle() para flows      |
+---------------------------------------------------+
                       |
+---------------------------------------------------+
|  ViewModel Layer (AndroidX ViewModel)              |
|    - Logica de presentacion por pantalla           |
|    - Expone StateFlow<UiState> a las views         |
|    - Llama UseCases o Repositories                 |
|    - Sobrevive configuration changes               |
+---------------------------------------------------+
                       |
+---------------------------------------------------+
|  Domain Layer (UseCases — opcional para logica     |
|    compleja, Repository directo para CRUD simple)  |
+---------------------------------------------------+
                       |
+---------------------------------------------------+
|  Repository Layer (interfaces + implementaciones)  |
|    - Abstrae API + cache local (Room)              |
|    - Decide: fetch de red o cache?                 |
|    - Maneja actualizaciones optimistas             |
+---------------------------------------------------+
                       |
           +------------+------------+
           |                         |
+-----------------+    +-------------------+
|  Network Layer  |    |  Persistence Layer|
|  (Ktor Client)  |    |  (Room Database)  |
|  - Coroutines   |    |  - @Entity DAOs   |
|  - JWT refresh  |    |  - Offline reads  |
|  - Interceptors |    |  - Flow queries   |
+-----------------+    +-------------------+
```

### Principios de Arquitectura

1. **Separacion estricta** — Composables no llaman API directamente, siempre via ViewModel → Repository
2. **Interface-driven** — Repositories definen interfaces; implementaciones son intercambiables (fake para tests)
3. **Coroutine-safe networking** — Ktor client usa coroutines; token refresh es mutex-protected
4. **Offline-first reads** — Room responde inmediatamente via Flow; API actualiza en background
5. **Dependency injection via Hilt** — `@HiltViewModel`, `@Inject constructor`, facilita testing

### Flujo de Datos (Ejemplo: Listar Clientes)

```
ClientListScreen (@Composable)
  → ClientListViewModel.loadClients()
    → ClientRepository.getClients(): Flow<List<Client>>
      → 1. Emit cached from Room (instant) via Flow
      → 2. Fetch from KtorClient.get("/clients") (coroutine)
      → 3. Insert/update Room with fresh data
      → 4. Room Flow auto-emits update → UI recomposes
```

---

## 6. Estructura Modular del Proyecto

```
android/
|
+-- app/                                  # Modulo principal
|   +-- src/main/
|   |   +-- java/com/creapolis/solennix/
|   |   |   +-- SolennixApp.kt           # Application class (@HiltAndroidApp)
|   |   |   +-- MainActivity.kt          # Single Activity (@AndroidEntryPoint)
|   |   |   +-- MainNavHost.kt           # NavHost raiz con auth gate
|   |   +-- res/
|   |   |   +-- values/                  # strings.xml, themes.xml, colors.xml
|   |   |   +-- drawable/               # Vectores, iconos custom
|   |   +-- AndroidManifest.xml
|   +-- build.gradle.kts
|
+-- core/
|   +-- model/                            # Modelos de datos (data classes)
|   |   +-- User.kt, Client.kt, Event.kt, Product.kt, InventoryItem.kt
|   |   +-- EventProduct.kt, EventExtra.kt, EventEquipment.kt, EventSupply.kt
|   |   +-- ProductIngredient.kt, Payment.kt, EquipmentConflict.kt
|   |   +-- SupplySuggestion.kt, EquipmentSuggestion.kt
|   |
|   +-- network/                          # Cliente API, endpoints, auth
|   |   +-- KtorClient.kt               # Ktor HttpClient config + interceptors
|   |   +-- AuthManager.kt              # EncryptedSharedPrefs + biometric + token refresh
|   |   +-- AuthInterceptor.kt          # Plugin de Ktor para Bearer token
|   |   +-- Endpoints.kt                # Object con todas las rutas
|   |   +-- NetworkMonitor.kt           # ConnectivityManager wrapper
|   |
|   +-- database/                         # Room database + DAOs
|   |   +-- SolennixDatabase.kt          # @Database
|   |   +-- dao/                         # ClientDao, EventDao, ProductDao, InventoryDao
|   |   +-- entity/                      # Cached entities (@Entity)
|   |   +-- converter/                   # TypeConverters (Date, enums, JSON)
|   |
|   +-- designsystem/                    # Design system completo
|   |   +-- theme/
|   |   |   +-- Color.kt                # Tokens de color (light/dark)
|   |   |   +-- Typography.kt           # Text styles
|   |   |   +-- Spacing.kt              # Spacing scale (4dp grid)
|   |   |   +-- Shape.kt                # Corner radius tokens
|   |   |   +-- Shadow.kt               # Elevation tokens
|   |   |   +-- Theme.kt                # SolennixTheme composable
|   |   +-- component/                   # Componentes compartidos de UI
|   |       +-- PremiumButton.kt
|   |       +-- Avatar.kt
|   |       +-- KPICard.kt
|   |       +-- EmptyState.kt
|   |       +-- SolennixTextField.kt
|   |       +-- StatusBadge.kt
|   |       +-- SwipeableRow.kt
|   |       +-- ConfirmDialog.kt
|   |       +-- SkeletonLoading.kt
|   |       +-- SortSelector.kt
|   |       +-- SegmentedControl.kt
|   |       +-- PhotoGallery.kt
|   |       +-- UpgradeBanner.kt
|   |       +-- SearchBar.kt
|   |       +-- ToastOverlay.kt
|
+-- feature/
|   +-- auth/
|   |   +-- ui/                          # LoginScreen, RegisterScreen, ForgotPasswordScreen, ResetPasswordScreen
|   |   +-- viewmodel/                   # AuthViewModel
|   |
|   +-- dashboard/
|   |   +-- ui/                          # DashboardScreen, KPISection, UpcomingEventsSection
|   |   +-- viewmodel/                   # DashboardViewModel
|   |
|   +-- calendar/
|   |   +-- ui/                          # CalendarScreen, EventDayList
|   |   +-- viewmodel/                   # CalendarViewModel
|   |
|   +-- events/
|   |   +-- ui/                          # EventFormScreen (wizard), EventDetailScreen, EventChecklistScreen
|   |   +-- viewmodel/                   # EventFormViewModel, EventDetailViewModel
|   |   +-- pdf/                         # 6 generadores de PDF nativos
|   |
|   +-- clients/
|   |   +-- ui/                          # ClientListScreen, ClientFormScreen, ClientDetailScreen
|   |   +-- viewmodel/                   # ClientListViewModel, ClientFormViewModel
|   |
|   +-- products/
|   |   +-- ui/                          # ProductListScreen, ProductFormScreen, ProductDetailScreen
|   |   +-- viewmodel/                   # ProductListViewModel, ProductFormViewModel
|   |
|   +-- inventory/
|   |   +-- ui/                          # InventoryListScreen, InventoryFormScreen, InventoryDetailScreen
|   |   +-- viewmodel/                   # InventoryListViewModel
|   |
|   +-- search/
|   |   +-- ui/                          # SearchScreen
|   |   +-- viewmodel/                   # SearchViewModel
|   |
|   +-- settings/
|       +-- ui/                          # SettingsScreen, EditProfileScreen, ChangePasswordScreen...
|       +-- viewmodel/                   # SettingsViewModel, BusinessSettingsViewModel
|
+-- widget/                              # Glance widget module
|   +-- UpcomingEventsWidget.kt
|   +-- KPIWidget.kt
|
+-- build.gradle.kts                     # Root build
+-- gradle/libs.versions.toml            # Version catalog
```

### Justificacion de la estructura modular

- **Builds incrementales** — Modulos Gradle independientes; cambios en `feature:events` no recompila `core:designsystem`
- **Testabilidad** — Cada modulo tiene tests; repositories mockeables via interfaces
- **Reutilizacion** — `core:model` y `core:network` se comparten con widget module
- **Separation of concerns** — Design system aislado del negocio; network aislado de la UI
- **Consistent con iOS** — Estructura de paquetes espeja los Swift Packages de iOS

---

## 7. Estrategia de App Adaptativa

### Phone (Compact Width < 600dp)

```
+------------------------------+
|  Status Bar                   |
+------------------------------+
|  TopAppBar                    |
|  Titulo | Acciones            |
+------------------------------+
|                               |
|  LazyColumn / Content         |
|  bg: surfaceGrouped           |
|                               |
|  +-------------------------+  |
|  |  Card (bg-card)         |  |
|  |  shape: RoundedCorner24 |  |
|  |  tonalElevation: sm     |  |
|  +-------------------------+  |
|                               |
+------------------------------+
|  [Home] [Cal] [+] [Cli] [Mas]|
|  NavigationBar (4 items + FAB)|
+------------------------------+
```

- **NavigationBar** (Material 3) con 4 destinos: Inicio, Calendario, Clientes, Mas
- **FAB central** (FloatingActionButton) para "Nuevo Evento" — identico al iOS
- **NavHost** dentro de cada destino para navegacion drill-down

### Tablet (Medium 600-840dp)

```
+--------------------------------------------------+
|  NavigationRail   |  Content                      |
|  (80dp)           |                               |
|                   |  Lista de Clientes             |
|  [S] Logo         |                               |
|                   |  +--------+                   |
|  [■] Inicio       |  | Card   |                  |
|  [■] Calendario   |  +--------+                  |
|  [■] Clientes     |  | Card   |                  |
|  [■] Productos    |  +--------+                  |
|  [■] Inventario   |                               |
|  [■] Buscar       |                               |
|                   |                               |
|  ---              |                               |
|  [■] Ajustes      |                               |
+--------------------------------------------------+
```

### Tablet Large / Foldable Expanded (> 840dp)

```
+--------------------------------------------------+
|  NavigationRail |  Content         |  Detail       |
|  (80dp)         |  (list-detail)   |               |
|                 |                  |  Detalle      |
|  [S] Logo       |  Lista de       |  Cliente      |
|                 |  Clientes       |               |
|  [■] Inicio     |  +--------+    |  Nombre       |
|  [■] Calendario |  | Card ► |    |  Telefono     |
|  ...            |  +--------+    |  Email        |
|                 |  | Card   |    |  Eventos      |
|                 |  +--------+    |  [lista]      |
+--------------------------------------------------+
```

- **ListDetailPaneScaffold** (Material 3 Adaptive) para list-detail patterns
- **Multi-window** soporte con `resizeableActivity="true"`
- **Foldable awareness** via `WindowInfoTracker` para posture detection

### Codigo Adaptativo

```kotlin
@Composable
fun MainLayout(
    windowSizeClass: WindowSizeClass
) {
    val authState by authViewModel.authState.collectAsStateWithLifecycle()

    when (authState) {
        AuthState.Unauthenticated -> AuthNavHost()
        AuthState.BiometricLocked -> BiometricGateScreen()
        AuthState.Authenticated -> {
            when (windowSizeClass.widthSizeClass) {
                WindowWidthSizeClass.Compact -> CompactBottomNavLayout()
                WindowWidthSizeClass.Medium -> MediumNavigationRailLayout()
                WindowWidthSizeClass.Expanded -> ExpandedListDetailLayout()
            }
        }
    }
}
```

---

## 8. Sistema de Navegacion

### Navegacion type-safe con Navigation Compose

#### Sealed class de Routes

```kotlin
@Serializable
sealed class Route {
    // Events
    @Serializable data class EventDetail(val id: String) : Route()
    @Serializable data class EventForm(val id: String? = null, val clientId: String? = null) : Route()
    @Serializable data class EventChecklist(val id: String) : Route()

    // Clients
    @Serializable data class ClientDetail(val id: String) : Route()
    @Serializable data class ClientForm(val id: String? = null) : Route()

    // Products
    @Serializable data class ProductDetail(val id: String) : Route()
    @Serializable data class ProductForm(val id: String? = null) : Route()

    // Inventory
    @Serializable data class InventoryDetail(val id: String) : Route()
    @Serializable data class InventoryForm(val id: String? = null) : Route()

    // Settings
    @Serializable data object EditProfile : Route()
    @Serializable data object ChangePassword : Route()
    @Serializable data object BusinessSettings : Route()
    @Serializable data object ContractDefaults : Route()
    @Serializable data object Pricing : Route()
    @Serializable data object About : Route()
    @Serializable data object Privacy : Route()
    @Serializable data object Terms : Route()
}
```

#### Bottom Navigation Items (Phone)

```kotlin
enum class TopLevelDestination(
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector
) {
    HOME("Inicio", Icons.Outlined.Home, Icons.Filled.Home),
    CALENDAR("Calendario", Icons.Outlined.CalendarMonth, Icons.Filled.CalendarMonth),
    CLIENTS("Clientes", Icons.Outlined.People, Icons.Filled.People),
    MORE("Mas", Icons.Outlined.MoreHoriz, Icons.Filled.MoreHoriz)
}
```

#### Deep Links

```kotlin
// Password reset via email link
// solennix://reset-password?token=abc123
val deepLinks = listOf(
    navDeepLink {
        uriPattern = "solennix://reset-password?token={token}"
    }
)
```

---

## 9. Design System (SolennixDesign)

### 9.1 Tokens de Color

Todos los tokens identicos a iOS para consistencia visual. Implementados via `Color` con variantes Light/Dark en `SolennixTheme`.

#### Marca (Brand) — Identico a iOS

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `SolennixGold` (primary) | `#C4A265` | `#C4A265` | CTAs, iconos activos, badges, links, focus rings |
| `SolennixGoldDark` (primaryDark) | `#B8965A` | `#D4B87A` | Hover/pressed de primary, gradientes |
| `SolennixGoldLight` (primaryLight) | `#F5F0E8` | `#1B2A4A` | Fondos hover sutiles |
| `SolennixSecondary` | `#6B7B8D` | `#94A3B8` | Texto terciario, decorativo |

#### Superficies — Identico a iOS

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| `Background` | `#FFFFFF` | `#000000` (AMOLED) | Fondo de pagina |
| `SurfaceGrouped` | `#F5F4F1` | `#0A0F1A` (navy tint) | Panel principal |
| `Surface` | `#FAF9F7` | `#1A2030` | Inputs, search bars |
| `SurfaceAlt` | `#F0EFEC` | `#252A35` | Hover, estados alternos |
| `Card` | `#FFFFFF` | `#111722` (navy tint) | Cards, contenedores |

#### Texto, Bordes, Semanticos, Status, KPI, Tab Bar, Avatar

**100% identicos a iOS** — ver PRD-NATIVE-IOS.md seccion 9.1. Los mismos hexadecimales se usan aqui.

#### Implementacion en Compose

```kotlin
// Color.kt
val SolennixGold = Color(0xFFC4A265)
val SolennixGoldDark = Color(0xFFB8965A)
val SolennixGoldDarkDM = Color(0xFFD4B87A)  // Dark mode variant

// Theme.kt — Custom color scheme
private val LightSolennixColors = SolennixColorScheme(
    primary = SolennixGold,
    primaryDark = SolennixGoldDark,
    background = Color(0xFFFFFFFF),
    surfaceGrouped = Color(0xFFF5F4F1),
    surface = Color(0xFFFAF9F7),
    card = Color(0xFFFFFFFF),
    primaryText = Color(0xFF1A1A1A),
    secondaryText = Color(0xFF7A7670),
    // ... all 43+ tokens
)

private val DarkSolennixColors = SolennixColorScheme(
    primary = SolennixGold,
    primaryDark = SolennixGoldDarkDM,
    background = Color(0xFF000000),
    surfaceGrouped = Color(0xFF0A0F1A),
    surface = Color(0xFF1A2030),
    card = Color(0xFF111722),
    primaryText = Color(0xFFF5F0E8),
    secondaryText = Color(0xFF9A9590),
    // ... all 43+ tokens
)

@Composable
fun SolennixTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkSolennixColors else LightSolennixColors
    CompositionLocalProvider(
        LocalSolennixColors provides colors
    ) {
        MaterialTheme(
            colorScheme = colors.toMaterialColorScheme(),
            typography = SolennixTypography,
            shapes = SolennixShapes,
            content = content
        )
    }
}
```

### 9.2 Tipografia

Tipografia de sistema (Roboto) para contenido general, Cinzel para branding (identico a iOS).

| Uso | iOS Font | Android Font | Tamano | Peso |
|-----|----------|-------------|--------|------|
| Titulo de pagina | `.system(28, .black)` | `Roboto 28sp Black` | 28sp | Black (900) |
| Large Title | `.largeTitle` | `headlineLarge` | 32sp | Regular |
| Title 1 | `.title` | `titleLarge` | 22sp | Regular |
| Title 2 | `.title2` | `titleMedium` | 16sp | Medium |
| Title 3 | `.title3` | `titleSmall` | 14sp | Medium |
| Headline | `.headline` | `labelLarge` | 14sp | Medium |
| Body | `.body` | `bodyLarge` | 16sp | Regular |
| Callout | `.callout` | `bodyMedium` | 14sp | Regular |
| Subheadline | `.subheadline` | `bodySmall` | 12sp | Regular |
| Footnote | `.footnote` | `labelMedium` | 12sp | Medium |
| Caption 1 | `.caption` | `labelSmall` | 11sp | Medium |

**Tipografia de marca** (Cinzel para headlines premium):

```kotlin
val CinzelFontFamily = FontFamily(
    Font(R.font.cinzel_regular, FontWeight.Normal),
    Font(R.font.cinzel_semibold, FontWeight.SemiBold),
)

val SolennixTitle = TextStyle(
    fontFamily = CinzelFontFamily,
    fontWeight = FontWeight.SemiBold,
    fontSize = 32.sp
)
```

### 9.3 Espaciado — Identico a iOS

Grid de 4dp identico: `xxs=2`, `xs=4`, `sm=8`, `md=16`, `lg=20`, `xl=24`, `xxl=32`, `xxxl=48`

### 9.4 Shapes (Border Radius)

| Uso | iOS | Android (Compose) |
|-----|-----|-------------------|
| Badges, chips | 6pt | `RoundedCornerShape(6.dp)` |
| Inputs, botones | 10pt | `RoundedCornerShape(10.dp)` |
| Cards (web) | 14pt | `RoundedCornerShape(14.dp)` |
| Cards principales | 24pt | `RoundedCornerShape(24.dp)` |
| Modals/Sheets | 20pt | `RoundedCornerShape(topStart=20.dp, topEnd=20.dp)` |

### 9.5 Elevaciones/Sombras

```kotlin
object SolennixElevation {
    val sm = 2.dp    // Cards sutiles
    val md = 6.dp    // Cards principales
    val lg = 12.dp   // Modals, sheets
    val fab = 8.dp   // FAB con shadow dorada custom
}
```

### 9.6 Gradiente Premium — Identico a iOS

```kotlin
val PremiumGradient = Brush.horizontalGradient(
    colors = listOf(SolennixGold, SolennixGoldDark)
)
```

### 9.7 Mapeo de Iconos SF Symbols → Material Symbols

| Icono iOS (SF Symbol) | Material Symbol | Uso |
|----------------------|-----------------|-----|
| `house.fill` | `Icons.Filled.Home` | Tab Inicio |
| `calendar` | `Icons.Filled.CalendarMonth` | Tab Calendario |
| `person.2.fill` | `Icons.Filled.People` | Tab Clientes |
| `ellipsis` | `Icons.Filled.MoreHoriz` | Tab Mas |
| `plus` | `Icons.Filled.Add` | FAB nuevo evento |
| `magnifyingglass` | `Icons.Filled.Search` | Busqueda |
| `dollarsign.circle.fill` | `Icons.Filled.AttachMoney` | Pagos/KPI |
| `shippingbox.fill` | `Icons.Filled.Inventory2` | Productos |
| `archivebox.fill` | `Icons.Filled.Archive` | Inventario |
| `exclamationmark.triangle.fill` | `Icons.Filled.Warning` | Alertas |
| `pencil` | `Icons.Filled.Edit` | Editar |
| `trash.fill` | `Icons.Filled.Delete` | Eliminar |
| `checkmark` | `Icons.Filled.Check` | Confirmar |
| `star.fill` | `Icons.Filled.Star` | Premium |
| `clock.fill` | `Icons.Filled.Schedule` | Horario |
| `mappin.and.ellipse` | `Icons.Filled.LocationOn` | Ubicacion |
| `doc.text.fill` | `Icons.Filled.Description` | PDFs |
| `creditcard.fill` | `Icons.Filled.CreditCard` | Metodo pago |
| `camera.fill` | `Icons.Filled.CameraAlt` | Captura foto |
| `arrow.down.circle.fill` | `Icons.Filled.Download` | Descargar |
| `chevron.right` | `Icons.AutoMirrored.Filled.ChevronRight` | Navegacion |
| `phone.fill` | `Icons.Filled.Phone` | Llamar |
| `envelope.fill` | `Icons.Filled.Email` | Email |
| `eye` / `eye.slash` | `Icons.Filled.Visibility` / `VisibilityOff` | Password |
| `gearshape.fill` | `Icons.Filled.Settings` | Ajustes |
| `person.fill` | `Icons.Filled.Person` | Perfil |
| `lock.fill` | `Icons.Filled.Lock` | Seguridad |
| `paintpalette.fill` | `Icons.Filled.Palette` | Marca |

### 9.8 Componentes del Design System

| Componente iOS | Componente Android | Mejora Nativa |
|--------------|-------------------|---------------|
| `SolennixTextField` | `SolennixTextField` | `autofillType`, `KeyboardOptions`, `FocusRequester` |
| `AvatarView` | `Avatar` | Coil AsyncImage, Material Symbols fallback |
| `.redacted(reason:)` | `SkeletonLoading` | Shimmer animation con `placeholder` de Accompanist |
| `.confirmationDialog` | `ConfirmDialog` (AlertDialog M3) | Material 3 AlertDialog con haptics |
| `EmptyStateView` | `EmptyState` | Material Symbols animados con AnimatedVisibility |
| `.sheet + detents` | `ModalBottomSheet` (M3) | Material 3 BottomSheet con drag handles |
| `Picker(.segmented)` | `SegmentedButton` (M3) | Material 3 SegmentedButton nativo |
| `Menu + Picker` | `ExposedDropdownMenuBox` | Material 3 dropdown nativo |
| `.swipeActions` | `SwipeToDismissBox` (M3) | Material 3 swipe con anchors |
| `KPICardView` | `KPICard` | Vico charts inline |
| `PremiumButtonView` | `PremiumButton` | Gradiente con `animateContentSize()` |
| `PhotoGalleryView` | `PhotoGallery` | Coil + Photo picker nativo |
| `UpgradeBannerView` | `UpgradeBanner` | Google Play Billing overlay |
| `ToastOverlay` | `ToastOverlay` (Snackbar M3) | Snackbar con undo actions |

---

## 10. Matriz de Paridad de Features

### Feature por feature: iOS vs Android

| Feature | iOS Implementation | Android Equivalent | Notas |
|---------|-------------------|-------------------|-------|
| Login email/password | SwiftUI Form + `.textContentType` | Compose TextField + `autofill` | Autofill Manager nativo |
| Registro | SwiftUI Form + validacion | Compose Form + validacion Kotlin | Google One Tap sign-in |
| Reset password | `.onOpenURL` deep link | `navDeepLink` | Mismo esquema `solennix://` |
| Token JWT | Keychain Services | EncryptedSharedPreferences | Hardware-backed via AndroidKeyStore |
| Token refresh | Actor thread-safe | Mutex coroutine-safe | Sin race conditions |
| Tabs (4 + FAB) | TabView + overlay FAB | NavigationBar + FAB | Material 3 idiom |
| Sidebar (iPad) | NavigationSplitView | NavigationRail / NavigationDrawer | Adaptive via WindowSizeClass |
| Dark mode | `colorScheme` + Asset Catalog | `isSystemInDarkTheme()` + Theme | Automatico |
| Theme toggle | `@AppStorage` | DataStore preferences | Persistente |
| Pull-to-refresh | `.refreshable` modifier | `PullToRefreshBox` (M3) | Built-in |
| Haptics | UIImpactFeedbackGenerator | `HapticFeedbackType` | Compose nativo |
| PDF generation (6) | UIGraphicsPDFRenderer | `PdfDocument` + Canvas | Vectorial nativo |
| Compartir PDF | ShareLink | Intent.ACTION_SEND + FileProvider | Android sharing |
| Subir fotos | PhotosPicker (PhotosUI) | `PickVisualMedia` contract | Privacy-first photo picker |
| Mostrar imagenes | AsyncImage + Kingfisher | Coil 3 `AsyncImage` | Cache nativa |
| Calendario | Grid custom + Foundation | Grid custom + java.time | Locale-aware |
| Formularios | SwiftUI Form + validation | Compose + Kotlin validation | Integrado |
| Bottom sheets | `.sheet + detents` | `ModalBottomSheet` (M3) | Material 3 |
| Blur effects | `.ultraThinMaterial` | `Modifier.blur()` + RenderEffect | API 31+ |
| Gradientes | LinearGradient | `Brush.horizontalGradient` | Zero dependency |
| Graficas (KPIs) | Swift Charts | Vico | Compose-native, M3 |
| In-app purchases | StoreKit 2 + RevenueCat | Play Billing v7 + RevenueCat | Nativo + analytics |
| Animaciones | withAnimation / matchedGeometry | `animateContentSize` / `AnimatedVisibility` | 60fps |
| Swipe actions | `.swipeActions` modifier | `SwipeToDismissBox` (M3) | Material 3 |
| Skeleton loading | `.redacted(reason:)` | Shimmer placeholder | Custom pero equivalente |
| Busqueda | `.searchable` modifier | `SearchBar` (M3) | Material 3 Search |
| Date/Time pickers | DatePicker | `DatePickerDialog` / `TimePickerDialog` (M3) | Material 3 |
| Iconos | SF Symbols 5 (5000+) | Material Symbols (2500+) | Variable weight/fill |
| Onboarding tips | TipKit | Custom tooltips + Composable | No framework equivalente directo |
| Widgets | WidgetKit | Glance (Compose for widgets) | Home screen widgets |
| Biometria | Face ID / Touch ID (LocalAuthentication) | BiometricPrompt (AndroidX) | Fingerprint / Face |
| Sign in with Apple | AuthenticationServices | Google One Tap sign-in | Plataforma-especifico |

---

## 11. Especificacion Pantalla por Pantalla

### 11.1 Autenticacion (4 pantallas)

#### LoginScreen

- **Layout:** Identico visual al iOS — Logo Solennix (copa tulipan) + titulo Cinzel + tagline + Form
- **Campos:** Email (`KeyboardType.Email`, `AutofillType.EmailAddress`), Password (con toggle visibilidad)
- **Botones:** "Iniciar Sesion" (PremiumButton gradient), "Google One Tap" (reemplaza Sign in with Apple)
- **Validacion/API/Flujo:** Identico a iOS
- **Diferencia Android:** Google One Tap sign-in en lugar de Sign in with Apple. Boton "Iniciar con Google" con Material 3 styling.

#### RegisterScreen, ForgotPasswordScreen, ResetPasswordScreen

- **Identicos a iOS** en campos, validacion, API calls y flujo
- **Google One Tap** como alternativa de registro
- **Deep link:** `solennix://reset-password?token=X` via `navDeepLink`

### 11.2-11.9 — Todas las pantallas

**Identicas functionally a iOS** (Dashboard, Calendario, Eventos con wizard de 5 pasos, Clientes, Productos, Inventario, Busqueda, Ajustes). Las mismas secciones, campos, APIs, y logica de negocio. Las diferencias son unicamente en componentes de UI que usan el idiom nativo de Android:

| Pantalla | Diferencia Android vs iOS |
|----------|--------------------------|
| Dashboard KPIs | Vico charts en lugar de Swift Charts |
| Calendario grid | Custom `LazyVerticalGrid` equivalente |
| EventForm wizard | `HorizontalPager` (Compose) en lugar de `TabView(.page)` |
| Listas | `LazyColumn` con `SwipeToDismissBox` |
| Detalle evento PDFs | `Intent.ACTION_SEND` en lugar de `ShareLink` |
| Settings | `ListItem` (M3) en secciones agrupadas |
| Color picker | Custom compose color picker (no hay nativo como SwiftUI) |
| Photo picker | `PickVisualMedia` contract |

**Ver PRD-NATIVE-IOS.md secciones 11.1-11.9 para especificaciones completas de cada pantalla. La funcionalidad es 100% identica.**

---

## 12. Mejoras Nativas Android Exclusivas

### 12.1 Glance Widgets (Home Screen)

#### Widget de Proximos Eventos

| Tamano | Contenido |
|--------|-----------|
| **Small** (2x2) | Proximo evento: fecha, cliente, status badge |
| **Medium** (4x2) | Proximos 2-3 eventos con fecha, cliente, tipo |
| **Large** (4x3) | Vista semanal con dots + lista de proximos |

#### Widget de KPIs

| Tamano | Contenido |
|--------|-----------|
| **Small** (2x2) | Revenue del mes (numero grande) |
| **Medium** (4x2) | Revenue + eventos + stock bajo |

```kotlin
class UpcomingEventsWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            SolennixTheme {
                EventWidgetContent(events = loadEvents())
            }
        }
    }
}
```

**Data flow:** Room database → WorkManager periodic sync (cada 15 min) → Glance widget reads via DAO

### 12.2 Quick Settings Tile (NUEVO — No existe en iOS)

```kotlin
class NewEventTileService : TileService() {
    override fun onClick() {
        // Abre la app directamente en EventFormScreen
        val intent = Intent(this, MainActivity::class.java).apply {
            action = "com.creapolis.solennix.NEW_EVENT"
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivityAndCollapse(intent)
    }
}
```

Quick Settings tile "Nuevo Evento" — acceso con un swipe desde notification shade.

### 12.3 Google Assistant / App Actions

```xml
<!-- shortcuts.xml -->
<shortcuts>
    <capability android:name="actions.intent.CREATE_EVENT">
        <intent android:action="android.intent.action.VIEW"
                android:targetPackage="com.creapolis.solennix"
                android:targetClass=".MainActivity">
            <parameter android:name="event.name" android:key="eventName" />
        </intent>
    </capability>
    <capability android:name="actions.intent.GET_EVENT">
        <intent android:action="android.intent.action.VIEW"
                android:targetPackage="com.creapolis.solennix">
            <parameter android:name="event.name" android:key="query" />
        </intent>
    </capability>
</shortcuts>
```

### 12.4 Foldable Support (Samsung Galaxy Z Fold)

```kotlin
@Composable
fun AdaptiveEventDetail(foldingFeature: FoldingFeature?) {
    if (foldingFeature?.state == FoldingFeature.State.HALF_OPENED) {
        // Table-top mode: info arriba, PDFs/actions abajo
        TwoPane(
            first = { EventInfoSection() },
            second = { EventActionsSection() },
            strategy = HorizontalTwoPaneStrategy(splitFraction = 0.5f)
        )
    } else {
        // Normal: scroll vertical
        EventDetailScrollable()
    }
}
```

### 12.5 Predictive Back Gesture (Android 14+)

```kotlin
// Animacion de preview al hacer back gesture
PredictiveBackHandler { progress ->
    // Animar el contenido con la animacion predictiva del sistema
    scale = 1f - (progress.coerceIn(0f, 1f) * 0.1f)
}
```

### 12.6 Per-App Language Preferences (Android 13+)

```xml
<!-- res/xml/locales_config.xml -->
<locale-config>
    <locale android:name="es-MX" />
    <locale android:name="en" />
    <locale android:name="pt-BR" />
</locale-config>
```

### 12.7 Bubble Notifications (Android 11+)

```kotlin
// Para eventos activos, mostrar burbuja flotante con info del evento
val bubbleMetadata = Notification.BubbleMetadata.Builder(
    pendingIntent, Icon.createWithResource(context, R.drawable.ic_event)
).setDesiredHeight(600).build()
```

### 12.8 Shortcuts (Long-press app icon)

```xml
<shortcuts>
    <shortcut android:shortcutId="new_event" android:enabled="true"
              android:shortcutShortLabel="@string/new_event"
              android:icon="@drawable/ic_add_event">
        <intent android:action="android.intent.action.VIEW"
                android:targetPackage="com.creapolis.solennix"
                android:data="solennix://new-event" />
    </shortcut>
    <shortcut android:shortcutId="search" .../>
    <shortcut android:shortcutId="calendar" .../>
    <shortcut android:shortcutId="new_client" .../>
</shortcuts>
```

### 12.9 Biometric Authentication (Fingerprint / Face)

```kotlin
val biometricPrompt = BiometricPrompt(activity, executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: AuthenticationResult) {
            // Proceder al contenido principal
        }
    }
)
val promptInfo = BiometricPrompt.PromptInfo.Builder()
    .setTitle("Desbloquea Solennix")
    .setSubtitle("Usa tu huella o rostro")
    .setAllowedAuthenticators(BIOMETRIC_STRONG or DEVICE_CREDENTIAL)
    .build()
biometricPrompt.authenticate(promptInfo)
```

---

## 13. Capa de Datos

### 13.1 Modelos Kotlin (Kotlinx Serialization)

Identicos a iOS, mapeados de `mobile/src/types/entities.ts`:

```kotlin
@Serializable
data class User(
    val id: String,
    val email: String,
    val name: String,
    @SerialName("business_name") val businessName: String? = null,
    @SerialName("logo_url") val logoUrl: String? = null,
    @SerialName("brand_color") val brandColor: String? = null,
    @SerialName("show_business_name_in_pdf") val showBusinessNameInPdf: Boolean? = null,
    @SerialName("default_deposit_percent") val defaultDepositPercent: Double? = null,
    @SerialName("default_cancellation_days") val defaultCancellationDays: Double? = null,
    @SerialName("default_refund_percent") val defaultRefundPercent: Double? = null,
    @SerialName("contract_template") val contractTemplate: String? = null,
    val plan: Plan = Plan.BASIC,
    @SerialName("stripe_customer_id") val stripeCustomerId: String? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String
) {
    @Serializable
    enum class Plan { @SerialName("basic") BASIC, @SerialName("premium") PREMIUM }
}
// Client, Event, Product, InventoryItem, EventProduct, EventExtra,
// EventEquipment, EventSupply, ProductIngredient, Payment,
// EquipmentConflict, SupplySuggestion, EquipmentSuggestion
// — Todos siguen el mismo patron con @SerialName para snake_case
```

### 13.2 KtorClient

```kotlin
@Singleton
class KtorClient @Inject constructor(
    private val authManager: AuthManager
) {
    val client = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
        install(Auth) { bearer { loadTokens { authManager.getBearerTokens() } } }
        defaultRequest { url(BuildConfig.API_BASE_URL) }
    }
    suspend inline fun <reified T> get(endpoint: String): T = client.get(endpoint).body()
    suspend inline fun <reified T> post(endpoint: String, body: Any): T = client.post(endpoint) { setBody(body) }.body()
    // put, delete, upload...
}
```

### 13.3 Endpoints — Identicos a iOS (seccion 13.3 del PRD iOS)

### 13.4 Room Database (Cache)

```kotlin
@Database(entities = [CachedClient::class, CachedEvent::class, ...], version = 1)
abstract class SolennixDatabase : RoomDatabase() {
    abstract fun clientDao(): ClientDao
    abstract fun eventDao(): EventDao
    // ...
}

@Dao
interface ClientDao {
    @Query("SELECT * FROM clients ORDER BY updated_at DESC")
    fun getAll(): Flow<List<CachedClient>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(clients: List<CachedClient>)
}
```

---

## 14. Flujo de Autenticacion

Identico al iOS (seccion 14 del PRD iOS), con estas diferencias:

- **EncryptedSharedPreferences** en lugar de Keychain
- **Google One Tap sign-in** en lugar de Sign in with Apple
- **BiometricPrompt** en lugar de LocalAuthentication
- **Backend:** `POST /auth/google` (NUEVO) en lugar de `POST /auth/apple`

---

## 15. Suscripciones

### Google Play Billing Library v7 + RevenueCat (Hibrido)

- **Cliente:** Google Play Billing para flujo de compra y verificacion
- **Backend:** Mantener RevenueCat webhooks para analytics
- **Tiers identicos:** Basic (Gratis), Pro Mensual ($99 MXN), Pro Anual ($899 MXN)
- **Product IDs:** `com.creapolis.solennix.pro_monthly`, `com.creapolis.solennix.pro_annual`

---

## 16. Generacion de PDFs

6 tipos identicos a iOS, renderizados con `PdfDocument` + `Canvas` nativo de Android:

```kotlin
fun generateBudgetPdf(event: Event, client: Client, products: List<EventProduct>): File {
    val document = PdfDocument()
    val pageInfo = PdfDocument.PageInfo.Builder(612, 792, 1).create()
    val page = document.startPage(pageInfo)
    val canvas = page.canvas
    // Dibujar header, tabla de productos, resumen financiero...
    // Misma estructura visual que iOS
    document.finishPage(page)
    val file = File(context.cacheDir, "presupuesto_${event.id}.pdf")
    document.writeTo(file.outputStream())
    document.close()
    return file
}
```

**Compartir:** `Intent.ACTION_SEND` con `FileProvider` para URIs seguras.

---

## 17. Gestion de Fotos

| iOS | Android |
|-----|---------|
| PhotosPicker (PhotosUI) | `PickMultipleVisualMedia()` (ActivityResult API) |
| URLSession.uploadTask | `WorkManager` background upload |
| CIFilter crop | Coil transformations |
| AsyncImage + Kingfisher | Coil 3 `AsyncImage` |

---

## 18. Notificaciones Push

### FCM (Firebase Cloud Messaging) en lugar de APNs

```
[App] → POST /devices/register {token, platform: "android"} → [Backend Go]
[Backend Go] → FCM → [Dispositivo Android]
```

Mismos tipos de notificaciones que iOS (Event Reminder, Payment Received, Low Stock, Subscription Change). Notification channels para categorizar.

**Backend:** Agregar soporte FCM al `PushService` (Go). Usar `google.golang.org/api/fcm/v1`.

---

## 19. Accesibilidad

- **TalkBack** — Labels significativos via `contentDescription`, `semantics { }` blocks
- **Font scaling** — Todas las fuentes en `sp`, layouts que no se rompen
- **Reduce animations** — `Settings.Global.ANIMATOR_DURATION_SCALE` check
- **High contrast** — Minimo 4.5:1 en todos los textos
- **Switch Access** — Focus order logico

---

## 20. Localizacion

- Idioma base: **Espanol (Mexico)** — `values-es-rMX/strings.xml`
- Preparado: English (`values/strings.xml`), Portugues (`values-pt-rBR/`)
- Formato moneda: `NumberFormat.getCurrencyInstance(Locale("es", "MX"))`
- Formato fecha: `DateTimeFormatter.ofPattern("d 'de' MMMM 'de' yyyy", Locale("es", "MX"))`

---

## 21. Estrategia de Testing

| Tipo | Herramienta | Coverage | Que testea |
|------|------------|----------|------------|
| **Unit Tests** | JUnit 5 + Turbine (Flow) | 80% ViewModels | Logica de negocio, validaciones |
| **UI Tests** | Compose UI Test | Flujos criticos | Login, crear evento, PDF |
| **Screenshot Tests** | Paparazzi (Cashapp) | Todas las pantallas | Light/dark, phone/tablet |
| **Integration** | MockWebServer + Hilt | API + Room | Networking, cache |
| **Performance** | Macrobenchmark | Arranque, scroll | Baseline profiles |

---

## 22. CI/CD

### GitHub Actions

| Trigger | Accion | Resultado |
|---------|--------|-----------|
| Push a `develop` | Build + Unit tests + Lint | Feedback en PR |
| Push a `main` | Build + All tests + Bundle | Internal track (Play Console) |
| Tag `v*` | Build + Release + Sign | Production track |

### Baseline Profiles

```kotlin
@RunWith(AndroidJUnit4::class)
class BaselineProfileGenerator {
    @get:Rule val rule = BaselineProfileRule()

    @Test
    fun generateProfile() {
        rule.collect("com.creapolis.solennix") {
            startActivityAndWait()
            // Navigate through critical paths
        }
    }
}
```

---

## 23. Google Play Store Optimization

### Metadata

| Campo | Valor |
|-------|-------|
| **Nombre** | Solennix - Event Planner |
| **Subtitulo** | Eventos, Catering y Banquetes |
| **Categoria** | Business |
| **Precio** | Gratis (con in-app purchases) |
| **Package** | com.creapolis.solennix |
| **Content Rating** | Everyone |

### Screenshots: 6.7" phone (1080x2400), 10" tablet (1600x2560), 7" fold

---

## 24. Plan de Migracion

- App Android nueva publicada en Play Store (nuevo listing O reemplaza RN via update)
- **Misma estrategia que iOS**: no migracion de datos necesaria (server-side)
- Mismas credenciales, fresh login requerido
- Suscripciones Play Store detectadas automaticamente via RevenueCat

---

## 25. Cambios Requeridos en Backend

### 25.1 `POST /auth/google` — Google Sign-In (NUEVO)

**Request:** `{ "id_token": "eyJ...", "full_name": "..." }`

**Logica:** Verificar id_token con Google APIs, crear/vincular cuenta, retornar JWT.

**Cambios DB:** Columna `google_user_id VARCHAR(255) UNIQUE` en tabla `users`.

### 25.2 FCM Push Support

**Nuevo en PushService:** Agregar `sendToFCM()` ademas de `sendToAPNs()`. La tabla `device_tokens` ya soporta `platform = 'android'`.

**Environment variables:** `FCM_PROJECT_ID`, `FCM_SERVICE_ACCOUNT_KEY`

### 25.3 Migrations Nuevas

| # | Migration | Descripcion |
|---|-----------|-------------|
| 027 | `add_google_auth` | Agrega `google_user_id` a users |

(Las migrations 025-026 de iOS ya cubren Apple auth y device_tokens)

---

## 26. Rollout por Fases

### v1: Fases 1-6 (~20 semanas, paralelo a iOS)

#### Fase 1: Foundation (Semanas 1-4) ✅ COMPLETADA

- [x] Crear proyecto Android con Gradle multi-modulo
- [x] Implementar core:designsystem (colores, tipografia, spacing, componentes base)
- [x] Implementar core:network (Ktor client, AuthManager, endpoints)
- [x] Implementar core:model (data classes Serializable)
- [x] Auth screens: Login, Register, Forgot/Reset Password
- [x] Google One Tap sign-in (+ endpoint backend `POST /auth/google`)
- [x] Biometric unlock (BiometricPrompt)
- [x] Navegacion: NavigationBar (phone) + NavigationRail (tablet)
- [x] Deep linking (`solennix://reset-password`)
- [x] Dark mode (SolennixTheme)
- [x] CI/CD: GitHub Actions (build + test on push)

#### Fase 2: Core Screens (Semanas 5-8) ✅ COMPLETADA

- [x] DashboardScreen (KPIs, Vico charts, proximos eventos, stock bajo)
- [x] CalendarScreen (grid, dots, vista dual, filtros)
- [x] ClientListScreen, ClientFormScreen, ClientDetailScreen
- [x] SearchScreen
- [x] Room database setup (cache)
- [x] Pull-to-refresh en todas las listas

#### Fase 3: Events (Semanas 9-12) ✅ COMPLETADA

- [x] EventFormScreen wizard de 6 pasos (HorizontalPager) — Equipment + Supplies añadidos
- [x] EventDetailScreen, EventChecklistScreen
- [x] 6 PDF generators con PdfDocument + Canvas
- [x] Photo gallery (upload + display con Coil 3)

#### Fase 4: Catalog & Settings (Semanas 13-15) ✅ COMPLETADA

- [x] Products, Inventory screens completos
- [x] Settings screens completos
- [x] Google Play Billing v7 (suscripciones)
- [x] Plan limits enforcement (PlanLimitsManager)
- [x] SubscriptionScreen con planes Pro mensual/anual

#### Fase 5: Native Enhancements (Semanas 16-18) ✅ COMPLETADA

- [x] Glance widgets (upcoming events + KPI)
- [x] Quick Settings tile (NewEventTileService)
- [x] App Shortcuts (long-press icon)
- [x] FCM push notifications
- [x] Haptic feedback (HapticFeedbackManager)
- [x] WorkManager background sync (SyncWorker)

#### Fase 6: Polish & Launch (Semanas 19-20) ✅ COMPLETADA

- [x] Tablet optimization (NavigationRail, list-detail)
- [x] Calendar view mode toggle (Calendar vs List)
- [x] Calendar status filters + search
- [x] Onboarding checklist for new users
- [x] Upgrade banners for plan limits
- [ ] Accessibility audit (TalkBack, font scaling) — Pendiente
- [ ] Performance (baseline profiles, R8) — Pendiente
- [ ] Screenshot tests (Paparazzi) — Pendiente
- [ ] Internal testing → Open testing → Production — Pendiente
- [ ] Play Store listing — Pendiente

### v2: Post-Launch

| Feature | Descripcion | Prioridad | Estado |
|---------|-------------|-----------|--------|
| Wear OS | Tile con proximos eventos | Media | Pendiente |
| Android Auto | Lectura de eventos del dia | Baja | Pendiente |
| ChromeOS optimization | Keyboard/mouse/trackpad | Media | Pendiente |
| Offline mode completo | WorkManager sync queue | Media | ✅ Implementado (SyncWorker) |
| i18n (English) | strings.xml traducido | Media | Pendiente |
| Unavailable Dates | Bloquear fechas para vacaciones | Baja | Pendiente |
| Quick Quote | Cotizacion rapida sin evento completo | Baja | Pendiente |

---

## 27. Metricas de Exito

| Metrica | Actual (RN) | Objetivo (Nativo) | Metodo |
|---------|-------------|-------------------|--------|
| Arranque en frio | ~2.8s | < 1.0s | Macrobenchmark |
| Tamano APK | ~50MB | < 20MB | Android Studio Analyzer |
| Scroll FPS | 40-50 fps | 60 fps constante | GPU Profiler |
| Generacion PDF | ~3.5s | < 0.5s | Unit test measure |
| Crash-free rate | ~97% | > 99.5% | Sentry / Play Console |
| Memoria (Dashboard) | ~130MB | < 65MB | Memory Profiler |

---

## 28. Analisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|------------|
| Fragmentacion Android (diferentes APIs) | Alta | Medio | API 26+ cubre 97%. Compat libraries para features nuevas. WindowSizeClass para layouts. |
| Compose en Material 3 aun madurando | Media | Medio | Usar versiones estables. Fallback a Material 2 si hay bugs criticos. |
| Google Play Billing complejidad | Media | Medio | RevenueCat como fallback. Testing con Play Console sandbox. |
| Samsung custom skins rompen UI | Media | Bajo | Testing en Samsung Galaxy S y Tab. Evitar dependencia de APIs Samsung-especificas. |
| Foldable edge cases | Media | Bajo | Foldable es bonus feature, no critica. Testing con emulador de fold. |
| Tiempo de desarrollo excede estimacion | Alta | Medio | Rollout por fases — cada fase produce app usable. Fases 1-4 son MVP. |

---

## 29. Estado de Implementacion (Marzo 2026)

### Resumen de Paridad de Features

| Area | Estado | Notas |
|------|--------|-------|
| Arquitectura | ✅ Completa | Clean architecture, Compose, MVVM, Hilt, Room |
| Autenticacion | ✅ Completa | Login, registro, reset, biometrico, Google Sign-In |
| Eventos CRUD | ✅ Completa | Wizard 6 pasos con equipment/supplies |
| Event Checklist | ✅ Completa | Checklist interactivo con persistencia |
| Clientes CRUD | ✅ Completa | Full functionality |
| Productos CRUD | ✅ Completa | Full functionality con ingredientes |
| Inventario CRUD | ✅ Completa | Full functionality con alertas stock bajo |
| Calendario | ✅ Completa | Vista dual (calendar/list), filtros por status, busqueda |
| Settings | ✅ Completa | Todas las pantallas implementadas |
| PDF Generation | ✅ Completa | 6 tipos (Budget, Contract, Checklist, Equipment, ShoppingList, Invoice) |
| Photo Gallery | ✅ Completa | Upload desde camara/galeria, visualizacion con Coil 3 |
| Widgets | ✅ Completa | Glance-based KPI y Events widgets |
| Plan Limits | ✅ Completa | PlanLimitsManager + UpgradeBanner |
| In-App Billing | ✅ Completa | Google Play Billing v7 |
| Background Sync | ✅ Completa | WorkManager SyncWorker |
| Haptic Feedback | ✅ Completa | HapticFeedbackManager |

### Archivos Implementados por Fase

#### Fase 1: Event Form Enhancement

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `StepEquipment.kt` | `feature/events/ui/` | Paso 4 del wizard: seleccion de equipo con deteccion de conflictos |
| `StepSupplies.kt` | `feature/events/ui/` | Paso 5 del wizard: suministros sugeridos y manuales |
| `EventFormViewModel.kt` | `feature/events/viewmodel/` | Estado para equipment/supplies, conflictos |

#### Fase 2: Event Checklist

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `EventChecklistScreen.kt` | `feature/events/ui/` | Pantalla de checklist interactivo |
| `EventChecklistViewModel.kt` | `feature/events/viewmodel/` | Estado y persistencia del checklist |
| Ruta: `events/{eventId}/checklist` | Navigation | Deep link al checklist |

#### Fase 3: Calendar Enhancements

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `CalendarScreen.kt` | `feature/calendar/ui/` | Vista dual calendar/list, filtros, busqueda |
| `CalendarViewModel.kt` | `feature/calendar/viewmodel/` | `CalendarViewMode`, `StatusFilter`, search state |
| `ViewModeToggle` | Composable | SegmentedButton para cambiar vista |
| `StatusFilterRow` | Composable | FilterChips para filtrar por status |
| `ListViewContent` | Composable | Vista lista con busqueda |

#### Fase 4: Photo Gallery

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `EventPhoto.kt` | `core/model/` | Modelo de datos para fotos |
| `PhotoGallerySheet.kt` | `feature/events/ui/` | Bottom sheet con galeria y upload |
| `PhotoPicker.kt` | `feature/events/ui/` | Selector de camara/galeria |
| `EventDetailViewModel.kt` | Actualizado | Estado para fotos, upload, delete |

#### Fase 5: PDF Generation (Shopping List + Invoice)

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `ShoppingListPdfGenerator.kt` | `feature/events/pdf/` | Lista de compras para el evento |
| `InvoicePdfGenerator.kt` | `feature/events/pdf/` | Factura completa con desglose fiscal |
| `PdfPageManager.kt` | `feature/events/pdf/` | Utilidad compartida para paginacion |
| `PdfConstants.kt` | `feature/events/pdf/` | Constantes de estilos y formato |

#### Fase 6: Plan Limits & Onboarding

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `PlanLimitsManager.kt` | `core/data/plan/` | Gestion de limites por plan (3 eventos/mes, 50 clientes, 20 productos) |
| `UpgradeBanner.kt` | `core/designsystem/component/` | Banner de upgrade cuando se acerca al limite |
| `OnboardingChecklist.kt` | `feature/dashboard/ui/` | Checklist de primeros pasos para nuevos usuarios |
| `OnboardingStep` | Data class | Modelo para pasos de onboarding |

#### Fase 7: In-App Billing

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `BillingManager.kt` | `feature/settings/billing/` | Google Play Billing v7 integration |
| `SubscriptionScreen.kt` | `feature/settings/ui/` | UI para ver/comprar suscripciones |
| `SubscriptionViewModel.kt` | `feature/settings/viewmodel/` | Estado de billing y purchases |
| Product IDs | `pro_monthly`, `pro_annual` | SKUs en Play Console |

#### Fase 8: Lower Priority Features

| Archivo | Ubicacion | Descripcion |
|---------|-----------|-------------|
| `HapticFeedback.kt` | `core/designsystem/util/` | `HapticFeedbackManager` + `HapticFeedbackType` enum |
| `SyncWorker.kt` | `app/sync/` | WorkManager periodic sync (15 min) |
| `rememberHapticFeedback()` | Composable | Helper para haptics en Compose |

### Dependencias Agregadas

```toml
# gradle/libs.versions.toml
billing = "7.1.1"
workmanager = "2.10.0"

[libraries]
billing = { group = "com.android.billingclient", name = "billing-ktx", version.ref = "billing" }
work-runtime = { group = "androidx.work", name = "work-runtime-ktx", version.ref = "workmanager" }
hilt-work = { group = "androidx.hilt", name = "hilt-work", version = "1.2.0" }
hilt-work-compiler = { group = "androidx.hilt", name = "hilt-compiler", version = "1.2.0" }
```

### Estructura Final del Proyecto

```
android/
├── app/
│   └── src/main/java/com/creapolis/solennix/
│       ├── SolennixApp.kt
│       ├── MainActivity.kt
│       ├── MainNavHost.kt
│       ├── service/
│       │   └── NewEventTileService.kt          # Quick Settings tile
│       └── sync/
│           └── SyncWorker.kt                   # Background sync ✅ NUEVO
│
├── core/
│   ├── model/
│   │   ├── EventPhoto.kt                       # ✅ NUEVO
│   │   └── ... (User, Client, Event, Product, etc.)
│   ├── data/
│   │   ├── plan/
│   │   │   └── PlanLimitsManager.kt            # ✅ NUEVO
│   │   └── repository/
│   └── designsystem/
│       ├── component/
│       │   ├── UpgradeBanner.kt                # ✅ NUEVO
│       │   └── ... (otros componentes)
│       └── util/
│           └── HapticFeedback.kt               # ✅ NUEVO
│
├── feature/
│   ├── dashboard/
│   │   └── ui/
│   │       ├── DashboardScreen.kt
│   │       └── OnboardingChecklist.kt          # ✅ NUEVO
│   ├── calendar/
│   │   ├── ui/
│   │   │   └── CalendarScreen.kt               # ✅ ACTUALIZADO (vista dual, filtros)
│   │   └── viewmodel/
│   │       └── CalendarViewModel.kt            # ✅ ACTUALIZADO
│   ├── events/
│   │   ├── ui/
│   │   │   ├── EventFormScreen.kt              # ✅ ACTUALIZADO (6 pasos)
│   │   │   ├── EventDetailScreen.kt            # ✅ ACTUALIZADO (fotos)
│   │   │   ├── EventChecklistScreen.kt         # ✅ NUEVO
│   │   │   ├── PhotoGallerySheet.kt            # ✅ NUEVO
│   │   │   ├── StepEquipment.kt                # ✅ NUEVO
│   │   │   └── StepSupplies.kt                 # ✅ NUEVO
│   │   ├── viewmodel/
│   │   │   ├── EventFormViewModel.kt           # ✅ ACTUALIZADO
│   │   │   ├── EventDetailViewModel.kt         # ✅ ACTUALIZADO
│   │   │   └── EventChecklistViewModel.kt      # ✅ NUEVO
│   │   └── pdf/
│   │       ├── BudgetPdfGenerator.kt
│   │       ├── ContractPdfGenerator.kt
│   │       ├── ChecklistPdfGenerator.kt
│   │       ├── EquipmentPdfGenerator.kt
│   │       ├── ShoppingListPdfGenerator.kt     # ✅ NUEVO
│   │       ├── InvoicePdfGenerator.kt          # ✅ NUEVO
│   │       ├── PdfPageManager.kt
│   │       └── PdfConstants.kt
│   └── settings/
│       ├── ui/
│       │   └── SubscriptionScreen.kt           # ✅ NUEVO
│       ├── viewmodel/
│       │   └── SubscriptionViewModel.kt        # ✅ NUEVO
│       └── billing/
│           └── BillingManager.kt               # ✅ NUEVO
│
└── widget/
    ├── UpcomingEventsWidget.kt
    └── KPIWidget.kt
```

---

## 30. Apendices

### A. Modelo de Datos Completo

Ver `mobile/src/types/entities.ts` para tipos. Seccion 13.1 de este PRD contiene mapeo a Kotlin data classes.

### B. API Endpoints

Ver `backend/internal/router/router.go`. Seccion 13.3 referencia el listado del PRD iOS (identico).

### C. Database Schema

24 migrations existentes + 3 nuevas (025: Apple auth, 026: device_tokens, 027: Google auth).

### D. Documentos de Referencia

| Documento | Ubicacion |
|-----------|-----------|
| PRD iOS Nativo | `docs/native-ios/PRD-NATIVE-IOS.md` |
| Brand Manual | `marketing/brand-manual/BRAND-MANUAL.md` |
| UI Design Guide | `docs/design/ui-design-guide.md` |
| System Overview | `docs/architecture/system-overview.md` |

### E. Comparativa de Libraries

| Funcionalidad | iOS | Android |
|--------------|-----|---------|
| UI Framework | SwiftUI | Jetpack Compose |
| State | @Observable | StateFlow + MutableState |
| DI | @Environment | Hilt (Dagger) |
| Navigation | NavigationStack | Navigation Compose |
| Images | Kingfisher | Coil 3 |
| Charts | Swift Charts | Vico |
| Networking | URLSession | Ktor Client |
| Local DB | SwiftData | Room |
| Key-Value | @AppStorage | DataStore |
| Secure Storage | Keychain | EncryptedSharedPreferences |
| PDF | UIGraphicsPDFRenderer | PdfDocument + Canvas |
| Auth Social | Sign in with Apple | Google One Tap |
| IAP | StoreKit 2 | Play Billing v7 |
| Push | APNs | FCM |
| Widgets | WidgetKit | Glance |
| Analytics | TelemetryDeck | Firebase Analytics |
| CI/CD | Xcode Cloud | GitHub Actions |

### F. Glosario

| Termino | Definicion |
|---------|-----------|
| **FAB** | Floating Action Button — boton flotante para crear evento |
| **KPI** | Key Performance Indicator — metricas del dashboard |
| **HIG** | Human Interface Guidelines (Apple) / Material Design Guidelines (Google) |
| **FCM** | Firebase Cloud Messaging — notificaciones push de Google |
| **Glance** | Framework de widgets para Android (Compose-based) |
| **Hilt** | Framework de inyeccion de dependencias para Android (basado en Dagger) |
| **Room** | Libreria de persistencia SQL para Android con soporte Flow |
| **Ktor** | Framework HTTP client de JetBrains para Kotlin |
| **WindowSizeClass** | Clasifica ventanas en Compact/Medium/Expanded para layouts adaptativos |
| **NavigationRail** | Barra de navegacion vertical para tablets (Material 3) |
| **Baseline Profiles** | Perfiles de compilacion AOT para mejorar arranque en Android |

---

> **"CADA DETALLE IMPORTA"** — Este PRD documenta cada detalle de la app nativa Solennix para Android.
> La consistencia cross-platform garantiza que todo usuario de Solennix se sienta en casa.

---

*PRD v1.1 — Marzo 2026*
*Solennix Native Android & Tablets*
*Feature Parity: 100% — Pendiente QA y lanzamiento*
