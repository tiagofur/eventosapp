# Design: Native Android Foundation (Phase 1)

## 1. File/Directory Structure

```
android/
+-- app/                                        # Main app module
|   +-- src/main/
|   |   +-- java/com/creapolis/solennix/
|   |   |   +-- SolennixApp.kt                 # @HiltAndroidApp Application class
|   |   |   +-- MainActivity.kt                # @AndroidEntryPoint single Activity
|   |   |   +-- MainNavHost.kt                 # Auth gate + adaptive layout switch
|   |   |   +-- ui/navigation/
|   |   |       +-- Route.kt                   # @Serializable sealed class
|   |   |       +-- TopLevelDestination.kt     # Enum for bottom nav items
|   |   |       +-- SidebarSection.kt          # Enum for NavigationRail items
|   |   |       +-- CompactBottomNavLayout.kt  # Phone: NavigationBar + FAB
|   |   |       +-- AdaptiveNavigationRailLayout.kt # Tablet: NavigationRail
|   |   |       +-- AuthNavHost.kt             # NavHost for auth flow
|   |   +-- res/
|   |   |   +-- values/strings.xml             # Spanish (MX) strings
|   |   |   +-- values/themes.xml              # Base theme (Material 3)
|   |   |   +-- font/cinzel_regular.ttf        # Brand font
|   |   |   +-- font/cinzel_semibold.ttf       # Brand font
|   |   +-- AndroidManifest.xml
|   +-- build.gradle.kts
|
+-- core/
|   +-- model/                                  # Data models module
|   |   +-- src/main/java/com/creapolis/solennix/core/model/
|   |   |   +-- User.kt, Client.kt, Event.kt, Product.kt, InventoryItem.kt
|   |   |   +-- EventProduct.kt, EventExtra.kt, EventEquipment.kt, EventSupply.kt
|   |   |   +-- ProductIngredient.kt, Payment.kt, EquipmentConflict.kt
|   |   |   +-- SupplySuggestion.kt, EquipmentSuggestion.kt
|   |   |   +-- ApiError.kt, AuthResponse.kt
|   |   |   +-- extensions/
|   |   |       +-- DateFormatting.kt, StringValidation.kt, CurrencyFormatting.kt
|   |   +-- build.gradle.kts
|   |
|   +-- network/                                # Network layer module
|   |   +-- src/main/java/com/creapolis/solennix/core/network/
|   |   |   +-- KtorClient.kt                  # Ktor HttpClient config
|   |   |   +-- ApiService.kt                  # Typed GET/POST/PUT/DELETE
|   |   |   +-- AuthManager.kt                 # EncryptedSharedPrefs + biometric
|   |   |   +-- Endpoints.kt                   # Object with route constants
|   |   |   +-- NetworkMonitor.kt              # ConnectivityManager wrapper
|   |   |   +-- di/
|   |   |       +-- NetworkModule.kt           # Hilt @Module for network deps
|   |   +-- build.gradle.kts
|   |
|   +-- designsystem/                           # Design system module
|       +-- src/main/java/com/creapolis/solennix/core/designsystem/
|       |   +-- theme/
|       |   |   +-- Color.kt                   # All hex color values
|       |   |   +-- SolennixColorScheme.kt     # Data class with 43+ color properties
|       |   |   +-- Typography.kt              # TextStyle definitions
|       |   |   +-- Spacing.kt                 # 4dp grid constants
|       |   |   +-- Shape.kt                   # RoundedCornerShape tokens
|       |   |   +-- Elevation.kt               # Dp elevation tokens
|       |   |   +-- Gradient.kt                # Premium gradient Brush
|       |   |   +-- Theme.kt                   # SolennixTheme @Composable
|       |   +-- component/
|       |       +-- SolennixTextField.kt
|       |       +-- PremiumButton.kt
|       |       +-- Avatar.kt
|       |       +-- EmptyState.kt
|       |       +-- StatusBadge.kt
|       |       +-- ConfirmDialog.kt
|       |       +-- ToastOverlay.kt
|       |       +-- SkeletonLoading.kt
|       +-- build.gradle.kts
|
+-- feature/
|   +-- auth/                                   # Auth feature module
|       +-- src/main/java/com/creapolis/solennix/feature/auth/
|       |   +-- ui/
|       |   |   +-- LoginScreen.kt
|       |   |   +-- RegisterScreen.kt
|       |   |   +-- ForgotPasswordScreen.kt
|       |   |   +-- ResetPasswordScreen.kt
|       |   |   +-- BiometricGateScreen.kt
|       |   |   +-- GoogleSignInButton.kt
|       |   +-- viewmodel/
|       |       +-- AuthViewModel.kt
|       +-- build.gradle.kts
|
+-- build.gradle.kts                            # Root build script
+-- settings.gradle.kts                         # Module declarations
+-- gradle/libs.versions.toml                   # Version catalog
+-- gradle.properties                           # JVM/Kotlin config
```

