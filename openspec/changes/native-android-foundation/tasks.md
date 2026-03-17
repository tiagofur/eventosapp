# Tasks: native-android-foundation

**Change:** native-android-foundation
**Depends on:** spec.md, design.md
**Phase:** 1 (Foundation)
**Total tasks:** 8
**Estimated files:** ~50 Kotlin files (including build scripts)

---

## Task 1: Project Structure & Gradle Setup

Create the `android/` directory tree, all `build.gradle.kts` files (root + 5 modules), `settings.gradle.kts`, `gradle/libs.versions.toml`, `gradle.properties`, and `AndroidManifest.xml`. This task produces the skeleton that all subsequent tasks write into.

- [ ] Create `android/` root directory
- [ ] Create `android/app/src/main/java/com/creapolis/solennix/` directory
- [ ] Create `android/app/src/main/java/com/creapolis/solennix/ui/navigation/` directory
- [ ] Create `android/app/src/main/res/values/` directory
- [ ] Create `android/app/src/main/res/font/` directory (for Cinzel TTF files)
- [ ] Create `android/core/model/src/main/java/com/creapolis/solennix/core/model/` directory
- [ ] Create `android/core/model/src/main/java/com/creapolis/solennix/core/model/extensions/` directory
- [ ] Create `android/core/network/src/main/java/com/creapolis/solennix/core/network/` directory
- [ ] Create `android/core/network/src/main/java/com/creapolis/solennix/core/network/di/` directory
- [ ] Create `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/` directory
- [ ] Create `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/` directory
- [ ] Create `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/` directory
- [ ] Create `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/viewmodel/` directory
- [ ] Write `android/gradle/libs.versions.toml` — Full version catalog per design.md section 2
- [ ] Write `android/gradle.properties` — JVM args, Kotlin config, android.useAndroidX=true
- [ ] Write `android/build.gradle.kts` — Root script applying all plugins with `apply false`
- [ ] Write `android/settings.gradle.kts` — Include all 5 modules
- [ ] Write `android/core/model/build.gradle.kts` — Android library, Kotlin serialization
- [ ] Write `android/core/network/build.gradle.kts` — Ktor, Hilt, Security, depends on :core:model
- [ ] Write `android/core/designsystem/build.gradle.kts` — Compose, Coil (no Hilt)
- [ ] Write `android/feature/auth/build.gradle.kts` — Compose, Hilt, Navigation, depends on all core modules
- [ ] Write `android/app/build.gradle.kts` — Application plugin, depends on all modules, applicationId `com.creapolis.solennix`
- [ ] Write `android/app/src/main/AndroidManifest.xml` — MainActivity, deep link intent filter for `solennix://`
- [ ] Write `android/app/src/main/res/values/strings.xml` — App name "Solennix", Spanish base strings
- [ ] Write `android/app/src/main/res/values/themes.xml` — Base Material 3 theme stub

**Files:**
- `android/gradle/libs.versions.toml`
- `android/gradle.properties`
- `android/build.gradle.kts`
- `android/settings.gradle.kts`
- `android/core/model/build.gradle.kts`
- `android/core/network/build.gradle.kts`
- `android/core/designsystem/build.gradle.kts`
- `android/feature/auth/build.gradle.kts`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/res/values/themes.xml`

**Depends on:** nothing

---

## Task 2: core:model — Data Classes & Extensions

Write all 14 `@Serializable` data classes plus `ApiError` sealed class, `AuthResponse`, `TokenPair`, and the 3 extension files. Every data class uses `@SerialName` for snake_case mapping. Source of truth: spec.md section 1.

- [ ] Write `User.kt` — includes nested `Plan` enum (BASIC, PREMIUM)
- [ ] Write `Client.kt`
- [ ] Write `Event.kt` — includes `EventStatus` and `DiscountType` enums
- [ ] Write `Product.kt` — uses `JsonElement?` for recipe field
- [ ] Write `InventoryItem.kt` — includes `InventoryType` enum
- [ ] Write `EventProduct.kt`
- [ ] Write `EventExtra.kt`
- [ ] Write `EventEquipment.kt` — includes joined fields
- [ ] Write `EventSupply.kt` — includes `SupplySource` enum + joined fields
- [ ] Write `ProductIngredient.kt` — includes joined fields
- [ ] Write `Payment.kt`
- [ ] Write `EquipmentConflict.kt` — includes `ConflictType` enum, no id field
- [ ] Write `SupplySuggestion.kt`
- [ ] Write `EquipmentSuggestion.kt`
- [ ] Write `ApiError.kt` — sealed class with 8 cases per spec.md
- [ ] Write `AuthResponse.kt` — dual-format decoding + `TokenPair`
- [ ] Write `extensions/DateFormatting.kt` — `String.toFormattedDate()` with `es_MX` locale
- [ ] Write `extensions/StringValidation.kt` — `String.isValidEmail()` regex
- [ ] Write `extensions/CurrencyFormatting.kt` — `Double.asMXN()` using NumberFormat

**Files:**
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/User.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/Client.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/Event.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/Product.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/InventoryItem.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EventProduct.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EventExtra.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EventEquipment.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EventSupply.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/ProductIngredient.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/Payment.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EquipmentConflict.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/SupplySuggestion.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/EquipmentSuggestion.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/ApiError.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/AuthResponse.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/extensions/DateFormatting.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/extensions/StringValidation.kt`
- `android/core/model/src/main/java/com/creapolis/solennix/core/model/extensions/CurrencyFormatting.kt`

