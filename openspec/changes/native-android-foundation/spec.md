# Spec: Native Android Foundation (Phase 1)

**Change:** native-android-foundation
**Depends on:** PRD-NATIVE-ANDROID.md
**Scope:** core:model, core:network, core:designsystem, feature:auth, Navigation

---

## 1. core:model — Data Classes

All 14 data classes use `@Serializable` (Kotlinx Serialization) with `@SerialName` for snake_case mapping. Source of truth: `mobile/src/types/entities.ts` (identical to iOS spec).

### 1.1 User

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
| id | `String` | id | |
| email | `String` | email | |
| name | `String` | name | |
| businessName | `String?` | business_name | default `null` |
| logoUrl | `String?` | logo_url | default `null` |
| brandColor | `String?` | brand_color | default `null` |
| showBusinessNameInPdf | `Boolean?` | show_business_name_in_pdf | default `null` |
| defaultDepositPercent | `Double?` | default_deposit_percent | default `null` |
| defaultCancellationDays | `Double?` | default_cancellation_days | default `null` |
| defaultRefundPercent | `Double?` | default_refund_percent | default `null` |
| contractTemplate | `String?` | contract_template | default `null` |
| plan | `Plan` | plan | enum: `basic`, `premium` |
| stripeCustomerId | `String?` | stripe_customer_id | default `null` |
| createdAt | `String` | created_at | |
| updatedAt | `String` | updated_at | |

Nested enum:
```kotlin
@Serializable
enum class Plan {
    @SerialName("basic") BASIC,
    @SerialName("premium") PREMIUM
}
```

### 1.2 Client

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
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

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
| id | `String` | id | |
| userId | `String` | user_id | |
| clientId | `String` | client_id | |
| eventDate | `String` | event_date | |
| startTime | `String?` | start_time | |
| endTime | `String?` | end_time | |
| serviceType | `String` | service_type | |
| numPeople | `Int` | num_people | |
| status | `EventStatus` | status | enum |
| discount | `Double` | discount | |
| discountType | `DiscountType` | discount_type | enum |
| requiresInvoice | `Boolean` | requires_invoice | |
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

Enums:
```kotlin
@Serializable
enum class EventStatus {
    @SerialName("quoted") QUOTED,
    @SerialName("confirmed") CONFIRMED,
    @SerialName("completed") COMPLETED,
    @SerialName("cancelled") CANCELLED
}

@Serializable
enum class DiscountType {
    @SerialName("percent") PERCENT,
    @SerialName("fixed") FIXED
}
```

### 1.4 Product

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| userId | `String` | user_id |
| name | `String` | name |
| category | `String` | category |
| basePrice | `Double` | base_price |
| recipe | `JsonElement?` | recipe |
| imageUrl | `String?` | image_url |
| isActive | `Boolean` | is_active |
| createdAt | `String` | created_at |
| updatedAt | `String` | updated_at |

Uses `kotlinx.serialization.json.JsonElement` for arbitrary JSON (`recipe` field).

### 1.5 InventoryItem

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
| id | `String` | id | |
| userId | `String` | user_id | |
| ingredientName | `String` | ingredient_name | |
| currentStock | `Double` | current_stock | |
| minimumStock | `Double` | minimum_stock | |
| unit | `String` | unit | |
| unitCost | `Double?` | unit_cost | |
| lastUpdated | `String` | last_updated | |
| type | `InventoryType` | type | enum |

```kotlin
@Serializable
enum class InventoryType {
    @SerialName("ingredient") INGREDIENT,
    @SerialName("equipment") EQUIPMENT,
    @SerialName("supply") SUPPLY
}
```

### 1.6 EventProduct

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| productId | `String` | product_id |
| quantity | `Int` | quantity |
| unitPrice | `Double` | unit_price |
| discount | `Double` | discount |
| totalPrice | `Double?` | total_price |
| createdAt | `String` | created_at |

