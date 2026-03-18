import Foundation
import StoreKit
import SwiftUI

public struct StoreReviewHelper {
    private static let eventsCountKey = "solennix_events_created_count"
    private static let lastReviewRequestKey = "solennix_last_review_request"
    
    /// Increments the event creation count and requests a review if conditions are met
    public static func recordEventCreated() {
        let currentCount = UserDefaults.standard.integer(forKey: eventsCountKey)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: eventsCountKey)
        
        // Request review after 3 events created
        if newCount == 3 {
            requestReview()
        } else if newCount > 3 && newCount % 10 == 0 {
            // Also request every 10 events after that, with a minimum time limit
            let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date ?? Date.distantPast
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
            
            // At least 30 days between requests
            if daysSinceLastRequest > 30 {
                requestReview()
            }
        }
    }
    
    public static func requestReview() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            
            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(Date(), forKey: lastReviewRequestKey)
        }
    }
}