**Depends on:** Task 1 (directory structure + build.gradle.kts)

---

## Task 3: core:designsystem — Theme Tokens

Write the design token files. Colors are defined as raw `Color(0xFF______)` values in two `SolennixColorScheme` instances (light/dark), served via `CompositionLocal`. Includes Typography with Cinzel, Spacing grid, Shape tokens, Elevation tokens, Gradient, and the `SolennixTheme` composable wrapper.

- [ ] Write `Color.kt` — Raw color constants + `LightSolennixColors` + `DarkSolennixColors` instances
- [ ] Write `SolennixColorScheme.kt` — Data class with 43+ color properties + `toMaterialColorScheme()`
- [ ] Write `Typography.kt` — `SolennixTypography` per Material3 `Typography()`, including `CinzelFontFamily`
- [ ] Write `Spacing.kt` — `object Spacing` with `xxs=2.dp` through `xxxl=48.dp`
- [ ] Write `Shape.kt` — `SolennixShapes` with `RoundedCornerShape` tokens
- [ ] Write `Elevation.kt` — `object SolennixElevation` with `sm/md/lg/fab`
- [ ] Write `Gradient.kt` — `SolennixGradient` object with `premiumBrush`
- [ ] Write `Theme.kt` — `SolennixTheme` composable, `LocalSolennixColors`, `SolennixTheme.colors` accessor

**Files:**
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Color.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/SolennixColorScheme.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Typography.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Spacing.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Shape.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Elevation.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Gradient.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/theme/Theme.kt`

**Depends on:** Task 1 (directory structure)

---

## Task 4: core:designsystem — Components

Write the 8 reusable UI components per spec.md section 3.7. Each component uses design tokens from Task 3.

- [ ] Write `SolennixTextField.kt` — OutlinedTextField with label, leadingIcon, password toggle, error message, KeyboardOptions, ImeAction
- [ ] Write `PremiumButton.kt` — Primary (gradient bg), Secondary (outlined), Destructive (red). isLoading → CircularProgressIndicator. `animateContentSize()`.
- [ ] Write `Avatar.kt` — Initials fallback (deterministic color from palette), Coil `AsyncImage` for URL, `CircleShape` clip.
- [ ] Write `EmptyState.kt` — Centered icon + title + message + optional CTA button.
- [ ] Write `StatusBadge.kt` — Colored pill accepting `status: String`, maps to status color tokens.
- [ ] Write `ConfirmDialog.kt` — Material 3 `AlertDialog` with confirm/dismiss. Optional destructive styling.
- [ ] Write `ToastOverlay.kt` — SlideIn from top, auto-dismiss 3s, 4 types (success/error/info/warning) with icons.
- [ ] Write `SkeletonLoading.kt` — Shimmer effect with `rememberInfiniteTransition`, translucent gradient overlay.

**Files:**
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/SolennixTextField.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/PremiumButton.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/Avatar.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/EmptyState.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/StatusBadge.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/ConfirmDialog.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/ToastOverlay.kt`
- `android/core/designsystem/src/main/java/com/creapolis/solennix/core/designsystem/component/SkeletonLoading.kt`

**Depends on:** Task 3 (design tokens)

---

## Task 5: core:network — KtorClient, AuthManager, Endpoints, NetworkMonitor

Write the full networking layer. `KtorClient` configures Ktor HttpClient with Auth plugin (bearer). `AuthManager` handles EncryptedSharedPreferences tokens, biometric gate, and Mutex-protected refresh. `Endpoints` is an object with all route constants. `NetworkModule` provides Hilt bindings.