### 1.7 EventExtra

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| description | `String` | description |
| cost | `Double` | cost |
| price | `Double` | price |
| excludeUtility | `Boolean` | exclude_utility |
| createdAt | `String` | created_at |

### 1.8 EventEquipment

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
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

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
| id | `String` | id | |
| eventId | `String` | event_id | |
| inventoryId | `String` | inventory_id | |
| quantity | `Double` | quantity | |
| unitCost | `Double` | unit_cost | |
| source | `SupplySource` | source | enum |
| excludeCost | `Boolean` | exclude_cost | |
| createdAt | `String` | created_at | |
| supplyName | `String?` | supply_name | Joined field |
| unit | `String?` | unit | Joined field |
| currentStock | `Double?` | current_stock | Joined field |

```kotlin
@Serializable
enum class SupplySource {
    @SerialName("stock") STOCK,
    @SerialName("purchase") PURCHASE
}
```

### 1.10 ProductIngredient

| Field | Kotlin Type | JSON Key | Notes |
|-------|------------|----------|-------|
| id | `String` | id | |
| productId | `String` | product_id | |
| inventoryId | `String` | inventory_id | |
| quantityRequired | `Double` | quantity_required | |
| capacity | `Double?` | capacity | |
| bringToEvent | `Boolean?` | bring_to_event | |
| createdAt | `String` | created_at | |
| ingredientName | `String?` | ingredient_name | Joined field |
| unit | `String?` | unit | Joined field |
| unitCost | `Double?` | unit_cost | Joined field |
| type | `InventoryType?` | type | Joined field |

### 1.11 Payment

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| eventId | `String` | event_id |
| userId | `String` | user_id |
| amount | `Double` | amount |
| paymentDate | `String` | payment_date |
| paymentMethod | `String` | payment_method |
| notes | `String?` | notes |
| createdAt | `String` | created_at |

### 1.12 EquipmentConflict

Not data class with default values — all fields required. No `id` field.

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| inventoryId | `String` | inventory_id |
| equipmentName | `String` | equipment_name |
| conflictingEventId | `String` | conflicting_event_id |
| eventDate | `String` | event_date |
| startTime | `String?` | start_time |
| endTime | `String?` | end_time |
| serviceType | `String` | service_type |
| clientName | `String?` | client_name |
| conflictType | `ConflictType` | conflict_type |

```kotlin
@Serializable
enum class ConflictType {
    @SerialName("overlap") OVERLAP,
    @SerialName("insufficient_gap") INSUFFICIENT_GAP,
    @SerialName("full_day") FULL_DAY
}
```

### 1.13 SupplySuggestion

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| ingredientName | `String` | ingredient_name |
| currentStock | `Double` | current_stock |
| unit | `String` | unit |
| unitCost | `Double` | unit_cost |
| suggestedQuantity | `Double` | suggested_quantity |

### 1.14 EquipmentSuggestion

| Field | Kotlin Type | JSON Key |
|-------|------------|----------|
| id | `String` | id |
| ingredientName | `String` | ingredient_name |
| currentStock | `Double` | current_stock |
| unit | `String` | unit |
| type | `String` | type |
| suggestedQuantity | `Double` | suggested_quantity |

### Additional Types

- **`ApiError`** — Sealed class: `Unauthorized`, `Forbidden`, `NotFound`, `ValidationError(errors: Map<String,String>)`, `ServerError(code: Int)`, `NetworkError(cause: Throwable)`, `DecodingError(cause: Throwable)`, `Unknown(cause: Throwable)`.
- **`EmptyResponse`** — Empty `@Serializable object` for 204 responses.

### Extensions (Phase 1)

- `DateFormatting.kt` — `String.toFormattedDate()` with `es_MX` locale, `String.toRelativeDate()`
- `StringValidation.kt` — `String.isValidEmail()`, `String.isNotBlank()` (Kotlin stdlib already has this)
- `CurrencyFormatting.kt` — `Double.asMXN()` property using `NumberFormat.getCurrencyInstance(Locale("es","MX"))`

