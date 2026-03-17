# Design: Native iOS Foundation (Phase 1)

## 1. File/Directory Structure

```
ios/
+-- Solennix/
|   +-- SolennixApp.swift                    # @main entry, environment injection
|   +-- ContentView.swift                    # Auth gate: if authenticated → MainLayout else → LoginView
|   +-- Navigation/
|   |   +-- Route.swift                      # Route enum (Hashable)
|   |   +-- Tab.swift                        # Tab enum for bottom bar
|   |   +-- CompactTabLayout.swift           # iPhone: TabView + 4 NavigationStacks + FAB
|   |   +-- SidebarSplitLayout.swift         # iPad: NavigationSplitView
|   |   +-- SidebarView.swift                # Sidebar content for iPad
|   |   +-- RouteDestination.swift           # @ViewBuilder routing Route → View
|   |   +-- DeepLinkHandler.swift            # .onOpenURL parser
|   +-- Info.plist
|
+-- Packages/
    +-- SolennixCore/
    |   +-- Package.swift
    |   +-- Sources/SolennixCore/
    |       +-- Models/
    |       |   +-- User.swift
    |       |   +-- Client.swift
    |       |   +-- Event.swift
    |       |   +-- Product.swift
    |       |   +-- InventoryItem.swift
    |       |   +-- EventProduct.swift
    |       |   +-- EventExtra.swift
    |       |   +-- EventEquipment.swift
    |       |   +-- EventSupply.swift
    |       |   +-- ProductIngredient.swift
    |       |   +-- Payment.swift
    |       |   +-- EquipmentConflict.swift
    |       |   +-- SupplySuggestion.swift
    |       |   +-- EquipmentSuggestion.swift
    |       +-- Extensions/
    |       |   +-- Date+Formatting.swift
    |       |   +-- String+Validation.swift
    |       |   +-- Double+Currency.swift
    |       +-- Finance/
    |           +-- TaxCalculator.swift
    |
    +-- SolennixNetwork/
    |   +-- Package.swift
    |   +-- Sources/SolennixNetwork/
    |       +-- APIClient.swift
    |       +-- AuthManager.swift
    |       +-- Endpoint.swift
    |       +-- KeychainHelper.swift
    |       +-- NetworkMonitor.swift
    |       +-- APIError.swift
    |
    +-- SolennixDesign/
    |   +-- Package.swift
    |   +-- Sources/SolennixDesign/
    |       +-- Colors.swift
    |       +-- Typography.swift
    |       +-- Spacing.swift
    |       +-- Shadows.swift
    |       +-- Gradient.swift
    |       +-- Components/
    |           +-- SolennixTextField.swift
    |           +-- PremiumButton.swift
    |           +-- Avatar.swift
    |           +-- EmptyStateView.swift
    |           +-- StatusBadge.swift
    |           +-- ConfirmDialog.swift
    |           +-- ToastOverlay.swift
    |           +-- SkeletonView.swift
    |
    +-- SolennixFeatures/
        +-- Package.swift
        +-- Sources/SolennixFeatures/
            +-- Auth/
                +-- Views/
                |   +-- LoginView.swift
                |   +-- RegisterView.swift
                |   +-- ForgotPasswordView.swift
                |   +-- ResetPasswordView.swift
                |   +-- AppleSignInButton.swift
                +-- ViewModels/
                    +-- AuthViewModel.swift
```

**Total: ~42 Swift files** (4 Package.swift + 14 models + 3 extensions + 1 finance + 6 network + 5 design tokens + 8 components + 5 auth views + 1 auth VM + 7 navigation/app = ~54 if counting Package.swift separately, but ~42 source files).

---

## 2. Package.swift Contents

### SolennixCore/Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixCore", targets: ["SolennixCore"])
    ],
    targets: [
        .target(name: "SolennixCore")
    ]
)
```

No external dependencies. Pure Swift models + extensions.

### SolennixNetwork/Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixNetwork",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixNetwork", targets: ["SolennixNetwork"])
    ],
    dependencies: [
        .package(path: "../SolennixCore")
    ],
    targets: [
        .target(name: "SolennixNetwork", dependencies: ["SolennixCore"])
    ]
)
```

