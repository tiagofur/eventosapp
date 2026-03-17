# Tasks: native-ios-foundation

**Change:** native-ios-foundation
**Depends on:** spec.md, design.md
**Phase:** 1 (Foundation)
**Total tasks:** 8
**Estimated files:** ~48 Swift files (including Package.swift manifests)

---

## Task 1: Project Structure & Package Manifests

Create the `ios/` directory tree and all four `Package.swift` manifests with correct dependency declarations. Create the `Info.plist` placeholder. This task produces the skeleton that all subsequent tasks write into.

- [ ] Create `ios/Solennix/` directory (app target root)
- [ ] Create `ios/Solennix/Navigation/` directory
- [ ] Create `ios/Packages/SolennixCore/Sources/SolennixCore/Models/` directory
- [ ] Create `ios/Packages/SolennixCore/Sources/SolennixCore/Extensions/` directory
- [ ] Create `ios/Packages/SolennixCore/Sources/SolennixCore/Finance/` directory
- [ ] Create `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/` directory
- [ ] Create `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/` directory
- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/` directory
- [ ] Create `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/ViewModels/` directory
- [ ] Write `ios/Packages/SolennixCore/Package.swift` — platforms iOS 17+/macOS 14+, no external deps
- [ ] Write `ios/Packages/SolennixNetwork/Package.swift` — depends on SolennixCore (local path)
- [ ] Write `ios/Packages/SolennixDesign/Package.swift` — no external deps
- [ ] Write `ios/Packages/SolennixFeatures/Package.swift` — depends on SolennixCore, SolennixNetwork, SolennixDesign
- [ ] Write `ios/Solennix/Info.plist` — placeholder with bundle ID `com.creapolis.solennix`, URL scheme `solennix`

**Files:**
- `ios/Packages/SolennixCore/Package.swift`
- `ios/Packages/SolennixNetwork/Package.swift`
- `ios/Packages/SolennixDesign/Package.swift`
- `ios/Packages/SolennixFeatures/Package.swift`
- `ios/Solennix/Info.plist`

**Depends on:** nothing

---

## Task 2: SolennixCore — Models & Extensions

Write all 14 Codable model structs plus `AnyCodable`, the 6 enums (`Plan`, `EventStatus`, `DiscountType`, `InventoryType`, `SupplySource`, `ConflictType`), `EmptyResponse`, `APIError`, and the 3 extension files. Every struct must conform to `Codable, Identifiable` (except `EquipmentConflict` which is `Codable` only). All use explicit `CodingKeys` with `snake_case` mapping. Source of truth: spec.md section 1.

- [ ] Write `User.swift` — includes nested `Plan` enum (basic, premium)
- [ ] Write `Client.swift`
- [ ] Write `Event.swift` — includes `EventStatus` and `DiscountType` enums
- [ ] Write `Product.swift`
- [ ] Write `InventoryItem.swift` — includes `InventoryType` enum
- [ ] Write `EventProduct.swift`
- [ ] Write `EventExtra.swift`
- [ ] Write `EventEquipment.swift`
- [ ] Write `EventSupply.swift` — includes `SupplySource` enum
- [ ] Write `ProductIngredient.swift`
- [ ] Write `Payment.swift`
- [ ] Write `EquipmentConflict.swift` — includes `ConflictType` enum, NOT Identifiable
- [ ] Write `SupplySuggestion.swift`
- [ ] Write `EquipmentSuggestion.swift`
- [ ] Write `AnyCodable.swift` — wrapper for arbitrary JSON via JSONSerialization
- [ ] Write `Date+Formatting.swift` — `formatted(as:)` with `es_MX` locale, relative date strings
- [ ] Write `String+Validation.swift` — `isValidEmail`, `isNotEmpty`
- [ ] Write `Double+Currency.swift` — `asMXN` property using NumberFormatter, locale `es_MX`, currency `MXN`

**Files:**
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/User.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/Client.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/Event.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/Product.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/InventoryItem.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EventProduct.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EventExtra.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EventEquipment.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EventSupply.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/ProductIngredient.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/Payment.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EquipmentConflict.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/SupplySuggestion.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/EquipmentSuggestion.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Models/AnyCodable.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Extensions/Date+Formatting.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Extensions/String+Validation.swift`
- `ios/Packages/SolennixCore/Sources/SolennixCore/Extensions/Double+Currency.swift`

**Depends on:** Task 1 (directory structure)

---

## Task 3: SolennixDesign — Tokens (Colors, Typography, Spacing, Shadows, Gradient)