---

## 2. core:network

### 2.1 KtorClient

```kotlin
@Singleton
class KtorClient @Inject constructor(
    private val authManager: AuthManager
) {
    val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
                encodeDefaults = false
            })
        }
        install(Auth) {
            bearer {
                loadTokens { authManager.getBearerTokens() }
                refreshTokens { authManager.refreshAndGetTokens() }
            }
        }
        install(Logging) {
            level = LogLevel.HEADERS  // DEBUG in dev builds
        }
        defaultRequest {
            url(BuildConfig.API_BASE_URL)
            contentType(ContentType.Application.Json)
        }
        engine {
            config {
                connectTimeout(30, TimeUnit.SECONDS)
                readTimeout(30, TimeUnit.SECONDS)
            }
        }
    }
}
```

**Behaviors:**
- Ktor `Auth` plugin handles bearer token injection automatically
- On 401: Ktor `refreshTokens` block calls `authManager.refreshAndGetTokens()`
- If refresh fails, `authManager.clearTokens()` and throws `ApiError.Unauthorized`
- Uses Kotlinx Serialization (NOT Gson/Moshi) for consistency with data classes
- `ignoreUnknownKeys = true` for forward compatibility

### 2.2 ApiService (typed API calls)

```kotlin
@Singleton
class ApiService @Inject constructor(
    private val client: KtorClient
) {
    suspend inline fun <reified T> get(
        endpoint: String,
        params: Map<String, String> = emptyMap()
    ): T = client.httpClient.get(endpoint) {
        params.forEach { (key, value) -> parameter(key, value) }
    }.body()

    suspend inline fun <reified T> post(
        endpoint: String,
        body: Any
    ): T = client.httpClient.post(endpoint) {
        setBody(body)
    }.body()

    suspend inline fun <reified T> put(
        endpoint: String,
        body: Any
    ): T = client.httpClient.put(endpoint) {
        setBody(body)
    }.body()

    suspend fun delete(endpoint: String) {
        client.httpClient.delete(endpoint)
    }

    suspend fun upload(
        endpoint: String,
        fileBytes: ByteArray,
        fileName: String,
        mimeType: String
    ): UploadResponse = client.httpClient.post(endpoint) {
        setBody(MultiPartFormDataContent(formData {
            append("file", fileBytes, Headers.build {
                append(HttpHeaders.ContentDisposition, "filename=\"$fileName\"")
                append(HttpHeaders.ContentType, mimeType)
            })
        }))
    }.body()
}
```

### 2.3 AuthManager

```kotlin
@Singleton
class AuthManager @Inject constructor(
    private val encryptedPrefs: SharedPreferences,  // EncryptedSharedPreferences
    @ApplicationContext private val context: Context
) {
    private val _authState = MutableStateFlow<AuthState>(AuthState.Unknown)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser: StateFlow<User?> = _currentUser.asStateFlow()

    private val refreshMutex = Mutex()

    // Keys in EncryptedSharedPreferences
    private companion object {
        const val KEY_ACCESS_TOKEN = "access_token"
        const val KEY_REFRESH_TOKEN = "refresh_token"
        const val KEY_USER_JSON = "current_user"
        const val KEY_BIOMETRIC_ENABLED = "biometric_enabled"
    }

    // Auth states
    sealed class AuthState {
        data object Unknown : AuthState()
        data object Authenticated : AuthState()
        data object Unauthenticated : AuthState()
        data object BiometricLocked : AuthState()
    }
}
```

**Methods:**