Depends on SolennixCore for model types used in response decoding.

### SolennixDesign/Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixDesign",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixDesign", targets: ["SolennixDesign"])
    ],
    targets: [
        .target(name: "SolennixDesign")
    ]
)
```

No dependencies. Pure SwiftUI design tokens and components.

### SolennixFeatures/Package.swift

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolennixFeatures",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SolennixFeatures", targets: ["SolennixFeatures"])
    ],
    dependencies: [
        .package(path: "../SolennixCore"),
        .package(path: "../SolennixNetwork"),
        .package(path: "../SolennixDesign")
    ],
    targets: [
        .target(name: "SolennixFeatures",
                dependencies: ["SolennixCore", "SolennixNetwork", "SolennixDesign"])
    ]
)
```

### Dependency graph

```
SolennixCore          (no deps)
SolennixDesign        (no deps)
SolennixNetwork  -->  SolennixCore
SolennixFeatures -->  SolennixCore, SolennixNetwork, SolennixDesign
Solennix (app)   -->  all four packages
```

---

## 3. APIClient Actor Design

### Core actor

```swift
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private var authManager: AuthManager

    init(baseURL: URL = URL(string: "https://api.solennix.com")!,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.authManager = AuthManager()
    }
}
```

### Method signatures

```swift
extension APIClient {
    /// Generic request — all public methods funnel through here
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T

    /// Convenience typed wrappers
    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func post<T: Decodable>(_ endpoint: Endpoint, body: Encodable) async throws -> T
    func put<T: Decodable>(_ endpoint: Endpoint, body: Encodable) async throws -> T
    func delete(_ endpoint: Endpoint) async throws

    /// Multipart upload (photos)
    func upload<T: Decodable>(_ endpoint: Endpoint, data: Data, mimeType: String) async throws -> T
}
```

### Token refresh flow

The actor guarantees serial access, so no two callers can race on refresh:

```swift
private var isRefreshing = false
private var refreshContinuations: [CheckedContinuation<String, Error>] = []

private func validAccessToken() async throws -> String {
    // 1. If token is not expired, return it
    if let token = authManager.accessToken, !authManager.isTokenExpired(token) {
        return token
    }

    // 2. If already refreshing, suspend caller and resume when refresh completes
    if isRefreshing {
        return try await withCheckedThrowingContinuation { continuation in
            refreshContinuations.append(continuation)
        }
    }

    // 3. Perform refresh
    isRefreshing = true
    do {
        let newToken = try await performTokenRefresh()
        isRefreshing = false
        // Resume all waiting callers
        for continuation in refreshContinuations {
            continuation.resume(returning: newToken)
        }
        refreshContinuations.removeAll()
        return newToken
    } catch {
        isRefreshing = false
        for continuation in refreshContinuations {
            continuation.resume(throwing: error)
        }
        refreshContinuations.removeAll()
        throw error
    }
}

private func performTokenRefresh() async throws -> String {
    guard let refreshToken = authManager.refreshToken else {
        throw APIError.unauthorized
    }
    let body = ["refresh_token": refreshToken]
    let (data, response) = try await session.data(for: buildRequest(.authRefresh, body: body))

    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
        authManager.clearTokens()
        throw APIError.unauthorized
    }

    let tokens = try decoder.decode(TokenResponse.self, from: data)
    authManager.store(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
    return tokens.accessToken
}
```

### Error handling

```swift
enum APIError: LocalizedError {
    case unauthorized                      // 401 after refresh fails → trigger logout
    case forbidden                         // 403
    case notFound                          // 404
    case validationFailed([String: String]) // 422 with field errors
    case serverError(Int)                  // 500+
    case networkUnavailable                // No connectivity (via NetworkMonitor)
    case decodingFailed(Error)             // JSON parse failure
    case unknown(Error)
}
```

The `request` method maps HTTP status codes to `APIError` cases. On 401, it attempts one refresh cycle via `validAccessToken()`. If refresh itself returns 401, it throws `.unauthorized` which the AuthViewModel catches to trigger logout.

