# Exploration: native-ios-foundation

## Current State

Solennix has a production React Native (Expo SDK 55) app with 31 screens, full auth flow, 50+ REST API endpoints consumed via a custom `ApiClient` class, and a complete design system (40+ color tokens, iOS-aligned typography, 4px spacing grid). The Go backend is stable and untouched.

## Affected Areas (for Phase 1 Foundation)

### Source Files to Replicate in Swift
- `mobile/src/types/entities.ts` — 14 TypeScript interfaces → Swift Codable structs
- `mobile/src/lib/api.ts` — ApiClient class with JWT refresh mutex → Swift actor
- `mobile/src/contexts/AuthContext.tsx` — Auth state (checkAuth, signIn, signUp, signOut, updateProfile) → @Observable AuthManager
- `mobile/src/theme/colors.ts` — 40+ semantic color tokens (light/dark) → Asset Catalog
- `mobile/src/theme/typography.ts` — iOS Dynamic Type scale (already aligned) → SwiftUI .font()
- `mobile/src/theme/spacing.ts` — 4px grid (xxs-xxxl) + border radius → CGFloat constants
- `mobile/src/theme/shadows.ts` — 4 shadow presets → ViewModifier extensions
- `mobile/src/screens/auth/LoginScreen.tsx` — Email/password + responsive tablet layout
- `mobile/src/screens/auth/RegisterScreen.tsx` — Name/email/password/confirm + tablet
- `mobile/src/screens/auth/ForgotPasswordScreen.tsx` — Email recovery
- `mobile/src/screens/auth/ResetPasswordScreen.tsx` — Token-based reset via deep link
- `mobile/src/navigation/RootNavigator.tsx` — Auth gate + deep linking (`solennix://`)
- `mobile/src/navigation/MainTabs.tsx` — 5-tab bar with FAB + BlurView + haptics
- `mobile/src/navigation/DrawerNavigator.tsx` — Sidebar with 5 drawer items
- `mobile/src/hooks/usePlanLimits.ts` — Plan enforcement (3 events, 50 clients, 20 items)
- `mobile/src/services/revenueCatService.ts` — RevenueCat with graceful fallback

### Backend Endpoints Used by Phase 1
- `POST /auth/register` — returns `{ tokens: { access_token, refresh_token }, user }`
- `POST /auth/login` — same response format (supports legacy single token too)
- `POST /auth/logout` — clears session
- `POST /auth/refresh` — returns `{ access_token, refresh_token }`
- `GET /auth/me` — returns User object
- `POST /auth/forgot-password` — sends reset email
- `POST /auth/reset-password` — accepts `{ token, password }`
- `POST /auth/apple` — NEW endpoint needed for Sign in with Apple

## Key Nuances Discovered

1. **Token response has dual format**: Login/register supports both legacy `{ token }` and new `{ tokens: { access_token, refresh_token } }`. Swift should handle both.
2. **Refresh mutex**: RN uses a `refreshPromise` singleton to prevent concurrent refreshes. Swift actor isolation handles this naturally.
3. **401 callback pattern**: ApiClient registers an unauthorized callback with AuthContext for global logout. Swift can use Combine/async notification.
4. **RevenueCat graceful fallback**: The service detects if native module exists and falls back to debug endpoints. StoreKit 2 hybrid approach replaces this.
5. **Theme persistence**: Stored in SecureStore under key `app_theme`. Swift uses `@AppStorage`.
6. **Deep linking**: Only `solennix://reset-password?token=XXX` is configured. SwiftUI `.onOpenURL` handles this.
7. **Plan limits are client-side**: `usePlanLimits` hook fetches counts and compares to hardcoded limits (basic: 3/50/20).
8. **FAB interception**: The center "New Event" tab doesn't navigate to its own stack — it's intercepted to push EventForm on HomeTab.
9. **Responsive breakpoint**: `width >= 600` triggers tablet layout with brand panel + form split.
10. **Auth context aliases**: `profile` and `user` are the same object — simplify in Swift to single `@Observable` property.

## Approach

**Single approach — create Swift/SwiftUI project structure on Windows as plain files:**

### What We Create (Phase 1 Deliverables)
1. **SolennixCore package** — All 14 Codable model structs with CodingKeys
2. **SolennixNetwork package** — Actor-based APIClient + AuthManager with Keychain
3. **SolennixDesign package** — Color tokens, typography, spacing, shadow ViewModifiers, base components (FormInput, PremiumButton, Avatar, EmptyState, StatusBadge, ConfirmDialog)
4. **Auth feature module** — LoginView, RegisterView, ForgotPasswordView, ResetPasswordView + Sign in with Apple
5. **Navigation** — ContentView with auth gate, TabView (iPhone), NavigationSplitView placeholder (iPad), Route enum
6. **App entry point** — SolennixApp.swift with @main, deep linking, theme

### What We Skip (needs Xcode)
- .xcodeproj / .xcworkspace generation
- Asset Catalog .xcassets (we create the color values in code as fallback)
- Actual compilation / testing
- Code signing, provisioning profiles
- Widget/Intent extension targets (Phase 5)

## Risks
- Cannot validate Swift compilation on Windows — syntax errors possible
- Asset Catalog colors are better in .xcassets but we'll use Color(hex:) initializer as alternative
- Package.swift manifests need to be validated in Xcode

## Ready for Proposal
Yes — proceed to proposal with scope focused on creating all Phase 1 Swift source files.