| Method | Signature | Description |
|--------|-----------|-------------|
| `restoreSession` | `suspend fun restoreSession()` | Read tokens from EncryptedPrefs. If present + biometric enabled → BiometricLocked. If present → Authenticated. Else → Unauthenticated. |
| `login` | `suspend fun login(email: String, password: String): User` | POST `/auth/login`. Store tokens. Set Authenticated. |
| `register` | `suspend fun register(name: String, email: String, password: String): User` | POST `/auth/register`. Store tokens. Set Authenticated. |
| `loginWithGoogle` | `suspend fun loginWithGoogle(idToken: String, fullName: String?): User` | POST `/auth/google`. Store tokens. Set Authenticated. |
| `logout` | `suspend fun logout()` | POST `/auth/logout`. Clear tokens. Set Unauthenticated. |
| `getBearerTokens` | `fun getBearerTokens(): BearerTokens?` | Read from EncryptedPrefs. Return `BearerTokens(accessToken, refreshToken)`. |
| `refreshAndGetTokens` | `suspend fun refreshAndGetTokens(): BearerTokens?` | Mutex-protected. POST `/auth/refresh`. Store new tokens. Return `BearerTokens`. |
| `clearTokens` | `fun clearTokens()` | Remove from EncryptedPrefs. Set Unauthenticated. Null currentUser. |
| `forgotPassword` | `suspend fun forgotPassword(email: String)` | POST `/auth/forgot-password`. |
| `resetPassword` | `suspend fun resetPassword(token: String, newPassword: String)` | POST `/auth/reset-password`. |
| `changePassword` | `suspend fun changePassword(current: String, newPassword: String)` | POST `/auth/change-password`. |
| `fetchCurrentUser` | `suspend fun fetchCurrentUser(): User` | GET `/auth/me`. Update `_currentUser`. |
| `isBiometricAvailable` | `fun isBiometricAvailable(): Boolean` | Check `BiometricManager.canAuthenticate()`. |

**Token response dual-format handling:**

```kotlin
@Serializable
data class AuthResponse(
    val user: User,
    val token: String? = null,         // Legacy format
    val tokens: TokenPair? = null      // New format
) {
    val accessToken: String get() = tokens?.accessToken ?: token ?: ""
    val refreshToken: String get() = tokens?.refreshToken ?: token ?: ""
}

@Serializable
data class TokenPair(
    @SerialName("access_token") val accessToken: String,
    @SerialName("refresh_token") val refreshToken: String
)
```

### 2.4 NetworkMonitor

```kotlin
@Singleton
class NetworkMonitor @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val connectivityManager = context.getSystemService<ConnectivityManager>()

    val isConnected: StateFlow<Boolean>  // Emits via registerDefaultNetworkCallback
    val connectionType: StateFlow<ConnectionType?>  // WIFI, CELLULAR, etc.
}
```

### 2.5 Endpoints

```kotlin
object Endpoints {
    // Auth
    const val REGISTER = "/auth/register"
    const val LOGIN = "/auth/login"
    const val LOGOUT = "/auth/logout"
    const val REFRESH = "/auth/refresh"
    const val FORGOT_PASSWORD = "/auth/forgot-password"
    const val RESET_PASSWORD = "/auth/reset-password"
    const val ME = "/auth/me"
    const val CHANGE_PASSWORD = "/auth/change-password"
    const val GOOGLE_AUTH = "/auth/google"

    // Clients
    const val CLIENTS = "/clients"
    fun client(id: String) = "/clients/$id"

    // Events
    const val EVENTS = "/events"
    const val UPCOMING_EVENTS = "/events/upcoming"
    fun event(id: String) = "/events/$id"
    fun eventProducts(id: String) = "/events/$id/products"
    fun eventExtras(id: String) = "/events/$id/extras"
    fun eventItems(id: String) = "/events/$id/items"
    fun eventEquipment(id: String) = "/events/$id/equipment"
    fun eventSupplies(id: String) = "/events/$id/supplies"
    const val EQUIPMENT_CONFLICTS = "/events/equipment/conflicts"
    const val EQUIPMENT_SUGGESTIONS = "/events/equipment/suggestions"
    const val SUPPLY_SUGGESTIONS = "/events/supplies/suggestions"

    // Products
    const val PRODUCTS = "/products"
    fun product(id: String) = "/products/$id"
    fun productIngredients(id: String) = "/products/$id/ingredients"
    const val BATCH_INGREDIENTS = "/products/ingredients/batch"

    // Inventory
    const val INVENTORY = "/inventory"
    fun inventoryItem(id: String) = "/inventory/$id"

    // Payments
    const val PAYMENTS = "/payments"
    fun payment(id: String) = "/payments/$id"

    // Unavailable Dates
    const val UNAVAILABLE_DATES = "/unavailable-dates"
    fun unavailableDate(id: String) = "/unavailable-dates/$id"

    // Search
    const val SEARCH = "/search"

    // Uploads
    const val UPLOAD_IMAGE = "/uploads/image"

    // Profile
    const val UPDATE_PROFILE = "/users/me"

    // Subscriptions
    const val SUBSCRIPTION_STATUS = "/subscriptions/status"

    // Devices
    const val REGISTER_DEVICE = "/devices/register"
    const val UNREGISTER_DEVICE = "/devices/unregister"
}
```