### Endpoint enum (pattern, not full list)

```swift
enum Endpoint {
    case authLogin
    case authRegister
    case authRefresh
    case authForgotPassword
    case authResetPassword

    case clients
    case client(id: String)
    case events
    case event(id: String)
    // ... 50+ total routes

    var path: String { /* switch self { ... } */ }
    var method: HTTPMethod { /* GET/POST/PUT/DELETE per route */ }
}
```

---

## 4. AuthManager Design

### Keychain storage

```swift
@Observable
final class AuthManager {
    private(set) var accessToken: String?
    private(set) var refreshToken: String?
    private(set) var currentUser: User?
    private(set) var authState: AuthState = .unknown

    enum AuthState {
        case unknown       // App just launched, checking keychain
        case authenticated // Valid tokens present
        case unauthenticated // No tokens or refresh failed
        case biometricLocked // Tokens exist but biometric gate not passed
    }

    private let keychain = KeychainHelper.standard

    // Keychain keys
    private enum Keys {
        static let accessToken = "com.solennix.accessToken"
        static let refreshToken = "com.solennix.refreshToken"
        static let userJSON = "com.solennix.currentUser"
        static let biometricEnabled = "com.solennix.biometricEnabled"
    }
}
```

### KeychainHelper

Thin wrapper around Security framework:

```swift
final class KeychainHelper {
    static let standard = KeychainHelper()

    func save(_ data: Data, for key: String) throws
    func read(for key: String) throws -> Data?
    func delete(for key: String) throws

    // Convenience for strings
    func saveString(_ value: String, for key: String) throws
    func readString(for key: String) throws -> String?
}
```

Uses `kSecClassGenericPassword` with `kSecAttrAccessible = kSecAttrAccessibleWhenUnlockedThisDeviceOnly` for token security.

### Biometric flow

```swift
extension AuthManager {
    var isBiometricAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        context.localizedReason = "Desbloquear Solennix"
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Inicia sesion con Face ID o Touch ID"
        )
    }
}
```

### State management on app launch

```swift
extension AuthManager {
    /// Called once from SolennixApp.init
    func restoreSession() async {
        // 1. Read tokens from Keychain
        guard let access = try? keychain.readString(for: Keys.accessToken),
              let refresh = try? keychain.readString(for: Keys.refreshToken) else {
            authState = .unauthenticated
            return
        }
        accessToken = access
        refreshToken = refresh

        // 2. If biometric is enabled, require gate
        let bioEnabled = (try? keychain.readString(for: Keys.biometricEnabled)) == "true"
        if bioEnabled && isBiometricAvailable {
            authState = .biometricLocked
            return
        }

        // 3. Otherwise, authenticated
        authState = .authenticated
        currentUser = try? loadCachedUser()
    }
}
```

### Token storage after login

```swift
func store(accessToken: String, refreshToken: String) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    try? keychain.saveString(accessToken, for: Keys.accessToken)
    try? keychain.saveString(refreshToken, for: Keys.refreshToken)
    authState = .authenticated
}

func clearTokens() {
    accessToken = nil
    refreshToken = nil
    currentUser = nil
    try? keychain.delete(for: Keys.accessToken)
    try? keychain.delete(for: Keys.refreshToken)
    try? keychain.delete(for: Keys.userJSON)
    authState = .unauthenticated
}
```

### Dual-token response handling

The backend returns two formats. AuthManager handles both:

```swift
struct AuthResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case user, token, tokens
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(User.self, forKey: .user)

        // Format 1: { token: "..." } (legacy single token)
        if let singleToken = try? container.decode(String.self, forKey: .token) {
            accessToken = singleToken
            refreshToken = singleToken
        }
        // Format 2: { tokens: { access_token, refresh_token } }
        else {
            let tokens = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .tokens)
            accessToken = try tokens.decode(String.self, forKey: .accessToken)
            refreshToken = try tokens.decode(String.self, forKey: .refreshToken)
        }
    }
}
```

---

## 5. Color System Design

### How Color(hex:) works

