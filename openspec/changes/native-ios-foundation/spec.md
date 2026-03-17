# Spec: Native iOS Foundation (Phase 1)

**Change:** native-ios-foundation
**Depends on:** proposal.md
**Scope:** SolennixCore, SolennixNetwork, SolennixDesign, Auth screens, Navigation

---

## 1. SolennixCore — Model Structs

All 14 structs conform to `Codable, Identifiable`. All use `CodingKeys` with `snake_case` mapping. Source of truth: `mobile/src/types/entities.ts`.

### 1.1 User

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| email | `String` | email | |
| name | `String` | name | |
| businessName | `String?` | business_name | |
| logoUrl | `String?` | logo_url | |
| brandColor | `String?` | brand_color | |
| showBusinessNameInPdf | `Bool?` | show_business_name_in_pdf | |
| defaultDepositPercent | `Double?` | default_deposit_percent | |
| defaultCancellationDays | `Double?` | default_cancellation_days | |
| defaultRefundPercent | `Double?` | default_refund_percent | |
| contractTemplate | `String?` | contract_template | |
| plan | `Plan` | plan | enum: `basic`, `premium` |
| stripeCustomerId | `String?` | stripe_customer_id | |
| createdAt | `String` | created_at | |
| updatedAt | `String` | updated_at | |

### 1.2 Client

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| userId | `String` | user_id |
| name | `String` | name |
| phone | `String` | phone |
| email | `String?` | email |
| address | `String?` | address |
| city | `String?` | city |
| notes | `String?` | notes |
| photoUrl | `String?` | photo_url |
| totalEvents | `Int?` | total_events |
| totalSpent | `Double?` | total_spent |
| createdAt | `String` | created_at |
| updatedAt | `String` | updated_at |

### 1.3 Event

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| userId | `String` | user_id | |
| clientId | `String` | client_id | |
| eventDate | `String` | event_date | |
| startTime | `String?` | start_time | |
| endTime | `String?` | end_time | |
| serviceType | `String` | service_type | |
| numPeople | `Int` | num_people | |
| status | `EventStatus` | status | enum: `quoted`, `confirmed`, `completed`, `cancelled` |
| discount | `Double` | discount | |
| discountType | `DiscountType` | discount_type | enum: `percent`, `fixed` |
| requiresInvoice | `Bool` | requires_invoice | |
| taxRate | `Double` | tax_rate | |
| taxAmount | `Double` | tax_amount | |
| totalAmount | `Double` | total_amount | |
| location | `String?` | location | |
| city | `String?` | city | |
| depositPercent | `Double?` | deposit_percent | |
| cancellationDays | `Double?` | cancellation_days | |
| refundPercent | `Double?` | refund_percent | |
| notes | `String?` | notes | |
| photos | `String?` | photos | JSON array of URLs |
| createdAt | `String` | created_at | |
| updatedAt | `String` | updated_at | |

### 1.4 Product

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| userId | `String` | user_id |
| name | `String` | name |
| category | `String` | category |
| basePrice | `Double` | base_price |
| recipe | `AnyCodable?` | recipe |
| imageUrl | `String?` | image_url |
| isActive | `Bool` | is_active |
| createdAt | `String` | created_at |
| updatedAt | `String` | updated_at |

### 1.5 InventoryItem

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| userId | `String` | user_id | |
| ingredientName | `String` | ingredient_name | |
| currentStock | `Double` | current_stock | |
| minimumStock | `Double` | minimum_stock | |
| unit | `String` | unit | |
| unitCost | `Double?` | unit_cost | |
| lastUpdated | `String` | last_updated | |
| type | `InventoryType` | type | enum: `ingredient`, `equipment`, `supply` |

### 1.6 EventProduct

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| productId | `String` | product_id |
| quantity | `Int` | quantity |
| unitPrice | `Double` | unit_price |
| discount | `Double` | discount |
| totalPrice | `Double?` | total_price |
| createdAt | `String` | created_at |

### 1.7 EventExtra

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| description | `String` | description |
| cost | `Double` | cost |
| price | `Double` | price |
| excludeUtility | `Bool` | exclude_utility |
| createdAt | `String` | created_at |