Write the design token files. Colors use the `UIColor` dynamic provider pattern from design.md section 5 so that light/dark mode works without Asset Catalogs. Includes `Color(hex:)` and `UIColor(hex:)` initializers, the `Color.adaptive(light:dark:)` factory, all 43 color tokens, typography scale with Cinzel brand fonts, spacing constants (4px grid), border radius tokens, shadow ViewModifiers, and the premium gradient.

- [ ] Write `Colors.swift` — `Color(hex:)`, `UIColor(hex:)`, `Color.adaptive(light:dark:)`, all 43 tokens organized by section (Brand, Surfaces, Text, Borders, Semantic, Event Status, KPI, Tab Bar, Avatar palette)
- [ ] Write `Typography.swift` — font style extensions including `h1Premium`, system scale, and Cinzel brand fonts (`solennixTitle`, `solennixSubtitle`)
- [ ] Write `Spacing.swift` — `enum Spacing` with static constants: `xxs` through `xxxl`, plus `BorderRadius` tokens (`radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `radiusCard`)
- [ ] Write `Shadows.swift` — `View` extension with `.shadowSm()`, `.shadowMd()`, `.shadowLg()`, `.shadowFab()` modifiers
- [ ] Write `Gradient.swift` — `premiumGradient` LinearGradient from `solennixGold` to `solennixGoldDark`

**Files:**
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Colors.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Typography.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Spacing.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Shadows.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Gradient.swift`

**Depends on:** Task 1 (directory structure)

---

## Task 4: SolennixDesign — Components

Write the 8 reusable UI components defined in spec.md section 3.7. Each component uses the design tokens from Task 3 (colors, typography, spacing, shadows). Components are self-contained SwiftUI views in the `Components/` subdirectory.

- [ ] Write `SolennixTextField.swift` — props: title, text binding, placeholder, icon (SF Symbol), isSecure with eye toggle, keyboardType, textContentType, errorMessage, isDisabled. Uses `@FocusState`.
- [ ] Write `PremiumButton.swift` — props: title, icon, style (.primary/.secondary/.destructive), isLoading (shows ProgressView), isDisabled, action. Primary style uses `premiumGradient`.
- [ ] Write `Avatar.swift` — props: name, photoUrl, size. Shows initials fallback with deterministic color from avatar palette. AsyncImage for photoUrl.
- [ ] Write `EmptyStateView.swift` — props: icon (SF Symbol), title, message, optional actionTitle + action. Centered layout.
- [ ] Write `StatusBadge.swift` — props: status (EventStatus). Colored pill using event status color tokens.
- [ ] Write `ConfirmDialog.swift` — ViewModifier wrapping `.confirmationDialog`. Props: isPresented, title, message, confirmTitle, confirmRole, onConfirm.
- [ ] Write `ToastOverlay.swift` — props: message, type (.success/.error/.info/.warning), isPresented binding. Auto-dismiss after 3s, slides from top.
- [ ] Write `SkeletonView.swift` — shimmer effect ViewModifier using `.redacted(reason: .placeholder)` with animation overlay.

**Files:**
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/SolennixTextField.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/PremiumButton.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/Avatar.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/EmptyStateView.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/StatusBadge.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/ConfirmDialog.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/ToastOverlay.swift`
- `ios/Packages/SolennixDesign/Sources/SolennixDesign/Components/SkeletonView.swift`

**Depends on:** Task 3 (design tokens)

---

## Task 5: SolennixNetwork — APIClient, AuthManager, Keychain, Endpoints, NetworkMonitor

Write the full networking layer. The `APIClient` is an actor with token refresh logic (design.md section 3). `AuthManager` is `@Observable` with Keychain-backed token storage, biometric gate, dual-token response handling, and session restore (design.md section 4). `KeychainHelper` wraps the Security framework. `Endpoint` is an enum with `path` and `method` for all 30+ API routes. `NetworkMonitor` wraps `NWPathMonitor`. Also includes `APIError` enum and `AuthResponse` with flexible decoding.

- [ ] Write `APIError.swift` — enum with cases: unauthorized, forbidden, notFound, validationFailed([String:String]), serverError(Int), networkUnavailable, decodingFailed(Error), unknown(Error). Conforms to `LocalizedError`.
- [ ] Write `KeychainHelper.swift` — `save(_:for:)`, `read(for:)`, `delete(for:)`, string convenience methods. Uses `kSecClassGenericPassword`, `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
- [ ] Write `Endpoint.swift` — enum with all routes from spec.md section 2.5. Properties: `path: String`, `method: HTTPMethod`. Includes `HTTPMethod` enum (get/post/put/delete).
- [ ] Write `NetworkMonitor.swift` — `@Observable` class wrapping `NWPathMonitor`. Properties: `isConnected`, `connectionType`.
- [ ] Write `AuthManager.swift` — `@Observable` class with `AuthState` enum, `restoreSession()`, `login()`, `register()`, `loginWithApple()`, `logout()`, `refreshToken()`, `getAccessToken()`, `clearTokens()`, `forgotPassword()`, `resetPassword()`, `changePassword()`, `fetchCurrentUser()`, biometric methods. Includes `AuthResponse` struct with dual-token decoding.
- [ ] Write `APIClient.swift` — actor with `request<T>()`, `get()`, `post()`, `put()`, `delete()`, `upload()`. Token refresh flow with continuation-based queuing. `EnvironmentKey` for injection. 30s timeout, `waitsForConnectivity`, snake_case decoder.

**Files:**
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/APIError.swift`
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/KeychainHelper.swift`
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/Endpoint.swift`
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/NetworkMonitor.swift`
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/AuthManager.swift`
- `ios/Packages/SolennixNetwork/Sources/SolennixNetwork/APIClient.swift`

**Depends on:** Task 2 (SolennixCore models — needed for User, AuthResponse decoding)

---

## Task 6: Auth Views & AuthViewModel

Write the 5 auth views and the shared `AuthViewModel`. `LoginView` includes animated logo, Cinzel branding, email/password fields, PremiumButton, Sign in with Apple, forgot-password link, register link, and feature carousel. `RegisterView` has 4 fields + validation + Apple sign-in. `ForgotPasswordView` has email field with success state. `ResetPasswordView` accepts a deep-link token. `AuthFlowView` is a `NavigationStack` wrapper for the auth flow. `AuthViewModel` is `@Observable`, shared across all screens, with validation computed properties.

- [ ] Write `AuthViewModel.swift` — `@Observable` class. Login fields + `login()`, register fields + `register()`, forgot fields + `forgotPassword()`, reset fields + `resetPassword()`. Validation computed props: `isLoginValid`, `isRegisterValid`, `isForgotValid`, `isResetValid`. Depends on `AuthManager` via `@Environment`.
- [ ] Write `LoginView.swift` — Full layout per spec.md section 4.1. Uses `SolennixTextField`, `PremiumButton`, `SignInWithAppleButton` (AuthenticationServices). Cinzel logo text. Feature carousel at bottom.
- [ ] Write `RegisterView.swift` — Layout per spec.md section 4.2. Name, email, password, confirm password. Feature pills. Terms/privacy links.
- [ ] Write `ForgotPasswordView.swift` — Layout per spec.md section 4.3. Email field. Success state with mail icon.
- [ ] Write `ResetPasswordView.swift` — Layout per spec.md section 4.4. Token from deep link. New password + confirm. Success state with checkmark.
- [ ] Write `AppleSignInButton.swift` — Wraps `SignInWithAppleButton` from AuthenticationServices. Handles `ASAuthorization` result, extracts identityToken + authorizationCode + fullName, calls `AuthManager.loginWithApple()`.

**Files:**
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/ViewModels/AuthViewModel.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/LoginView.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/RegisterView.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/ForgotPasswordView.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/ResetPasswordView.swift`
- `ios/Packages/SolennixFeatures/Sources/SolennixFeatures/Auth/Views/AppleSignInButton.swift`

**Depends on:** Task 4 (SolennixDesign components), Task 5 (AuthManager, APIClient)

---

## Task 7: Navigation — Route, Layouts, DeepLinks

Write the navigation layer: `Route` enum (type-safe, Hashable), `Tab` enum, `CompactTabLayout` (iPhone: TabView with 4 tabs + FAB overlay), `SidebarSplitLayout` (iPad: NavigationSplitView), `SidebarView` (sidebar list content), `RouteDestination` (centralized @ViewBuilder switch), and `DeepLinkHandler` (URL parser for `solennix://` scheme). Also write `ContentView.swift` with the auth gate that switches on `AuthManager.authState`.

- [ ] Write `Route.swift` — `Route` enum with all cases from design.md section 6 (resetPassword, eventDetail, eventForm, eventChecklist, clientDetail, clientForm, productDetail, productForm, inventoryDetail, inventoryForm, settings sub-screens). Conforms to `Hashable`.
- [ ] Write `Tab.swift` — `Tab` enum (home, calendar, clients, more) with `CaseIterable`.
- [ ] Write `CompactTabLayout.swift` — 4-tab `TabView`, each with own `NavigationStack(path:)`. FAB overlay. Placeholder root views for Phase 2+ screens.
- [ ] Write `SidebarSplitLayout.swift` — `NavigationSplitView` with sidebar + content + detail. `SidebarSection` enum (dashboard, calendar, clients, products, inventory, search, settings).
- [ ] Write `SidebarView.swift` — `List(selection:)` rendering `SidebarSection` cases with SF Symbol icons and Spanish labels.
- [ ] Write `RouteDestination.swift` — `@ViewBuilder` static func mapping `Route` to views. Phase 1 returns placeholders for non-auth routes.
- [ ] Write `DeepLinkHandler.swift` — Parses `solennix://` URLs. Supports `reset-password?token=X`. Returns `Route?`.
- [ ] Write `ContentView.swift` — Auth gate switching on `authManager.authState`: `.unknown` -> ProgressView, `.unauthenticated` -> LoginView, `.biometricLocked` -> biometric prompt, `.authenticated` -> adaptive layout (compact vs regular).

**Files:**
- `ios/Solennix/Navigation/Route.swift`
- `ios/Solennix/Navigation/Tab.swift`
- `ios/Solennix/Navigation/CompactTabLayout.swift`
- `ios/Solennix/Navigation/SidebarSplitLayout.swift`
- `ios/Solennix/Navigation/SidebarView.swift`
- `ios/Solennix/Navigation/RouteDestination.swift`
- `ios/Solennix/Navigation/DeepLinkHandler.swift`
- `ios/Solennix/ContentView.swift`

**Depends on:** Task 5 (AuthManager for auth gate), Task 6 (auth views referenced by ContentView and RouteDestination)

---

## Task 8: App Entry Point — SolennixApp.swift

Write the `@main` app entry point. Creates and owns the `AuthManager` and `APIClient` instances. Injects them into the SwiftUI environment. Applies `preferredColorScheme` from `@AppStorage("appearance")`. Registers `.onOpenURL` for deep linking via `DeepLinkHandler`. Calls `authManager.restoreSession()` in `.task`. This is the composition root that wires all packages together.

- [ ] Write `SolennixApp.swift` — `@main struct SolennixApp: App`. `@State` for `AuthManager`, `NetworkMonitor`. `@AppStorage("appearance")` with system/light/dark mapping. `WindowGroup` containing `ContentView` with `.environment()` injections, `.onOpenURL` deep link handling, `.task { await authManager.restoreSession() }`.
- [ ] Verify all import statements reference correct package module names (`SolennixCore`, `SolennixNetwork`, `SolennixDesign`, `SolennixFeatures`)

**Files:**
- `ios/Solennix/SolennixApp.swift`

**Depends on:** Task 7 (ContentView, DeepLinkHandler), Task 5 (AuthManager, APIClient, NetworkMonitor)

---

## Dependency Graph

```
Task 1 (Structure + Manifests)
  |
  +---> Task 2 (Core Models)
  |       |
  |       +---> Task 5 (Network Layer)
  |               |
  |               +---> Task 6 (Auth Views)
  |               |       |
  |               |       +---> Task 7 (Navigation)
  |               |               |
  |               |               +---> Task 8 (App Entry)
  |               |
  |               +---> Task 7 (Navigation) [also depends on Task 6]
  |
  +---> Task 3 (Design Tokens)
          |
          +---> Task 4 (Design Components)
                  |
                  +---> Task 6 (Auth Views) [also depends on Task 5]
```

**Critical path:** 1 -> 2 -> 5 -> 6 -> 7 -> 8

**Parallelizable:** Tasks 2 and 3 can run in parallel after Task 1. Task 4 can run as soon as Task 3 completes.

---

## Execution Notes

- **No compiler available:** All code is written on Windows. Swift syntax must follow Swift 5.9+ / iOS 17+ conventions carefully. The user validates on a Mac Mini with Xcode 15.4+.
- **No external dependencies:** Phase 1 uses only Foundation, SwiftUI, Security, LocalAuthentication, AuthenticationServices, and Network frameworks.
- **Placeholder views:** Tasks 7 uses `Text("placeholder")` for screens not yet built (Dashboard, Calendar, Clients list, Products list, Inventory list, Settings). These are replaced in Phases 2-4.
- **Spanish UI strings:** All user-facing text is in Spanish (Mexico). Hardcoded in Phase 1; localization infrastructure deferred.
- **StatusBadge imports SolennixCore:** The `StatusBadge` component needs the `EventStatus` enum from SolennixCore. However, SolennixDesign has no dependency on SolennixCore. Solution: `StatusBadge` accepts a `String` status and maps internally, OR move `EventStatus` display logic to the feature layer. Sub-agent should decide the cleanest approach.