**Total: ~50 Kotlin/Gradle files** (16 models + 3 extensions + 5 network + 1 DI + 8 theme + 8 components + 6 auth + 6 navigation/app = ~53 source files + ~8 build scripts)

---

## 2. Gradle Multi-Module Setup

### settings.gradle.kts

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolution {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "Solennix"
include(":app")
include(":core:model")
include(":core:network")
include(":core:designsystem")
include(":feature:auth")
```

### gradle/libs.versions.toml

```toml
[versions]
agp = "8.7.0"
kotlin = "2.0.21"
compose-bom = "2024.12.01"
ktor = "3.0.3"
hilt = "2.53.1"
room = "2.6.1"
coil = "3.0.4"
kotlinx-serialization = "1.7.3"
navigation = "2.8.5"
lifecycle = "2.8.7"
biometric = "1.2.0-alpha05"
credentials = "1.5.0-rc01"
datastore = "1.1.1"
security-crypto = "1.1.0-alpha06"

[libraries]
# Compose
compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }
compose-material3 = { group = "androidx.compose.material3", name = "material3" }
compose-material3-adaptive = { group = "androidx.compose.material3.adaptive", name = "adaptive" }
compose-material3-windowsizeclass = { group = "androidx.compose.material3", name = "material3-window-size-class" }
compose-material-icons = { group = "androidx.compose.material", name = "material-icons-extended" }
compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }

# Navigation
navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation" }

# Lifecycle
lifecycle-runtime-compose = { group = "androidx.lifecycle", name = "lifecycle-runtime-compose", version.ref = "lifecycle" }
lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycle" }

# Ktor
ktor-client-core = { group = "io.ktor", name = "ktor-client-core", version.ref = "ktor" }
ktor-client-okhttp = { group = "io.ktor", name = "ktor-client-okhttp", version.ref = "ktor" }
ktor-client-content-negotiation = { group = "io.ktor", name = "ktor-client-content-negotiation", version.ref = "ktor" }
ktor-serialization-json = { group = "io.ktor", name = "ktor-serialization-kotlinx-json", version.ref = "ktor" }
ktor-client-auth = { group = "io.ktor", name = "ktor-client-auth", version.ref = "ktor" }
ktor-client-logging = { group = "io.ktor", name = "ktor-client-logging", version.ref = "ktor" }

# Kotlinx
kotlinx-serialization-json = { group = "org.jetbrains.kotlinx", name = "kotlinx-serialization-json", version.ref = "kotlinx-serialization" }

# Hilt
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version = "1.2.0" }

# Coil
coil-compose = { group = "io.coil-kt.coil3", name = "coil-compose", version.ref = "coil" }
coil-network-ktor = { group = "io.coil-kt.coil3", name = "coil-network-ktor3", version.ref = "coil" }

# Security
security-crypto = { group = "androidx.security", name = "security-crypto", version.ref = "security-crypto" }
biometric = { group = "androidx.biometric", name = "biometric", version.ref = "biometric" }