### 1.8 EventEquipment

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| eventId | `String` | event_id | |
| inventoryId | `String` | inventory_id | |
| quantity | `Int` | quantity | |
| notes | `String?` | notes | |
| createdAt | `String` | created_at | |
| equipmentName | `String?` | equipment_name | Joined field |
| unit | `String?` | unit | Joined field |
| currentStock | `Double?` | current_stock | Joined field |

### 1.9 EventSupply

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| eventId | `String` | event_id | |
| inventoryId | `String` | inventory_id | |
| quantity | `Double` | quantity | |
| unitCost | `Double` | unit_cost | |
| source | `SupplySource` | source | enum: `stock`, `purchase` |
| excludeCost | `Bool` | exclude_cost | |
| createdAt | `String` | created_at | |
| supplyName | `String?` | supply_name | Joined field |
| unit | `String?` | unit | Joined field |
| currentStock | `Double?` | current_stock | Joined field |

### 1.10 ProductIngredient

| Field | Swift Type | JSON Key | Notes |
|-------|-----------|----------|-------|
| id | `String` | id | |
| productId | `String` | product_id | |
| inventoryId | `String` | inventory_id | |
| quantityRequired | `Double` | quantity_required | |
| capacity | `Double?` | capacity | |
| bringToEvent | `Bool?` | bring_to_event | |
| createdAt | `String` | created_at | |
| ingredientName | `String?` | ingredient_name | Joined field |
| unit | `String?` | unit | Joined field |
| unitCost | `Double?` | unit_cost | Joined field |
| type | `InventoryType?` | type | Joined field |

### 1.11 Payment

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| userId | `String` | user_id |
| amount | `Double` | amount |
| paymentDate | `String` | payment_date |
| paymentMethod | `String` | payment_method |
| notes | `String?` | notes |
| createdAt | `String` | created_at |

### 1.12 EquipmentConflict

Not `Identifiable` (no `id` field). Conforms to `Codable` only.

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| inventoryId | `String` | inventory_id |
| equipmentName | `String` | equipment_name |
| conflictingEventId | `String` | conflicting_event_id |
| eventDate | `String` | event_date |
| startTime | `String?` | start_time |
| endTime | `String?` | end_time |
| serviceType | `String` | service_type |
| clientName | `String?` | client_name |
| conflictType | `ConflictType` | conflict_type |

`ConflictType` enum: `overlap`, `insufficientGap`, `fullDay` (raw values: `"overlap"`, `"insufficient_gap"`, `"full_day"`).

### 1.13 SupplySuggestion

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| ingredientName | `String` | ingredient_name |
| currentStock | `Double` | current_stock |
| unit | `String` | unit |
| unitCost | `Double` | unit_cost |
| suggestedQuantity | `Double` | suggested_quantity |

### 1.14 EquipmentSuggestion

| Field | Swift Type | JSON Key |
|-------|-----------|----------|
| id | `String` | id |
| ingredientName | `String` | ingredient_name |
| currentStock | `Double` | current_stock |
| unit | `String` | unit |
| type | `String` | type |
| suggestedQuantity | `Double` | suggested_quantity |

### Additional Types

- **`AnyCodable`** — Wrapper for arbitrary JSON (`recipe` field). Encode/decode via `JSONSerialization`.
- **`EmptyResponse`** — Empty struct for 204 responses.
- **`APIError`** — Enum: `unauthorized`, `forbidden`, `notFound`, `validationError(String)`, `serverError(Int)`, `networkError(Error)`, `decodingError(Error)`.

### Extensions (Phase 1)

- `Date+Formatting` — `formatted(as:)` with `es_MX` locale, relative date strings
- `String+Validation` — `isValidEmail`, `isNotEmpty`
- `Double+Currency` — `asMXN` property using `NumberFormatter` with locale `es_MX`, currency `MXN`

---

## 2. SolennixNetwork

### 2.1 APIClient Actor

