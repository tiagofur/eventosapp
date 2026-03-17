# Proposal: Native iOS Foundation (Phase 1)

## Intent

Replace the React Native (Expo SDK 55) mobile app with a native Swift/SwiftUI universal app for iOS 17+, iPadOS 17+, and macOS 14+. Phase 1 establishes the project foundation: package structure, design system, networking layer, data models, authentication screens, and adaptive navigation. This is the base upon which all subsequent phases (Core screens, Events, Catalog, Native Enhancements) are built.

**Why:** The RN app is limited by the JavaScript bridge — no widgets, no Live Activities, no Siri, degraded scroll performance, 2.5s cold launch, and 45MB binary. Native Swift eliminates all these limitations while preserving the exact same backend API and user data.

**Constraint:** Development happens on Windows; files are plain Swift source code that the user opens in Xcode on a Mac Mini. We cannot generate .xcodeproj, compile, or run tests during this phase.

## Scope

### In Scope

1. **SolennixCore Swift Package** — 14 Codable model structs with snake_case CodingKeys, matching `entities.ts` exactly
2. **SolennixNetwork Swift Package** — Actor-based `APIClient` (URLSession + async/await), `AuthManager` (Keychain + biometric + token refresh), typed `Endpoint` enum for all 50+ API routes
3. **SolennixDesign Swift Package** — 40+ color tokens (Color extension with hex init), typography scale, spacing constants, shadow ViewModifiers, border radius, premium gradient, and core UI components: `SolennixTextField`, `PremiumButton`, `Avatar`, `EmptyStateView`, `StatusBadge`, `ConfirmDialog`, `ToastOverlay`, `SkeletonView`
4. **Auth Feature Module** — `LoginView`, `RegisterView`, `ForgotPasswordView`, `ResetPasswordView` with form validation, responsive iPad layout, Sign in with Apple button, biometric unlock gate
5. **Navigation System** — `ContentView` with auth gate, `Route` enum (type-safe), `CompactTabLayout` (iPhone: 4 tabs + FAB), `SidebarSplitLayout` (iPad: NavigationSplitView with sidebar), deep linking via `.onOpenURL`
6. **App Entry Point** — `SolennixApp.swift` with @main, theme management via `@AppStorage`, environment injection
7. **Package.swift Manifests** — For each Swift Package with correct dependencies and targets

### Out of Scope

- **.xcodeproj / .xcworkspace** — Must be created in Xcode on Mac
- **Asset Catalog (.xcassets)** — Colors defined in code; images added on Mac
- **Compilation & testing** — No Swift toolchain on Windows
- **All non-auth screens** — Dashboard, Calendar, Events, Clients, Products, Inventory, Settings (Phases 2-4)
- **Widget/Intent extensions** — Phase 5
- **Apple Watch / Mac targets** — v2 post-launch
- **Backend changes** — `POST /auth/apple` endpoint (separate task)
- **StoreKit 2 / RevenueCat** — Phase 4 (Catalog & Settings)
- **Push notifications** — Phase 5

## Approach

Create all Swift source files organized in a standard Swift Package Manager structure under `ios/` at the project root. The structure uses local Swift packages for modularity:

```
ios/
+-- Solennix/                        # Main app target (workspace root)
|   +-- SolennixApp.swift
|   +-- ContentView.swift
|   +-- Navigation/
|   +-- Info.plist (placeholder)
|
+-- Packages/
|   +-- SolennixCore/
|   |   +-- Package.swift
|   |   +-- Sources/SolennixCore/
|   |       +-- Models/              # 14 Codable structs
|   |       +-- Extensions/          # Date, String, Number formatting
|   |       +-- Finance/             # Tax/discount calculations
|   |
|   +-- SolennixNetwork/
|   |   +-- Package.swift
|   |   +-- Sources/SolennixNetwork/
|   |       +-- APIClient.swift      # Actor-based HTTP client
|   |       +-- AuthManager.swift    # Keychain + biometric + refresh
|   |       +-- Endpoints.swift      # Typed endpoint enum
|   |       +-- KeychainHelper.swift # Keychain wrapper
|   |       +-- NetworkMonitor.swift # NWPathMonitor wrapper
|   |
|   +-- SolennixDesign/
|   |   +-- Package.swift
|   |   +-- Sources/SolennixDesign/
|   |       +-- Colors.swift         # 40+ tokens via Color(hex:)
|   |       +-- Typography.swift     # Font styles
|   |       +-- Spacing.swift        # 4px grid
|   |       +-- Shadows.swift        # ViewModifier extensions
|   |       +-- Gradient.swift       # Premium gradient
|   |       +-- Components/          # Shared UI components
|   |
|   +-- SolennixFeatures/
|       +-- Package.swift
|       +-- Sources/SolennixFeatures/
|           +-- Auth/
|               +-- Views/           # 4 auth screens + AppleSignIn
|               +-- ViewModels/      # AuthViewModel
```