---

## 3. core:designsystem

### 3.1 Color Tokens

Defined as `Color` values in two `SolennixColorScheme` data class instances (light/dark). Accessed via `CompositionLocal` within `SolennixTheme`.

**All 43+ tokens identical to iOS** — see PRD sections 9.1. Implementation uses `Color(0xFF________)` hex format.

### 3.2 Typography — Same scale as iOS, mapped to Material 3 `TextStyle`

### 3.3 Spacing (4dp grid) — object constants, identical values to iOS

### 3.4 Shapes — `RoundedCornerShape` tokens matching iOS border radius

### 3.5 Shadows — Elevation `Dp` tokens (sm=2, md=6, lg=12, fab=8)

### 3.6 Gradient — `Brush.horizontalGradient` from `SolennixGold` to `SolennixGoldDark`

### 3.7 Components (Phase 1)

| Component | Props | Notes |
|-----------|-------|-------|
| `SolennixTextField` | `value: String`, `onValueChange: (String)->Unit`, `label: String`, `placeholder: String`, `leadingIcon: ImageVector?`, `isPassword: Boolean`, `keyboardType: KeyboardType`, `imeAction: ImeAction`, `errorMessage: String?`, `enabled: Boolean` | Uses `OutlinedTextField` (M3), shows error below, password toggle with `VisualTransformation` |
| `PremiumButton` | `text: String`, `onClick: ()->Unit`, `icon: ImageVector?`, `style: ButtonStyle` (.Primary/.Secondary/.Destructive), `isLoading: Boolean`, `enabled: Boolean` | Primary uses `PremiumGradient` background via `Box` + `Brush`, loading shows `CircularProgressIndicator` |
| `Avatar` | `name: String`, `photoUrl: String?`, `size: Dp` | Initials fallback with deterministic color from palette. Coil `AsyncImage` for URL. `CircleShape` clip. |
| `EmptyState` | `icon: ImageVector`, `title: String`, `message: String`, `actionText: String?`, `onAction: (()->Unit)?` | Material Symbol icon, centered layout, optional CTA `PremiumButton` |
| `StatusBadge` | `status: String` | Colored pill (`Surface` + `Text`), maps status string to color token |
| `ConfirmDialog` | `title: String`, `message: String`, `confirmText: String`, `onConfirm: ()->Unit`, `onDismiss: ()->Unit`, `isDestructive: Boolean` | Material 3 `AlertDialog` |
| `ToastOverlay` | `message: String`, `type: ToastType` (.Success/.Error/.Info/.Warning), `visible: Boolean` | Auto-dismiss after 3s via `LaunchedEffect`, slides from top with `AnimatedVisibility` |
| `SkeletonLoading` | `modifier: Modifier` | Shimmer effect with infinite `rememberInfiniteTransition`, translucent gradient animation |

