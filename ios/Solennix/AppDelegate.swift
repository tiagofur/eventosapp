import UIKit
import Sentry
import GoogleSignIn

import UserNotifications
import SolennixFeatures

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SentrySDK.start { options in
            options.dsn = "https://0db5eb9a6affdbf82694261a579369d3@o4511177041903616.ingest.us.sentry.io/4511177044459521"

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 1.0 // We recommend adjusting this value in production.
                $0.lifecycle = .trace
            }

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
            
            // Enable experimental logging features
            options.experimental.enableLogs = true
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This app uses Sentry! :)")

        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        NotificationManager.shared.configureCategories()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor in
            NotificationManager.shared.registerDeviceToken(deviceToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        SentryHelper.capture(error: error, context: "push_registration_failed")
    }

    // MARK: - URL Handling (Google Sign-In callback)

    /// Handles OAuth callback URLs for Google Sign-In.
    ///
    /// Modern versions of the Google SDK use `ASWebAuthenticationSession`,
    /// which delivers the callback automatically — but this handler is still
    /// required as a safety net for code paths that fall back to Safari or
    /// custom URL schemes. Leaving it out can break the flow in edge cases.
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
