import Foundation
// import Sentry 

/// A wrapper around Sentry SDK to mimic the behavior of React Native app.
/// In a real environment, you would add the Sentry SPM package and uncomment the Sentry code.
public struct SentryHelper {
    
    public static var isEnabled: Bool = false
    
    public static func configure() {
        // let dsn = ProcessInfo.processInfo.environment["SENTRY_DSN"] ?? ""
        // guard !dsn.isEmpty else { return }
        
        // SentrySDK.start { options in
        //     options.dsn = dsn
        //     options.debug = false // Set to true for debugging
        //     options.tracesSampleRate = 1.0 // Adjust in production to 0.2
        //     options.environment = "development"
        // }
        // isEnabled = true
    }
    
    public static func capture(error: Error, context: String? = nil) {
        guard isEnabled else {
            print("[\(context ?? "Error")]: \(error)")
            return
        }
        
        // if let context = context {
        //     SentrySDK.configureScope { scope in
        //         scope.setTag(value: context, key: "context")
        //     }
        // }
        // SentrySDK.capture(error: error)
    }
    
    public static func capture(message: String) {
        guard isEnabled else {
            print("[Warning]: \(message)")
            return
        }
        // SentrySDK.capture(message: message)
    }
    
    public static func setUser(id: String, email: String? = nil, name: String? = nil) {
        guard isEnabled else { return }
        
        // let user = User()
        // user.userId = id
        // user.email = email
        // user.name = name
        // SentrySDK.setUser(user)
    }
    
    public static func clearUser() {
        guard isEnabled else { return }
        // SentrySDK.setUser(nil)
    }
}