---

## 4. Auth Screens

### 4.1 LoginScreen

**Fields:**

| Field | Type | KeyboardType | AutofillType | Validation |
|-------|------|-------------|--------------|------------|
| email | `SolennixTextField` | `Email` | `EmailAddress` | Non-empty, valid email format |
| password | `SolennixTextField` (isPassword) | `Password` | `Password` | Non-empty |

**Layout (top to bottom):**
1. Animated logo (tulip cup) + "SOLENNIX" in `CinzelFontFamily`
2. Tagline "CADA DETALLE IMPORTA" — letter-spacing 5.5.sp
3. Email field
4. Password field with visibility toggle
5. `PremiumButton` "Iniciar Sesion" (.Primary)
6. "Olvidaste tu contrasena?" text button → `ForgotPasswordScreen`
7. Separator "o continua con"
8. **Google One Tap sign-in button** (Credential Manager API)
9. "Crear cuenta" text button → `RegisterScreen`

**API call:** `POST /auth/login` with `{ email, password }`

**Success:** Store tokens via `AuthManager.login()`. Navigate to main flow.

**Error:** Show inline error message. Handle: 401 (invalid credentials), network error, server error.

### 4.2 RegisterScreen

**Fields:**

| Field | Type | Validation |
|-------|------|------------|
| name | `SolennixTextField` | Non-empty, 2+ characters |
| email | `SolennixTextField` | Non-empty, valid email format |
| password | `SolennixTextField` (isPassword) | 6+ characters |
| confirmPassword | `SolennixTextField` (isPassword) | Must match password |

**Layout:**
1. TopAppBar with back navigation + Title "Crear Cuenta"
2. Name, Email, Password, Confirm Password fields
3. Feature pills (Gratis, Seguro, Escalable)
4. `PremiumButton` "Crear Cuenta" (.Primary)
5. Google One Tap as alternative
6. Links to Terms & Privacy

**API call:** `POST /auth/register` with `{ name, email, password }`

### 4.3 ForgotPasswordScreen

- Email field + "Enviar enlace" button
- Success state with mail icon + "Revisa tu correo"
- "Volver a Login" back navigation
- **API:** `POST /auth/forgot-password`

### 4.4 ResetPasswordScreen

- Entry via deep link `solennix://reset-password?token=X`
- New Password + Confirm Password fields
- Success state with checkmark → "Ir a Login"
- **API:** `POST /auth/reset-password` with `{ token, password }`

### 4.5 AuthViewModel

Single `@HiltViewModel` shared by auth screens:

```kotlin
@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authManager: AuthManager
) : ViewModel() {

    // UI State
    var isLoading by mutableStateOf(false)
    var errorMessage by mutableStateOf<String?>(null)

    // Login
    var loginEmail by mutableStateOf("")
    var loginPassword by mutableStateOf("")
    val isLoginValid: Boolean get() = loginEmail.isValidEmail() && loginPassword.isNotBlank()
    fun login() { viewModelScope.launch { ... } }

    // Register
    var registerName by mutableStateOf("")
    var registerEmail by mutableStateOf("")
    var registerPassword by mutableStateOf("")
    var registerConfirmPassword by mutableStateOf("")
    val isRegisterValid: Boolean get() = ...
    fun register() { viewModelScope.launch { ... } }

    // Forgot
    var forgotEmail by mutableStateOf("")
    var forgotSuccess by mutableStateOf(false)
    fun forgotPassword() { viewModelScope.launch { ... } }

    // Reset
    var resetToken by mutableStateOf("")
    var newPassword by mutableStateOf("")
    var confirmNewPassword by mutableStateOf("")
    var resetSuccess by mutableStateOf(false)
    fun resetPassword() { viewModelScope.launch { ... } }
}
```

---

## 5. Navigation

### 5.1 Route Sealed Class