```
actor APIClient {
    init(baseURL: URL, authManager: AuthManager)

    func get<T: Decodable>(_ endpoint: String, params: [String: String]?) async throws -> T
    func post<T: Decodable>(_ endpoint: String, body: some Encodable) async throws -> T
    func put<T: Decodable>(_ endpoint: String, body: some Encodable) async throws -> T
    func delete(_ endpoint: String) async throws
    func upload(_ endpoint: String, fileURL: URL) async throws -> UploadResponse
}
```

**Behaviors:**
- Sets `Authorization: Bearer {token}` on every request via `AuthManager.getAccessToken()`
- On 401: attempts `AuthManager.refreshToken()`, retries once. If refresh fails, calls `AuthManager.clearTokens()` and throws `APIError.unauthorized`
- Uses `JSONDecoder` with `.convertFromSnakeCase`
- `URLSessionConfiguration.default` with 30s timeout, `waitsForConnectivity = true`
- 204 responses return `EmptyResponse`

### 2.2 AuthManager

```
@Observable class AuthManager {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }

    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String) async throws -> User
    func loginWithApple(identityToken: String, authorizationCode: String, fullName: PersonNameComponents?) async throws -> User
    func logout() async throws
    func refreshToken() async throws -> Bool
    func getAccessToken() async throws -> String
    func clearTokens() async
    func forgotPassword(email: String) async throws
    func resetPassword(token: String, newPassword: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    func fetchCurrentUser() async throws -> User
    func checkBiometricAvailability() -> Bool
    func authenticateWithBiometric() async throws -> Bool
}
```

**Storage:** Keychain via `KeychainHelper` for `access_token` and `refresh_token`. `@AppStorage("biometricEnabled")` for biometric preference.

**Token format handling:** API may return either `{ token: "..." }` or `{ tokens: { access_token: "...", refresh_token: "..." } }`. AuthManager must handle both via `AuthResponse` struct with flexible decoding.

### 2.3 KeychainHelper

```
struct KeychainHelper {
    static func save(_ data: Data, for key: String) throws
    static func read(for key: String) throws -> Data?
    static func delete(for key: String) throws
}
```

Keys: `"com.creapolis.solennix.accessToken"`, `"com.creapolis.solennix.refreshToken"`

### 2.4 NetworkMonitor

```
@Observable class NetworkMonitor {
    var isConnected: Bool { get }
    var connectionType: NWInterface.InterfaceType? { get }
}
```

Wraps `NWPathMonitor`. Injected via `@Environment`.

### 2.5 Endpoint Enum (Phase 1 entries)

All endpoints are static properties/functions on `enum Endpoint`:

| Category | Entry | Value |
|----------|-------|-------|
| Auth | `register` | `"/auth/register"` |
| Auth | `login` | `"/auth/login"` |
| Auth | `logout` | `"/auth/logout"` |
| Auth | `refresh` | `"/auth/refresh"` |
| Auth | `forgotPassword` | `"/auth/forgot-password"` |
| Auth | `resetPassword` | `"/auth/reset-password"` |
| Auth | `me` | `"/auth/me"` |
| Auth | `changePassword` | `"/auth/change-password"` |
| Auth | `appleAuth` | `"/auth/apple"` |
| Clients | `clients` | `"/clients"` |
| Clients | `client(_ id:)` | `"/clients/{id}"` |
| Events | `events` | `"/events"` |
| Events | `upcomingEvents` | `"/events/upcoming"` |
| Events | `event(_ id:)` | `"/events/{id}"` |
| Events | `eventProducts(_ id:)` | `"/events/{id}/products"` |
| Events | `eventExtras(_ id:)` | `"/events/{id}/extras"` |
| Events | `eventItems(_ id:)` | `"/events/{id}/items"` |
| Events | `eventEquipment(_ id:)` | `"/events/{id}/equipment"` |
| Events | `eventSupplies(_ id:)` | `"/events/{id}/supplies"` |
| Events | `equipmentConflicts` | `"/events/equipment/conflicts"` |
| Events | `equipmentSuggestions` | `"/events/equipment/suggestions"` |
| Events | `supplySuggestions` | `"/events/supplies/suggestions"` |
| Products | `products` | `"/products"` |
| Products | `product(_ id:)` | `"/products/{id}"` |
| Products | `productIngredients(_ id:)` | `"/products/{id}/ingredients"` |
| Products | `batchIngredients` | `"/products/ingredients/batch"` |
| Inventory | `inventory` | `"/inventory"` |
| Inventory | `inventoryItem(_ id:)` | `"/inventory/{id}"` |
| Payments | `payments` | `"/payments"` |
| Payments | `payment(_ id:)` | `"/payments/{id}"` |
| Calendar | `unavailableDates` | `"/unavailable-dates"` |
| Calendar | `unavailableDate(_ id:)` | `"/unavailable-dates/{id}"` |
| Search | `search` | `"/search"` |
| Uploads | `uploadImage` | `"/uploads/image"` |
| Profile | `updateProfile` | `"/users/me"` |
| Subscriptions | `subscriptionStatus` | `"/subscriptions/status"` |
| Devices | `registerDevice` | `"/devices/register"` |
| Devices | `unregisterDevice` | `"/devices/unregister"` |