# Credentials (Google One Tap)
credentials = { group = "androidx.credentials", name = "credentials", version.ref = "credentials" }
credentials-play = { group = "androidx.credentials", name = "credentials-play-services-auth", version.ref = "credentials" }
google-id = { group = "com.google.android.libraries.identity.googleid", name = "googleid", version = "1.1.1" }

# DataStore
datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }

# Room (used in Phase 2+, declared here for completeness)
room-runtime = { group = "androidx.room", name = "room-runtime", version.ref = "room" }
room-ktx = { group = "androidx.room", name = "room-ktx", version.ref = "room" }
room-compiler = { group = "androidx.room", name = "room-compiler", version.ref = "room" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
android-library = { id = "com.android.library", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
ksp = { id = "com.google.devtools.ksp", version = "2.0.21-1.0.28" }
```

### build.gradle.kts (root)

```kotlin
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.serialization) apply false
    alias(libs.plugins.compose.compiler) apply false
    alias(libs.plugins.hilt) apply false
    alias(libs.plugins.ksp) apply false
}
```

### Dependency Graph

```
core:model          (no deps — pure Kotlin + Serialization)
core:designsystem   (no deps — pure Compose)
core:network   -->  core:model (for User, AuthResponse, ApiError)
feature:auth   -->  core:model, core:network, core:designsystem
app            -->  all modules
```

### Module build.gradle.kts Patterns

#### core:model/build.gradle.kts

```kotlin
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
}

android {
    namespace = "com.creapolis.solennix.core.model"
    compileSdk = 35
    defaultConfig { minSdk = 26 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(libs.kotlinx.serialization.json)
}
```

#### core:network/build.gradle.kts

```kotlin
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.hilt)
    alias(libs.plugins.ksp)
}

android {
    namespace = "com.creapolis.solennix.core.network"
    compileSdk = 35
    defaultConfig { minSdk = 26 }
    buildFeatures { buildConfig = true }
    defaultConfig {
        buildConfigField("String", "API_BASE_URL", "\"https://api.solennix.com\"")
    }
}

dependencies {
    implementation(project(":core:model"))

    // Ktor
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.okhttp)
    implementation(libs.ktor.client.content.negotiation)
    implementation(libs.ktor.serialization.json)
    implementation(libs.ktor.client.auth)
    implementation(libs.ktor.client.logging)

    // Hilt
    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)

    // Security
    implementation(libs.security.crypto)
    implementation(libs.biometric)

    // DataStore
    implementation(libs.datastore.preferences)
}
```

#### core:designsystem/build.gradle.kts

```kotlin
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
}

android {
    namespace = "com.creapolis.solennix.core.designsystem"
    compileSdk = 35
    defaultConfig { minSdk = 26 }
    buildFeatures { compose = true }
}

dependencies {
    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation(libs.compose.material3)
    implementation(libs.compose.material.icons)
    implementation(libs.compose.ui.tooling.preview)
    debugImplementation(libs.compose.ui.tooling)

    // Coil for Avatar component
    implementation(libs.coil.compose)
}
```

#### feature:auth/build.gradle.kts

```kotlin
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.hilt)
    alias(libs.plugins.ksp)
}

android {
    namespace = "com.creapolis.solennix.feature.auth"
    compileSdk = 35
    defaultConfig { minSdk = 26 }
    buildFeatures { compose = true }
}

dependencies {
    implementation(project(":core:model"))
    implementation(project(":core:network"))
    implementation(project(":core:designsystem"))

    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation(libs.compose.material3)

    implementation(libs.hilt.android)
    ksp(libs.hilt.compiler)
    implementation(libs.hilt.navigation.compose)
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.runtime.compose)
    implementation(libs.navigation.compose)

    // Google One Tap
    implementation(libs.credentials)
    implementation(libs.credentials.play)
    implementation(libs.google.id)
}
```

---

## 3. KtorClient Design

### Core client configuration

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideEncryptedSharedPreferences(
        @ApplicationContext context: Context
    ): SharedPreferences = EncryptedSharedPreferences.create(
        context,
        "solennix_secure_prefs",
        MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    @Provides
    @Singleton
    fun provideAuthManager(
        encryptedPrefs: SharedPreferences,
        @ApplicationContext context: Context
    ): AuthManager = AuthManager(encryptedPrefs, context)

    @Provides
    @Singleton
    fun provideKtorClient(authManager: AuthManager): KtorClient =
        KtorClient(authManager)

    @Provides
    @Singleton
    fun provideApiService(client: KtorClient): ApiService =
        ApiService(client)

    @Provides
    @Singleton
    fun provideNetworkMonitor(
        @ApplicationContext context: Context
    ): NetworkMonitor = NetworkMonitor(context)
}
```