- [ ] Write `Endpoints.kt` — Object with all 30+ route constants per spec.md section 2.5
- [ ] Write `NetworkMonitor.kt` — `@Singleton` class wrapping `ConnectivityManager.registerDefaultNetworkCallback`. Exposes `isConnected: StateFlow<Boolean>`.
- [ ] Write `AuthManager.kt` — `@Singleton` class with `AuthState` sealed class, `restoreSession()`, `login()`, `register()`, `loginWithGoogle()`, `logout()`, `getBearerTokens()`, `refreshAndGetTokens()` (Mutex), `clearTokens()`, `forgotPassword()`, `resetPassword()`, biometric methods. Dedicated `refreshHttpClient`.
- [ ] Write `KtorClient.kt` — `@Singleton` class creating `HttpClient(OkHttp)` with ContentNegotiation, Auth (bearer), Logging, defaultRequest. 30s timeout.
- [ ] Write `ApiService.kt` — `@Singleton` class with typed `get<T>()`, `post<T>()`, `put<T>()`, `delete()`, `upload()` suspend functions.
- [ ] Write `di/NetworkModule.kt` — `@Module @InstallIn(SingletonComponent)`. Provides `EncryptedSharedPreferences`, `AuthManager`, `KtorClient`, `ApiService`, `NetworkMonitor`.

**Files:**
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/Endpoints.kt`
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/NetworkMonitor.kt`
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/AuthManager.kt`
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/KtorClient.kt`
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/ApiService.kt`
- `android/core/network/src/main/java/com/creapolis/solennix/core/network/di/NetworkModule.kt`

**Depends on:** Task 2 (core:model — needed for User, AuthResponse, ApiError)

---

## Task 6: Auth Screens & AuthViewModel

Write the 6 auth UI files and the shared `AuthViewModel`. `LoginScreen` includes animated logo, Cinzel branding, email/password, PremiumButton, Google One Tap, links. `RegisterScreen` has 4 fields + validation + Google. `ForgotPasswordScreen` has email + success state. `ResetPasswordScreen` accepts deep-link token. `BiometricGateScreen` shows BiometricPrompt. `GoogleSignInButton` wraps Credential Manager API.

- [ ] Write `AuthViewModel.kt` — `@HiltViewModel`. Login/Register/Forgot/Reset fields with `mutableStateOf`. Computed `isLoginValid`, `isRegisterValid`. Suspend `login()`, `register()`, `forgotPassword()`, `resetPassword()` methods with error handling.
- [ ] Write `LoginScreen.kt` — Full layout per spec.md section 4.1. Uses `SolennixTextField`, `PremiumButton`, `GoogleSignInButton`. Cinzel logo. Animated logo (scale + fade).
- [ ] Write `RegisterScreen.kt` — Layout per spec.md section 4.2. Name, email, password, confirm. Feature pills. Terms/privacy links.
- [ ] Write `ForgotPasswordScreen.kt` — Layout per spec.md section 4.3. Email field. Success state.
- [ ] Write `ResetPasswordScreen.kt` — Layout per spec.md section 4.4. Token from deep link. Password + confirm. Success state.
- [ ] Write `BiometricGateScreen.kt` — Shows BiometricPrompt on launch. On success → `authManager.unlockWithBiometric()`. On failure (3x) → `authManager.failedBiometric()`.
- [ ] Write `GoogleSignInButton.kt` — Wraps `CredentialManager.getCredential()` with `GetGoogleIdTokenCredentialRequest`. Extracts `idToken`, calls `authManager.loginWithGoogle()`.

**Files:**
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/viewmodel/AuthViewModel.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/LoginScreen.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/RegisterScreen.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/ForgotPasswordScreen.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/ResetPasswordScreen.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/BiometricGateScreen.kt`
- `android/feature/auth/src/main/java/com/creapolis/solennix/feature/auth/ui/GoogleSignInButton.kt`

**Depends on:** Task 4 (SolennixDesign components), Task 5 (AuthManager, ApiService)

---

## Task 7: Navigation — Routes, Layouts, Deep Links

Write the navigation layer: `Route` sealed class (type-safe, @Serializable), `TopLevelDestination` enum, `SidebarSection` enum, `CompactBottomNavLayout` (phone: NavigationBar + FAB), `AdaptiveNavigationRailLayout` (tablet: NavigationRail), and `AuthNavHost` (NavHost for auth screens). Also write `MainNavHost` with auth gate.