---

## 3. SolennixDesign

### 3.1 Color Tokens

Defined as `Color` static extensions via `Color(hex:)` initializer. Each token has light and dark variants resolved via `@Environment(\.colorScheme)`.

**Brand (4)**

| Token | Light | Dark |
|-------|-------|------|
| `solennixGold` | `#C4A265` | `#C4A265` |
| `solennixGoldDark` | `#B8965A` | `#D4B87A` |
| `solennixGoldLight` | `#F5F0E8` | `#1B2A4A` |
| `solennixSecondary` | `#6B7B8D` | `#94A3B8` |

**Surfaces (5)**

| Token | Light | Dark |
|-------|-------|------|
| `background` | `#FFFFFF` | `#000000` |
| `surfaceGrouped` | `#F5F4F1` | `#0A0F1A` |
| `surface` | `#FAF9F7` | `#1A2030` |
| `surfaceAlt` | `#F0EFEC` | `#252A35` |
| `card` | `#FFFFFF` | `#111722` |

**Text (4)**

| Token | Light | Dark |
|-------|-------|------|
| `primaryText` | `#1A1A1A` | `#F5F0E8` |
| `secondaryText` | `#7A7670` | `#9A9590` |
| `tertiaryText` | `#A8A29E` | `#6B6560` |
| `inverseText` | `#FFFFFF` | `#1A1A1A` |

**Borders (3)**

| Token | Light | Dark |
|-------|-------|------|
| `border` | `#E6E3DD` | `#252A35` |
| `borderStrong` | `#D4D0C8` | `#3A3F4A` |
| `separator` | `rgba(60,60,67,0.29)` | `rgba(84,84,88,0.65)` |

**Semantic (4 pairs: color + background)**

| Token | Light | Dark | Bg Light | Bg Dark |
|-------|-------|------|----------|---------|
| `success` | `#2D6A4F` | `#52B788` | `#F0F7F4` | `#0B1D14` |
| `warning` | `#FF9500` | `#FF9F0A` | `#FFF8F0` | `#2A1A00` |
| `error` | `#FF3B30` | `#FF453A` | `#FFF0F0` | `#2A0A0A` |
| `info` | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |

**Event Status (4 pairs)**

| Token | Light | Dark | Bg Light | Bg Dark |
|-------|-------|------|----------|---------|
| `statusQuoted` | `#D97706` | `#FBBF24` | `#FFF8F0` | `#2A1A00` |
| `statusConfirmed` | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |
| `statusCompleted` | `#2D6A4F` | `#52B788` | `#F0F7F4` | `#0B1D14` |
| `statusCancelled` | `#FF3B30` | `#FF453A` | `#FFF0F0` | `#2A0A0A` |

**KPI (3 pairs)**

| Token | Light | Dark | Bg Light | Bg Dark |
|-------|-------|------|----------|---------|
| `kpiGreen` | `#34C759` | `#30D158` | `#EEFBF0` | `#0D2818` |
| `kpiOrange` | `#D97706` | `#FBBF24` | `#FFF8F0` | `#2A1A00` |
| `kpiBlue` | `#007AFF` | `#0A84FF` | `#EEF4FF` | `#001A33` |