### Token refresh flow (Ktor Auth plugin)

Ktor's `Auth` plugin handles 401 responses automatically via the `bearer {}` block:

```kotlin
install(Auth) {
    bearer {
        loadTokens {
            authManager.getBearerTokens()
        }
        refreshTokens {
            authManager.refreshAndGetTokens()
        }
    }
}
```

**How it works:**
1. Every request gets `Authorization: Bearer <accessToken>` via `loadTokens`
2. On 401, Ktor calls `refreshTokens` automatically
3. `authManager.refreshAndGetTokens()` is protected by `Mutex` to prevent concurrent refreshes
4. On success: new tokens stored, request retried with new Bearer
5. On failure: `authManager.clearTokens()`, throws exception → ViewModel catches and sets `Unauthenticated`

```kotlin
// Inside AuthManager
private val refreshMutex = Mutex()

suspend fun refreshAndGetTokens(): BearerTokens? {
    return refreshMutex.withLock {
        val refreshToken = encryptedPrefs.getString(KEY_REFRESH_TOKEN, null)
            ?: throw ApiError.Unauthorized

        try {
            // Direct HTTP call (not via KtorClient to avoid circular dependency)
            val response = refreshHttpClient.post(BuildConfig.API_BASE_URL + Endpoints.REFRESH) {
                contentType(ContentType.Application.Json)
                setBody(mapOf("refresh_token" to refreshToken))
            }.body<TokenPair>()

            storeTokens(response.accessToken, response.refreshToken)
            BearerTokens(response.accessToken, response.refreshToken)
        } catch (e: Exception) {
            clearTokens()
            null
        }
    }
}
```

**Key insight:** `refreshMutex.withLock` is the Kotlin coroutine equivalent of Swift's actor isolation. It prevents multiple concurrent 401 handlers from all trying to refresh simultaneously. The first one refreshes; the rest wait and get the new token.

---

## 4. AuthManager Design

### EncryptedSharedPreferences storage

```kotlin
@Singleton
class AuthManager @Inject constructor(
    private val encryptedPrefs: SharedPreferences,
    @ApplicationContext private val context: Context
) {
    private val _authState = MutableStateFlow<AuthState>(AuthState.Unknown)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser: StateFlow<User?> = _currentUser.asStateFlow()

    // Dedicated refresh client (avoids circular dependency with main KtorClient)
    private val refreshHttpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true })
        }
    }
}
```

### State management on app launch

```kotlin
suspend fun restoreSession() {
    val accessToken = encryptedPrefs.getString(KEY_ACCESS_TOKEN, null)
    val refreshToken = encryptedPrefs.getString(KEY_REFRESH_TOKEN, null)

    if (accessToken == null || refreshToken == null) {
        _authState.value = AuthState.Unauthenticated
        return
    }

    val biometricEnabled = encryptedPrefs.getBoolean(KEY_BIOMETRIC_ENABLED, false)
    if (biometricEnabled && isBiometricAvailable()) {
        _authState.value = AuthState.BiometricLocked
        return
    }

    _authState.value = AuthState.Authenticated
    _currentUser.value = loadCachedUser()
}
```

### Token storage after login

```kotlin
fun storeTokens(accessToken: String, refreshToken: String) {
    encryptedPrefs.edit()
        .putString(KEY_ACCESS_TOKEN, accessToken)
        .putString(KEY_REFRESH_TOKEN, refreshToken)
        .apply()
    _authState.value = AuthState.Authenticated
}

fun clearTokens() {
    encryptedPrefs.edit()
        .remove(KEY_ACCESS_TOKEN)
        .remove(KEY_REFRESH_TOKEN)
        .remove(KEY_USER_JSON)
        .apply()
    _currentUser.value = null
    _authState.value = AuthState.Unauthenticated
}
```