```kotlin
@Serializable
sealed class Route {
    @Serializable data class EventDetail(val id: String) : Route()
    @Serializable data class EventForm(val id: String? = null, val clientId: String? = null) : Route()
    @Serializable data class EventChecklist(val id: String) : Route()
    @Serializable data class ClientDetail(val id: String) : Route()
    @Serializable data class ClientForm(val id: String? = null) : Route()
    @Serializable data class ProductDetail(val id: String) : Route()
    @Serializable data class ProductForm(val id: String? = null) : Route()
    @Serializable data class InventoryDetail(val id: String) : Route()
    @Serializable data class InventoryForm(val id: String? = null) : Route()
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

### 5.2 TopLevelDestination Enum (Phone bottom nav)

```kotlin
enum class TopLevelDestination(
    val label: String,
    val unselectedIcon: ImageVector,
    val selectedIcon: ImageVector,
    val route: String
) {
    HOME("Inicio", Icons.Outlined.Home, Icons.Filled.Home, "home"),
    CALENDAR("Calendario", Icons.Outlined.CalendarMonth, Icons.Filled.CalendarMonth, "calendar"),
    CLIENTS("Clientes", Icons.Outlined.People, Icons.Filled.People, "clients"),
    MORE("Mas", Icons.Outlined.MoreHoriz, Icons.Filled.MoreHoriz, "more")
}
```

### 5.3 SidebarSection Enum (Tablet NavigationRail)

```kotlin
enum class SidebarSection(val label: String, val icon: ImageVector) {
    DASHBOARD("Inicio", Icons.Filled.Home),
    CALENDAR("Calendario", Icons.Filled.CalendarMonth),
    CLIENTS("Clientes", Icons.Filled.People),
    PRODUCTS("Productos", Icons.Filled.Inventory2),
    INVENTORY("Inventario", Icons.Filled.Archive),
    SEARCH("Buscar", Icons.Filled.Search),
    SETTINGS("Ajustes", Icons.Filled.Settings)
}
```

### 5.4 MainActivity (Single Activity)

```kotlin
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val windowSizeClass = calculateWindowSizeClass(this)
            SolennixTheme {
                MainNavHost(windowSizeClass = windowSizeClass)
            }
        }
    }
}
```

### 5.5 MainNavHost (Auth Gate)

```kotlin
@Composable
fun MainNavHost(windowSizeClass: WindowSizeClass) {
    val authViewModel: AuthViewModel = hiltViewModel()
    val authState by authViewModel.authState.collectAsStateWithLifecycle()

    when (authState) {
        AuthState.Unknown -> LoadingScreen()
        AuthState.Unauthenticated -> AuthNavHost()
        AuthState.BiometricLocked -> BiometricGateScreen()
        AuthState.Authenticated -> {
            when (windowSizeClass.widthSizeClass) {
                WindowWidthSizeClass.Compact -> CompactBottomNavLayout()
                else -> AdaptiveNavigationRailLayout()
            }
        }
    }
}
```

---

## 6. Scenarios

### SC-01: Fresh Login
1. User opens app, no tokens in EncryptedSharedPreferences
2. `AuthManager.restoreSession()` sets `Unauthenticated`
3. `MainNavHost` shows `AuthNavHost` → `LoginScreen`
4. User enters email + password, taps "Iniciar Sesion"
5. `AuthViewModel.login()` calls `POST /auth/login`
6. On 200: tokens stored, `authState = Authenticated`
7. `MainNavHost` recomposes → `CompactBottomNavLayout`

### SC-02: Token Refresh on 401
1. User authenticated, Ktor makes API call
2. Gets 401 → Ktor Auth plugin calls `refreshTokens`
3. `authManager.refreshAndGetTokens()` uses Mutex → `POST /auth/refresh`
4. On success: new tokens stored, original request retried
5. On failure: `clearTokens()`, `authState = Unauthenticated`

### SC-03: Google One Tap Sign-In
1. User taps Google sign-in button
2. Credential Manager shows account picker
3. On success: extract `idToken` from `GoogleIdTokenCredential`
4. Send to `POST /auth/google`
5. Backend verifies, returns JWT tokens
6. Normal post-login flow

### SC-04: Forgot + Reset Password
1. User taps "Olvidaste tu contrasena?" → `ForgotPasswordScreen`
2. Enters email → `POST /auth/forgot-password` → success message
3. User clicks email link: `solennix://reset-password?token=abc123`
4. Deep link routes to `ResetPasswordScreen` with token
5. User enters new password → `POST /auth/reset-password` → success