**Tab Bar (4)**

| Token | Light | Dark |
|-------|-------|------|
| `tabBackground` | `#FFFFFF` | `#111722` |
| `tabActive` | `#C4A265` | `#C4A265` |
| `tabInactive` | `#A8A29E` | `#6B6560` |
| `tabBorder` | `#E6E3DD` | `#252A35` |

**Avatar palette (8):** `#5B8DEF`, `#E57373`, `#7DB38A`, `#D4B87A`, `#BA68C8`, `#F06292`, `#4DB6AC`, `#FF8A65`

**Total: 43 tokens** (counting bg variants separately).

### 3.2 Typography Scale

| Name | SwiftUI Font | Size | Weight |
|------|-------------|------|--------|
| `h1Premium` | `.system(size: 28, weight: .black)` | 28pt | Black |
| `largeTitle` | `.largeTitle` | 34pt | Regular |
| `title` | `.title` | 28pt | Regular |
| `title2` | `.title2` | 22pt | Regular |
| `title3` | `.title3` | 20pt | Regular |
| `headline` | `.headline` | 17pt | Semibold |
| `body` | `.body` | 17pt | Regular |
| `callout` | `.callout` | 16pt | Regular |
| `subheadline` | `.subheadline` | 15pt | Regular |
| `footnote` | `.footnote` | 13pt | Regular |
| `caption` | `.caption` | 12pt | Regular |
| `caption2` | `.caption2` | 11pt | Regular |

Brand fonts (Cinzel, bundled):
- `solennixTitle` — `Font.custom("Cinzel-SemiBold", size: 32, relativeTo: .title)`
- `solennixSubtitle` — `Font.custom("Cinzel-Regular", size: 24, relativeTo: .title2)`

### 3.3 Spacing (4px grid)

| Token | Value |
|-------|-------|
| `xxs` | 2pt |
| `xs` | 4pt |
| `sm` | 8pt |
| `md` | 16pt |
| `lg` | 20pt |
| `xl` | 24pt |
| `xxl` | 32pt |
| `xxxl` | 48pt |

### 3.4 Border Radius

| Token | Value | Use |
|-------|-------|-----|
| `radiusSm` | 6pt | Badges, chips |
| `radiusMd` | 10pt | Inputs, buttons |
| `radiusLg` | 14pt | Cards (web-style) |
| `radiusXl` | 20pt | Modals |
| `radiusCard` | 24pt | Cards (mobile) |

### 3.5 Shadows (ViewModifier extensions on `View`)

| Modifier | Color | Radius | Offset |
|----------|-------|--------|--------|
| `.shadowSm()` | `black 5%` | 2 | (0, 1) |
| `.shadowMd()` | `black 10%` | 6 | (0, 2) |
| `.shadowLg()` | `black 15%` | 12 | (0, 4) |
| `.shadowFab()` | `solennixGold 40%` | 8 | (0, 4) |

### 3.6 Gradient

- `premiumGradient` — `LinearGradient` from `solennixGold` to `solennixGoldDark`, `.leading` to `.trailing`

### 3.7 Components (Phase 1)

| Component | Props | Notes |
|-----------|-------|-------|
| `SolennixTextField` | `title: String`, `text: Binding<String>`, `placeholder: String`, `icon: String?`, `isSecure: Bool`, `keyboardType: UIKeyboardType`, `textContentType: UITextContentType?`, `errorMessage: String?`, `isDisabled: Bool` | Uses `@FocusState`, shows error below field |
| `PremiumButton` | `title: String`, `icon: String?`, `style: ButtonStyle` (.primary, .secondary, .destructive), `isLoading: Bool`, `isDisabled: Bool`, `action: () -> Void` | Primary uses `premiumGradient`, loading shows `ProgressView` |
| `AvatarView` | `name: String`, `photoUrl: String?`, `size: CGFloat` | Initials fallback with deterministic color from avatar palette |
| `EmptyStateView` | `icon: String`, `title: String`, `message: String`, `actionTitle: String?`, `action: (() -> Void)?` | SF Symbol icon, optional CTA button |
| `StatusBadge` | `status: EventStatus` | Colored pill with text, uses event status color tokens |
| `ConfirmDialog` | Uses `.confirmationDialog` modifier | Not a standalone view; usage pattern |
| `ToastOverlay` | `message: String`, `type: ToastType` (.success, .error, .info, .warning), `isPresented: Binding<Bool>` | Auto-dismisses after 3s, slides from top |
| `SkeletonView` | Uses `.redacted(reason: .placeholder)` modifier | Not a standalone view; usage pattern |