### Biometric flow

```kotlin
fun isBiometricAvailable(): Boolean {
    val biometricManager = BiometricManager.from(context)
    return biometricManager.canAuthenticate(BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
}

/**
 * Called from BiometricGateScreen composable.
 * The actual BiometricPrompt is shown from the Activity/Fragment context.
 * On success, call unlockWithBiometric().
 */
fun unlockWithBiometric() {
    _authState.value = AuthState.Authenticated
    _currentUser.value = loadCachedUser()
}

fun failedBiometric() {
    clearTokens()
}
```

### Dual-token response handling

```kotlin
@Serializable
data class AuthResponse(
    val user: User,
    val token: String? = null,
    val tokens: TokenPair? = null
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

---

## 5. Color System Design

### SolennixColorScheme data class

```kotlin
data class SolennixColorScheme(
    // Brand
    val primary: Color,
    val primaryDark: Color,
    val primaryLight: Color,
    val secondary: Color,

    // Surfaces
    val background: Color,
    val surfaceGrouped: Color,
    val surface: Color,
    val surfaceAlt: Color,
    val card: Color,

    // Text
    val primaryText: Color,
    val secondaryText: Color,
    val tertiaryText: Color,
    val inverseText: Color,

    // Borders
    val border: Color,
    val borderLight: Color,
    val divider: Color,

    // Semantic
    val success: Color,
    val warning: Color,
    val error: Color,
    val info: Color,

    // Event Status
    val statusQuoted: Color,
    val statusConfirmed: Color,
    val statusCompleted: Color,
    val statusCancelled: Color,

    // KPI
    val kpiBlue: Color,
    val kpiGreen: Color,
    val kpiOrange: Color,
    val kpiRed: Color,

    // Tab Bar
    val tabBarBg: Color,
    val tabBarActive: Color,
    val tabBarInactive: Color,

    // Avatar palette
    val avatarPalette: List<Color>
)
```

### CompositionLocal for theming

```kotlin
val LocalSolennixColors = staticCompositionLocalOf { LightSolennixColors }

@Composable
fun SolennixTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkSolennixColors else LightSolennixColors

    CompositionLocalProvider(
        LocalSolennixColors provides colorScheme
    ) {
        MaterialTheme(
            colorScheme = colorScheme.toMaterialColorScheme(),
            typography = SolennixTypography,
            shapes = SolennixShapes,
            content = content
        )
    }
}

// Convenience accessor
object SolennixTheme {
    val colors: SolennixColorScheme
        @Composable @ReadOnlyComposable
        get() = LocalSolennixColors.current
}
```

**Usage in any composable:**
```kotlin
Text("Hola", color = SolennixTheme.colors.primaryText)
Surface(color = SolennixTheme.colors.card) { ... }
```

---

## 6. Navigation Architecture

### Auth gate in MainNavHost

```kotlin
@Composable
fun MainNavHost(windowSizeClass: WindowSizeClass) {
    val authManager: AuthManager = // injected via Hilt
    val authState by authManager.authState.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        authManager.restoreSession()
    }

    when (authState) {
        AuthState.Unknown -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = SolennixTheme.colors.primary)
            }
        }
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

### CompactBottomNavLayout (Phone)