- [ ] Write `Route.kt` — `@Serializable` sealed class with all route cases per spec.md section 5.1
- [ ] Write `TopLevelDestination.kt` — Enum with label, icons, route per spec.md section 5.2
- [ ] Write `SidebarSection.kt` — Enum for NavigationRail items per spec.md section 5.3
- [ ] Write `CompactBottomNavLayout.kt` — `NavigationBar` with 4 items + center FAB. `NavHost` with placeholder destinations for Phase 2+.
- [ ] Write `AdaptiveNavigationRailLayout.kt` — `NavigationRail` on left + content area. Placeholder sections.
- [ ] Write `AuthNavHost.kt` — `NavHost` routing between Login → Register → ForgotPassword → ResetPassword. Includes `navDeepLink` for `solennix://reset-password?token={token}`.
- [ ] Write `MainNavHost.kt` — Auth gate switching on `authState`: Unknown → Loading, Unauthenticated → AuthNavHost, BiometricLocked → BiometricGateScreen, Authenticated → adaptive layout via WindowSizeClass.

**Files:**
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/Route.kt`
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/TopLevelDestination.kt`
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/SidebarSection.kt`
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/CompactBottomNavLayout.kt`
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/AdaptiveNavigationRailLayout.kt`
- `android/app/src/main/java/com/creapolis/solennix/ui/navigation/AuthNavHost.kt`
- `android/app/src/main/java/com/creapolis/solennix/MainNavHost.kt`

**Depends on:** Task 5 (AuthManager for auth gate), Task 6 (auth screens referenced by AuthNavHost)

---

## Task 8: App Entry Point — SolennixApp.kt & MainActivity.kt

Write the `@HiltAndroidApp` Application class and the `@AndroidEntryPoint` single Activity. MainActivity calculates `WindowSizeClass`, applies `SolennixTheme`, and hosts `MainNavHost`. This is the composition root.

- [ ] Write `SolennixApp.kt` — `@HiltAndroidApp class SolennixApp : Application()`. Can initialize Coil, Sentry, etc. in `onCreate()`.
- [ ] Write `MainActivity.kt` — `@AndroidEntryPoint class MainActivity : ComponentActivity()`. Calls `enableEdgeToEdge()`, `calculateWindowSizeClass()`, wraps `MainNavHost` in `SolennixTheme`. Applies `Activity.setContent {}`.
- [ ] Verify all import statements reference correct module packages (`com.creapolis.solennix.core.model`, `com.creapolis.solennix.core.network`, `com.creapolis.solennix.core.designsystem`, `com.creapolis.solennix.feature.auth`)

**Files:**
- `android/app/src/main/java/com/creapolis/solennix/SolennixApp.kt`
- `android/app/src/main/java/com/creapolis/solennix/MainActivity.kt`

**Depends on:** Task 7 (MainNavHost), Task 5 (AuthManager)

---

## Dependency Graph

```
Task 1 (Structure + Gradle Setup)
  |
  +---> Task 2 (Core Models)
  |       |
  |       +---> Task 5 (Network Layer)
  |               |
  |               +---> Task 6 (Auth Screens)
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
                  +---> Task 6 (Auth Screens) [also depends on Task 5]
```

**Critical path:** 1 → 2 → 5 → 6 → 7 → 8

**Parallelizable:** Tasks 2 and 3 can run in parallel after Task 1. Task 4 can run as soon as Task 3 completes.

---

## Execution Notes

- **No Android Studio required for file creation:** All code is written as plain Kotlin files. The user opens the project in Android Studio to compile, run, and test.
- **No external dependencies beyond version catalog:** Phase 1 uses only libraries declared in `libs.versions.toml`. No additional Maven repos beyond google() + mavenCentral().
- **Placeholder views:** Tasks 7 uses `Text("Placeholder — Phase 2")` for screens not yet built (Dashboard, Calendar, Clients list, Products list, Inventory list, Settings). These are replaced in Phases 2-4.
- **Spanish UI strings:** All user-facing text is in Spanish (Mexico). Hardcoded in composables in Phase 1; full `strings.xml` localization in Phase 6.
- **StatusBadge design decision:** `StatusBadge` accepts a `status: String` and maps internally to color tokens, avoiding a dependency from `core:designsystem` → `core:model`. This keeps the design system module dependency-free.
- **Cinzel TTF fonts:** Font files must be manually placed in `res/font/`. Files are referenced via `R.font.cinzel_regular` and `R.font.cinzel_semibold` in `Typography.kt`.
- **Google Web Client ID:** Required for Credential Manager. Set as `BuildConfig.GOOGLE_WEB_CLIENT_ID` in `core:network/build.gradle.kts`. User must create OAuth 2.0 credentials in Google Cloud Console.
- **EncryptedSharedPreferences min API:** Works on API 23+ (our min is 26). Uses AndroidKeyStore for key management — hardware-backed on most devices.