---

## 4. Auth Screens

### 4.1 LoginView

**Fields:**

| Field | Type | textContentType | keyboardType | Validation |
|-------|------|----------------|--------------|------------|
| email | `SolennixTextField` | `.emailAddress` | `.emailAddress` | Non-empty, valid email format |
| password | `SecureField` + toggle | `.password` | `.default` | Non-empty |

**Layout (top to bottom):**
1. Animated logo (tulip cup) + "SOLENNIX" in `solennixTitle` (Cinzel)
2. Tagline "CADA DETALLE IMPORTA" — Helvetica Neue Light, letter-spacing 5.5px
3. Email field
4. Password field with eye/eye.slash toggle
5. `PremiumButton` "Iniciar Sesion" (.primary)
6. "Olvidaste tu contrasena?" link -> `ForgotPasswordView`
7. Separator "o continua con"
8. `SignInWithAppleButton` (AuthenticationServices) — style adapts to colorScheme
9. "Crear cuenta" link -> `RegisterView`
10. Feature carousel (Calendario, CRM, Reportes)

**API call:** `POST /auth/login` with `{ email, password }`

**Success:** Store tokens in Keychain via `AuthManager.login()`. If biometric available and not yet enabled, show prompt to enable Face ID/Touch ID. Navigate to `ContentView` main flow.

**Error:** Show inline error message below form. Handle: invalid credentials (401), network error, server error.

### 4.2 RegisterView

**Fields:**

| Field | Type | textContentType | Validation |
|-------|------|----------------|------------|
| name | `SolennixTextField` | `.name` | Non-empty, 2+ characters |
| email | `SolennixTextField` | `.emailAddress` | Non-empty, valid email format |
| password | `SecureField` | `.newPassword` | 6+ characters |
| confirmPassword | `SecureField` | `.newPassword` | Must match password |

**Layout:**
1. Back button + Title "Crear Cuenta"
2. Name, Email, Password, Confirm Password fields
3. Features showcase pills (Gratis, Seguro, Escalable)
4. `PremiumButton` "Crear Cuenta" (.primary)
5. `SignInWithAppleButton` as alternative
6. Links to Terms & Privacy (inline text)

**API call:** `POST /auth/register` with `{ name, email, password }`

**Success:** Auto-login (store tokens), navigate to main flow.

**Error:** Show inline error. Handle: email already exists (409), validation errors, network error.

### 4.3 ForgotPasswordView

**Fields:**

| Field | Type | Validation |
|-------|------|------------|
| email | `SolennixTextField` | Non-empty, valid email format |

**Layout:**
1. Back button + Title
2. Instruction text
3. Email field
4. `PremiumButton` "Enviar enlace" (.primary)
5. "Volver a Login" link

**API call:** `POST /auth/forgot-password` with `{ email }`

**Success:** Show success state with "Revisa tu correo" message + mail icon. Hide form.

**Error:** Show inline error. Always show success for non-existent emails (backend behavior).

### 4.4 ResetPasswordView

**Entry:** Via deep link `solennix://reset-password?token=X`. Token extracted from URL query parameter.

**Fields:**

| Field | Type | Validation |
|-------|------|------------|
| newPassword | `SecureField` | 6+ characters |
| confirmPassword | `SecureField` | Must match newPassword |

**Layout:**
1. Title "Nueva Contrasena"
2. New password field
3. Confirm password field
4. `PremiumButton` "Restablecer Contrasena" (.primary)

**API call:** `POST /auth/reset-password` with `{ token, password }`

**Success:** Show success state with checkmark. "Ir a Login" button navigates to `LoginView`.