```kotlin
@Composable
fun CompactBottomNavLayout() {
    var selectedDestination by remember { mutableStateOf(TopLevelDestination.HOME) }
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar(containerColor = SolennixTheme.colors.tabBarBg) {
                TopLevelDestination.entries.forEachIndexed { index, destination ->
                    NavigationBarItem(
                        selected = selectedDestination == destination,
                        onClick = { selectedDestination = destination },
                        icon = {
                            Icon(
                                if (selectedDestination == destination) destination.selectedIcon
                                else destination.unselectedIcon,
                                contentDescription = destination.label
                            )
                        },
                        label = { Text(destination.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = SolennixTheme.colors.tabBarActive,
                            unselectedIconColor = SolennixTheme.colors.tabBarInactive,
                            indicatorColor = SolennixTheme.colors.primaryLight
                        )
                    )
                }
            }
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { /* Navigate to EventFormScreen */ },
                containerColor = SolennixTheme.colors.primary,
                elevation = FloatingActionButtonDefaults.elevation(
                    defaultElevation = SolennixElevation.fab
                )
            ) {
                Icon(Icons.Filled.Add, "Nuevo Evento", tint = Color.White)
            }
        },
        floatingActionButtonPosition = FabPosition.Center
    ) { padding ->
        NavHost(navController, startDestination = "home", Modifier.padding(padding)) {
            composable("home") { Text("Dashboard — Phase 2") }
            composable("calendar") { Text("Calendar — Phase 2") }
            composable("clients") { Text("Clients — Phase 2") }
            composable("more") { Text("More — Phase 2") }
            // Detail routes via Route sealed class
        }
    }
}
```

### AdaptiveNavigationRailLayout (Tablet)

```kotlin
@Composable
fun AdaptiveNavigationRailLayout() {
    var selectedSection by remember { mutableStateOf(SidebarSection.DASHBOARD) }

    Row(Modifier.fillMaxSize()) {
        NavigationRail(
            containerColor = SolennixTheme.colors.card,
            header = {
                // Solennix logo
                Text("S", style = SolennixTitle, color = SolennixTheme.colors.primary)
            }
        ) {
            SidebarSection.entries.forEach { section ->
                NavigationRailItem(
                    selected = selectedSection == section,
                    onClick = { selectedSection = section },
                    icon = { Icon(section.icon, section.label) },
                    label = { Text(section.label) }
                )
            }
        }

        // Content area
        Box(Modifier.fillMaxSize().background(SolennixTheme.colors.surfaceGrouped)) {
            when (selectedSection) {
                SidebarSection.DASHBOARD -> Text("Dashboard — Phase 2")
                SidebarSection.SETTINGS -> Text("Settings — Phase 4")
                // ...
                else -> Text("${selectedSection.label} — Phase 2+")
            }
        }
    }
}
```

### Deep linking

```kotlin
// In AuthNavHost or MainNavHost
composable(
    route = "reset-password?token={token}",
    deepLinks = listOf(
        navDeepLink { uriPattern = "solennix://reset-password?token={token}" }
    ),
    arguments = listOf(navArgument("token") { type = NavType.StringType; nullable = true })
) { backStackEntry ->
    val token = backStackEntry.arguments?.getString("token")
    ResetPasswordScreen(token = token)
}
```

Applied in `AndroidManifest.xml`:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="solennix" />
</intent-filter>
```

---

## 7. Dependency Injection via Hilt

### Strategy: @HiltAndroidApp + @AndroidEntryPoint + @HiltViewModel

```kotlin
// SolennixApp.kt
@HiltAndroidApp
class SolennixApp : Application()

// MainActivity.kt
@AndroidEntryPoint
class MainActivity : ComponentActivity() { ... }

// AuthViewModel.kt
@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authManager: AuthManager,
    private val apiService: ApiService
) : ViewModel() { ... }
```

### Consuming in composables

```kotlin
@Composable
fun LoginScreen(
    viewModel: AuthViewModel = hiltViewModel()
) {
    // viewModel already has AuthManager and ApiService injected
    val authState by viewModel.authManager.authState.collectAsStateWithLifecycle()
    // ...
}
```

### Why Hilt over manual DI / Koin

- **Compile-time safety** — errors are caught at build time, not runtime
- **Standard** — official DI for Android (Google), largest community
- **ViewModel support** — `@HiltViewModel` + `hiltViewModel()` is seamless
- **Testing** — `@TestInstallIn` allows easy module replacement in tests
- **WorkManager** — `@HiltWorker` for Phase 5 (widgets, sync)