```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: Double
        switch hex.count {
        case 6: // #RRGGBB
            (r, g, b, a) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255,
                1
            )
        case 8: // #RRGGBBAA
            (r, g, b, a) = (
                Double((int >> 24) & 0xFF) / 255,
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0, 0, 0, 1)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
```

### Light/dark adaptive tokens via @Environment

Since we cannot use Asset Catalogs (no Xcode on Windows), every token is a **static computed property** that resolves at render time using a custom `ViewModifier` approach. However, `Color` extensions cannot access `@Environment`. The solution:

**Pattern: UIColor-based dynamic provider (works without Asset Catalog)**

```swift
extension Color {
    /// Creates an adaptive color using UIColor's trait-based init
    static func adaptive(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

// Then define UIColor(hex:) similarly to Color(hex:)
extension UIColor {
    convenience init(hex: String) { /* same scanner logic */ }
}
```

This is the key insight: `UIColor { traitCollection in ... }` is a **dynamic provider** that re-evaluates when dark mode toggles, just like Asset Catalog colors. Wrapping it in `Color(uiColor:)` gives SwiftUI a fully adaptive color with zero `@Environment` needed at the call site.

### Token definitions (Colors.swift)

```swift
extension Color {
    // MARK: - Brand
    static let solennixGold       = adaptive(light: "#C4A265", dark: "#C4A265")
    static let solennixGoldDark   = adaptive(light: "#B8965A", dark: "#D4B87A")
    static let solennixGoldLight  = adaptive(light: "#F5F0E8", dark: "#1B2A4A")

    // MARK: - Surfaces
    static let surfaceGrouped     = adaptive(light: "#F5F4F1", dark: "#0A0F1A")
    static let surface            = adaptive(light: "#FAF9F7", dark: "#1A2030")
    static let surfaceAlt         = adaptive(light: "#F0EFEC", dark: "#252A35")
    static let card               = adaptive(light: "#FFFFFF", dark: "#111722")

    // MARK: - Text
    static let primaryText        = adaptive(light: "#1A1A1A", dark: "#F5F0E8")
    static let secondaryText      = adaptive(light: "#7A7670", dark: "#9A9590")
    static let tertiaryText       = adaptive(light: "#A8A29E", dark: "#6B6560")

    // MARK: - Semantic
    static let success            = adaptive(light: "#2D6A4F", dark: "#52B788")
    static let warning            = adaptive(light: "#FF9500", dark: "#FF9F0A")
    static let error              = adaptive(light: "#FF3B30", dark: "#FF453A")
    static let info               = adaptive(light: "#007AFF", dark: "#0A84FF")

    // ... (all 40+ tokens from PRD section 9.1)
}
```

Usage in any view, no environment boilerplate needed:

```swift
Text("Hello").foregroundStyle(.primaryText)
RoundedRectangle().fill(.card)
```

---

## 6. Navigation Architecture

### Route enum

```swift
enum Route: Hashable {
    // Auth (used by deep links, not by NavigationStack path)
    case resetPassword(token: String?)

    // Events
    case eventDetail(id: String)
    case eventForm(id: String?, clientId: String?, date: Date?)
    case eventChecklist(id: String)

    // Clients
    case clientDetail(id: String)
    case clientForm(id: String?)

    // Products
    case productDetail(id: String)
    case productForm(id: String?)

    // Inventory
    case inventoryDetail(id: String)
    case inventoryForm(id: String?)

    // Settings
    case editProfile, changePassword, businessSettings
    case contractDefaults, pricing, about, privacy, terms
}
```

### Tab enum

```swift
enum Tab: String, CaseIterable {
    case home, calendar, clients, more
}
```

### ContentView (auth gate)

```swift
struct ContentView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        switch auth.authState {
        case .unknown:
            ProgressView()
        case .unauthenticated:
            LoginView()
        case .biometricLocked:
            BiometricGateView()
        case .authenticated:
            MainLayout()
        }
    }
}
```

### MainLayout (adaptive)

```swift
struct MainLayout: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .compact {
            CompactTabLayout()
        } else {
            SidebarSplitLayout()
        }
    }
}
```