### SC-05: Biometric Unlock
1. App launches, tokens exist, biometric enabled
2. `authState = BiometricLocked`
3. `BiometricGateScreen` shows BiometricPrompt
4. On success → `authState = Authenticated`
5. On 3 failures → `clearTokens()`, `authState = Unauthenticated`

### SC-06: Tablet Layout
1. User on tablet (expanded width)
2. `MainNavHost` shows `AdaptiveNavigationRailLayout`
3. NavigationRail on left with destinations
4. Content area shows selected section

### SC-07: Deep Link While Authenticated
1. User logged in, app in background
2. Opens `solennix://reset-password?token=X`
3. `navDeepLink` routes to `ResetPasswordScreen`

### SC-08: Offline State
1. `NetworkMonitor.isConnected` emits `false`
2. App shows offline banner (non-blocking Snackbar)
3. API calls fail with `ApiError.NetworkError`
4. When connectivity returns, banner dismisses

---

## 7. File Manifest (Phase 1)

```
android/
  app/
    src/main/
      java/com/creapolis/solennix/
        SolennixApp.kt
        MainActivity.kt
        MainNavHost.kt
        ui/navigation/
          Route.kt
          TopLevelDestination.kt
          SidebarSection.kt
          CompactBottomNavLayout.kt
          AdaptiveNavigationRailLayout.kt
          AuthNavHost.kt
      res/
        values/strings.xml
        values/themes.xml
      AndroidManifest.xml
    build.gradle.kts

  core/
    model/
      src/main/java/com/creapolis/solennix/core/model/
        User.kt
        Client.kt
        Event.kt
        Product.kt
        InventoryItem.kt
        EventProduct.kt
        EventExtra.kt
        EventEquipment.kt
        EventSupply.kt
        ProductIngredient.kt
        Payment.kt
        EquipmentConflict.kt
        SupplySuggestion.kt
        EquipmentSuggestion.kt
        ApiError.kt
        AuthResponse.kt
      build.gradle.kts

    network/
      src/main/java/com/creapolis/solennix/core/network/
        KtorClient.kt
        ApiService.kt
        AuthManager.kt
        Endpoints.kt
        NetworkMonitor.kt
        di/NetworkModule.kt
      build.gradle.kts

    designsystem/
      src/main/java/com/creapolis/solennix/core/designsystem/
        theme/
          Color.kt
          Typography.kt
          Spacing.kt
          Shape.kt
          Elevation.kt
          Gradient.kt
          Theme.kt
          SolennixColorScheme.kt
        component/
          SolennixTextField.kt
          PremiumButton.kt
          Avatar.kt
          EmptyState.kt
          StatusBadge.kt
          ConfirmDialog.kt
          ToastOverlay.kt
          SkeletonLoading.kt
      build.gradle.kts

  feature/
    auth/
      src/main/java/com/creapolis/solennix/feature/auth/
        ui/
          LoginScreen.kt
          RegisterScreen.kt
          ForgotPasswordScreen.kt
          ResetPasswordScreen.kt
          BiometricGateScreen.kt
          GoogleSignInButton.kt
        viewmodel/
          AuthViewModel.kt
      build.gradle.kts

  build.gradle.kts          (root)
  settings.gradle.kts
  gradle/libs.versions.toml
```

**Total: ~50 Kotlin files** (including build scripts)