**Error:** Show inline error. Handle: expired/invalid token, network error.

### 4.5 AuthViewModel

Single `@Observable` class shared by all 4 auth screens:

```
@Observable class AuthViewModel {
    var isLoading: Bool
    var errorMessage: String?

    // Login
    var loginEmail: String
    var loginPassword: String
    func login() async

    // Register
    var registerName: String
    var registerEmail: String
    var registerPassword: String
    var registerConfirmPassword: String
    func register() async

    // Forgot Password
    var forgotEmail: String
    var forgotSuccess: Bool
    func forgotPassword() async

    // Reset Password
    var resetToken: String
    var newPassword: String
    var confirmNewPassword: String
    var resetSuccess: Bool
    func resetPassword() async

    // Validation helpers
    var isLoginValid: Bool { get }
    var isRegisterValid: Bool { get }
    var isForgotValid: Bool { get }
    var isResetValid: Bool { get }
}
```

Depends on `AuthManager` (injected via `@Environment`).

---

## 5. Navigation

### 5.1 Route Enum

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

    // Settings sub-screens
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

### 5.2 Tab Enum (iPhone)

```swift
enum Tab: Hashable {
    case home       // "Inicio" — house.fill
    case calendar   // "Calendario" — calendar
    case clients    // "Clientes" — person.2.fill
    case more       // "Mas" — ellipsis
}
```

Each tab owns its own `NavigationStack(path:)` with `.navigationDestination(for: Route.self)`.

### 5.3 Sidebar Section Enum (iPad)

```swift
enum SidebarSection: Hashable {
    case dashboard    // "Inicio" — house.fill
    case calendar     // "Calendario" — calendar
    case clients      // "Clientes" — person.2.fill
    case products     // "Productos" — shippingbox.fill
    case inventory    // "Inventario" — archivebox.fill
    case search       // "Buscar" — magnifyingglass
    case settings     // "Ajustes" — gearshape.fill (bottom section)
}
```

### 5.4 ContentView (Root)

```
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(AuthManager.self) var authManager

    // Auth gate:
    //   !authManager.isAuthenticated -> AuthFlowView (LoginView as root)
    //   sizeClass == .compact -> CompactTabLayout
    //   sizeClass == .regular -> SidebarSplitLayout
}
```

### 5.5 CompactTabLayout (iPhone)

- `TabView(selection: $selectedTab)` with 4 tabs
- Each tab contains `NavigationStack` with its root view
- `NewEventFAB` overlay at bottom center (between tabs 2 and 3)
- FAB taps navigate to `Route.eventForm()` on the home tab

### 5.6 SidebarSplitLayout (iPad)

- `NavigationSplitView` with sidebar + content + detail columns
- Sidebar: `List(selection: $selectedSection)` with `SidebarSection` cases
- Content: switches on `selectedSection` to show list view
- Detail: populated by `NavigationLink` selections within content

### 5.7 Deep Link Handling

```
.onOpenURL { url in
    // Scheme: "solennix"
    // Supported paths:
    //   solennix://reset-password?token=X  ->  ResetPasswordView(token: X)
}
```

Registered in `SolennixApp.swift` on the root view. If user is authenticated and deep link is for reset-password, show it modally.

### 5.8 SolennixApp Entry Point

```swift
@main struct SolennixApp: App {
    @AppStorage("appearance") private var appearance: String = "system"
    @State private var authManager = AuthManager()
    @State private var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(networkMonitor)
                .preferredColorScheme(resolvedColorScheme)
                .onOpenURL { handle($0) }
        }
    }
}
```

Theme: `@AppStorage("appearance")` with values `"system"`, `"light"`, `"dark"` mapped to `ColorScheme?`.

---

## 6. Scenarios

### SC-01: Fresh Login
1. User opens app, no tokens in Keychain
2. `ContentView` shows `AuthFlowView` -> `LoginView`
3. User enters email + password, taps "Iniciar Sesion"
4. `AuthViewModel.login()` calls `POST /auth/login`
5. On 200: tokens stored in Keychain, `authManager.isAuthenticated = true`
6. `ContentView` re-evaluates, shows `CompactTabLayout` or `SidebarSplitLayout`