### CompactTabLayout (iPhone)

```swift
struct CompactTabLayout: View {
    @State private var selectedTab: Tab = .home
    @State private var homePath = NavigationPath()
    @State private var calendarPath = NavigationPath()
    @State private var clientsPath = NavigationPath()
    @State private var morePath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                DashboardPlaceholder() // Phase 1: placeholder
                    .navigationDestination(for: Route.self, destination: routeView)
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            .tag(Tab.home)

            // ... calendar, clients, more tabs identical pattern
        }
        .overlay(alignment: .bottom) {
            NewEventFAB()
        }
    }

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        RouteDestination.view(for: route)
    }
}
```

Each tab owns its own `NavigationPath`, so back stacks are independent.

### SidebarSplitLayout (iPad)

```swift
struct SidebarSplitLayout: View {
    @State private var selectedSection: SidebarSection? = .dashboard
    @State private var detailPath = NavigationPath()

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedSection)
        } content: {
            if let section = selectedSection {
                sectionRootView(section)
            }
        } detail: {
            NavigationStack(path: $detailPath) {
                Text("Select an item")
                    .navigationDestination(for: Route.self, destination: RouteDestination.view)
            }
        }
    }
}
```

### RouteDestination (centralized routing)

```swift
enum RouteDestination {
    @ViewBuilder
    static func view(for route: Route) -> some View {
        switch route {
        case .eventDetail(let id):   Text("Event \(id)")   // Placeholder Phase 1
        case .clientDetail(let id):  Text("Client \(id)")  // Placeholder Phase 1
        case .resetPassword(let t):  ResetPasswordView(token: t)
        // ... all routes
        }
    }
}
```

### Deep linking

```swift
struct DeepLinkHandler {
    static func route(from url: URL) -> Route? {
        guard url.scheme == "solennix" else { return nil }
        switch url.host {
        case "reset-password":
            let token = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "token" })?.value
            return .resetPassword(token: token)
        default:
            return nil
        }
    }
}
```

Applied in `SolennixApp`:

```swift
.onOpenURL { url in
    if let route = DeepLinkHandler.route(from: url) {
        // Push to active navigation path
    }
}
```

---

## 7. Dependency Injection via @Environment

### Strategy: @Observable + custom EnvironmentKey

Phase 1 injects two shared objects: `AuthManager` and `APIClient`. Future phases add repositories.

```swift
// In SolennixApp.swift
@main
struct SolennixApp: App {
    @State private var authManager = AuthManager()
    @State private var apiClient = APIClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(apiClient)
                .task {
                    await authManager.restoreSession()
                }
        }
    }
}
```

### Consuming in views

```swift
struct LoginView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(APIClient.self) private var api

    // ...
}
```

This works because `AuthManager` and `APIClient` conform to `@Observable` (or in APIClient's case, are injected as an actor reference). The `@Environment(Type.self)` syntax is the iOS 17+ Observation framework approach -- no `EnvironmentKey` boilerplate needed for `@Observable` classes.

**Note on APIClient as actor:** Since `actor` cannot conform to `@Observable`, APIClient is injected via a custom `EnvironmentKey`:

```swift
private struct APIClientKey: EnvironmentKey {
    static let defaultValue = APIClient()
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// Injection
.environment(\.apiClient, apiClient)

// Consumption
@Environment(\.apiClient) private var api
```

### Preview support

```swift
#Preview {
    LoginView()
        .environment(AuthManager.preview) // static factory with mock state
        .environment(\.apiClient, .preview)
}
```

### How packages wire together

The app target (`Solennix/`) is the composition root. It creates the `AuthManager` and `APIClient` instances and injects them via `.environment()`. Feature views in `SolennixFeatures` consume them via `@Environment` -- they never create instances themselves. This means:

- **SolennixCore** knows nothing about networking or UI
- **SolennixNetwork** knows models (via SolennixCore) but nothing about UI
- **SolennixDesign** knows nothing about models or networking
- **SolennixFeatures** consumes all three but does not own any shared state
- **Solennix (app)** owns the object graph and injects into the SwiftUI environment
