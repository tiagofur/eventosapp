import SwiftUI
import SolennixNetwork
import SolennixDesign

// MARK: - APIClient Environment Key

/// Custom `EnvironmentKey` for injecting the `APIClient` actor.
///
/// Since `actor` types cannot conform to `@Observable`, we use a
/// traditional `EnvironmentKey` + `EnvironmentValues` extension
/// rather than the `@Environment(Type.self)` pattern.
private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = APIClient()
}

extension EnvironmentValues {
    /// The shared API client for making network requests.
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// MARK: - App Entry Point

@main
struct SolennixApp: App {

    @State private var authManager: AuthManager
    @State private var toastManager = ToastManager()
    @State private var networkMonitor = NetworkMonitor()

    @AppStorage("appearance") private var appearance: String = "system"

    /// The shared API client instance.
    private let apiClient: APIClient

    // MARK: - Init

    init() {
        let keychain = KeychainHelper.standard
        let baseURL = URL(string: "https://api.solennix.com/api")!
        let client = APIClient(baseURL: baseURL, keychainHelper: keychain)
        let auth = AuthManager(keychain: keychain)
        auth.apiClient = client

        // Use Task to set auth manager on the actor after init
        let authRef = auth
        Task { await client.setAuthManager(authRef) }

        _authManager = State(initialValue: auth)
        self.apiClient = client
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(\.apiClient, apiClient)
                .environment(toastManager)
                .environment(networkMonitor)
                .preferredColorScheme(resolvedColorScheme)
                .task {
                    await authManager.checkAuth()
                }
        }
    }

    // MARK: - Appearance

    /// Resolves the user's appearance preference to a SwiftUI `ColorScheme`.
    private var resolvedColorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil // system default
        }
    }
}