### SC-02: Token Refresh on 401
1. User is authenticated, makes API call
2. `APIClient.execute()` gets 401
3. Calls `authManager.refreshToken()` -> `POST /auth/refresh` with refresh_token
4. On success: new tokens stored, original request retried with new access_token
5. On failure: `authManager.clearTokens()`, UI returns to `LoginView`

### SC-03: Sign in with Apple
1. User taps `SignInWithAppleButton` on LoginView or RegisterView
2. System presents Apple auth sheet, user authenticates
3. `handleAuthorization()` extracts `identityToken`, `authorizationCode`, `fullName`
4. Sends to `POST /auth/apple`
5. Backend creates/links account, returns JWT tokens
6. Normal post-login flow

### SC-04: Forgot + Reset Password
1. User taps "Olvidaste tu contrasena?" on LoginView
2. Navigates to `ForgotPasswordView`, enters email
3. `POST /auth/forgot-password` -> success message shown
4. User clicks email link: `solennix://reset-password?token=abc123`
5. App handles `.onOpenURL`, shows `ResetPasswordView` with token
6. User enters new password, taps submit
7. `POST /auth/reset-password` -> success, navigates to LoginView

### SC-05: Biometric Unlock
1. App launches, tokens exist in Keychain, biometric is enabled
2. `ContentView` shows blur overlay + Face ID/Touch ID prompt
3. On success: proceed to main layout
4. On 3 failures: fallback to LoginView (clear tokens)

### SC-06: iPad Layout Switch
1. User on iPad in portrait (regular width)
2. `ContentView` shows `SidebarSplitLayout` with sidebar
3. User selects "Clientes" in sidebar -> content shows client list
4. User taps client -> detail column populates

### SC-07: Deep Link While Authenticated
1. User is logged in, app is in background
2. Opens `solennix://reset-password?token=X` (e.g., from email)
3. `.onOpenURL` fires, presents `ResetPasswordView` modally

### SC-08: Offline State
1. `NetworkMonitor.isConnected` becomes `false`
2. App shows offline banner (non-blocking)
3. API calls fail with `APIError.networkError`
4. When connectivity returns, banner dismisses

---

## 7. File Manifest (Phase 1)

```
ios/
  Solennix/
    SolennixApp.swift
    ContentView.swift
    Navigation/
      Route.swift
      CompactTabLayout.swift
      SidebarSplitLayout.swift
    Info.plist

  Packages/
    SolennixCore/
      Package.swift
      Sources/SolennixCore/
        Models/
          User.swift
          Client.swift
          Event.swift
          Product.swift
          InventoryItem.swift
          EventProduct.swift
          EventExtra.swift
          EventEquipment.swift
          EventSupply.swift
          ProductIngredient.swift
          Payment.swift
          EquipmentConflict.swift
          SupplySuggestion.swift
          EquipmentSuggestion.swift
          AnyCodable.swift
        Extensions/
          Date+Formatting.swift
          String+Validation.swift
          Double+Currency.swift
        Finance/
          (placeholder — populated in Phase 2)

    SolennixNetwork/
      Package.swift
      Sources/SolennixNetwork/
        APIClient.swift
        AuthManager.swift
        Endpoints.swift
        KeychainHelper.swift
        NetworkMonitor.swift
        APIError.swift

    SolennixDesign/
      Package.swift
      Sources/SolennixDesign/
        Colors.swift
        Typography.swift
        Spacing.swift
        BorderRadius.swift
        Shadows.swift
        Gradient.swift
        Components/
          SolennixTextField.swift
          PremiumButton.swift
          AvatarView.swift
          EmptyStateView.swift
          StatusBadge.swift
          ToastOverlay.swift

    SolennixFeatures/
      Package.swift
      Sources/SolennixFeatures/
        Auth/
          Views/
            LoginView.swift
            RegisterView.swift
            ForgotPasswordView.swift
            ResetPasswordView.swift
            AuthFlowView.swift
          ViewModels/
            AuthViewModel.swift
```

**Total: ~40 Swift files**