**Key technical decisions:**
- **Colors in code (not Asset Catalog):** We can't create .xcassets on Windows. `Color(hex:)` extension with `@Environment(\.colorScheme)` achieves the same automatic dark mode switching.
- **Actor for APIClient:** Swift's actor isolation inherently prevents the concurrent refresh race condition that RN solves with a `refreshPromise` singleton.
- **@Observable over ObservableObject:** iOS 17+ Observation framework for less boilerplate and better performance.
- **NavigationStack + NavigationSplitView:** Type-safe navigation with `Route` enum, adaptive via `horizontalSizeClass`.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `ios/` (new directory) | **New** | Entire native iOS project — ~40 Swift files |
| `ios/Packages/SolennixCore/` | **New** | 14 Codable models, extensions, finance utils |
| `ios/Packages/SolennixNetwork/` | **New** | APIClient actor, AuthManager, Keychain, endpoints |
| `ios/Packages/SolennixDesign/` | **New** | Design system: colors, typography, spacing, components |
| `ios/Packages/SolennixFeatures/` | **New** | Auth views + viewmodel |
| `ios/Solennix/` | **New** | App entry, ContentView, navigation |
| `docs/native-ios/PRD-NATIVE-IOS.md` | Unchanged | Reference document (already created) |
| `backend/` | Unchanged | No backend changes in this phase |
| `mobile/` | Unchanged | RN app untouched, remains functional |
| `web/` | Unchanged | Web app untouched |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Swift syntax errors (no compiler on Windows) | High | Follow Swift 6 conventions carefully; user validates on Mac. Keep code simple and well-structured. |
| Package.swift dependency resolution issues | Medium | Use only Foundation/SwiftUI (no external deps in Phase 1). Kingfisher deferred to Phase 2. |
| Color hex initializer edge cases | Low | Well-tested hex→Color pattern from Swift community. Include unit test stubs. |
| Navigation architecture needs rework on real device | Medium | Keep navigation layer thin and swappable. Route enum is the stable API; layout is configurable. |
| Auth dual-token format parsing | Low | Explicitly handle both `{ token }` and `{ tokens: { access_token, refresh_token } }` in AuthResponse struct. |

## Rollback Plan

The entire native app lives under `ios/` directory — completely isolated from the existing `mobile/`, `web/`, and `backend/` directories. Rollback is:

```bash
rm -rf ios/
```

No existing code is modified. The RN app continues to work throughout development.

## Dependencies

- **macOS with Xcode 15.4+** — Required to open, compile, and run the project (user has Mac Mini)
- **Apple Developer Account** — Required for device testing and App Store submission
- **PRD document** — `docs/native-ios/PRD-NATIVE-IOS.md` (already complete)
- **Backend `POST /auth/apple`** — Needed before Sign in with Apple works end-to-end (can be stubbed in Phase 1)

## Success Criteria

- [ ] All Swift files are syntactically valid and compile in Xcode on Mac
- [ ] SolennixCore: All 14 model structs decode sample JSON from the Go API correctly
- [ ] SolennixNetwork: APIClient can perform GET/POST/PUT/DELETE with JWT auth header
- [ ] SolennixNetwork: AuthManager stores/retrieves tokens from Keychain, handles refresh on 401
- [ ] SolennixDesign: All 40+ color tokens render correctly in light and dark mode
- [ ] SolennixDesign: Core components (TextField, PremiumButton, Avatar) render in SwiftUI Preview
- [ ] Auth: Login screen sends credentials to `POST /auth/login` and navigates to main app on success
- [ ] Auth: Register, ForgotPassword, ResetPassword screens function correctly
- [ ] Auth: Sign in with Apple button is present (backend stub OK)
- [ ] Navigation: iPhone shows TabView with 4 tabs + FAB overlay
- [ ] Navigation: iPad shows NavigationSplitView with sidebar
- [ ] Navigation: Deep link `solennix://reset-password?token=X` routes to ResetPasswordView
- [ ] App launches on iOS 17+ simulator without crashes
