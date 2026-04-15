import UIKit
import GoogleSignIn

import UserNotifications
import BackgroundTasks
import SolennixFeatures

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // MUST run synchronously before launch completes — iOS aborts the app
        // with NSInternalInconsistencyException if any BGTaskScheduler handler
        // is registered after didFinishLaunchingWithOptions returns.
        BackgroundTaskManager.registerLaunchHandler()

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
