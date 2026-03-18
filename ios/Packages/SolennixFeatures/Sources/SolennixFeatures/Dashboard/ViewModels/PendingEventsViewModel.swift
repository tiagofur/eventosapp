import Foundation
import SolennixCore
import SolennixNetwork

@Observable
public final class PendingEventsViewModel {
    let apiClient: APIClient
    
    public var pendingEvents: [Event] = []
    public var isLoading: Bool = true
    public var isPresented: Bool = false
    public var updatingEventId: String? = nil
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    @MainActor
    public func loadPendingEvents() async {
        isLoading = true
        do {
            let allEvents = try await apiClient.getEvents()
            
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            
            let pastConfirmed = allEvents.filter { event in
                if event.status != .confirmed { return false }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let eventDate = formatter.date(from: String(event.eventDate.prefix(10))) else { return false }
                
                return eventDate < startOfToday
            }
            
            self.pendingEvents = pastConfirmed
            if !self.pendingEvents.isEmpty {
                self.isPresented = true
            }
        } catch {
            print("Error loading pending events: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    public func updateEventStatus(eventId: String, newStatus: EventStatus) async {
        updatingEventId = eventId
        do {
            var updateParams: [String: Any] = ["status": newStatus.rawValue]
            
            // To update just the status, we likely need to send the whole object or the API supports partial.
            // Assuming apiClient.updateEvent requires the full object, we find it.
            if var eventToUpdate = pendingEvents.first(where: { $0.id == eventId }) {
               eventToUpdate.status = newStatus
               _ = try await apiClient.updateEvent(eventId: eventId, event: eventToUpdate)
               
               pendingEvents.removeAll { $0.id == eventId }
               if pendingEvents.isEmpty {
                   isPresented = false
               }
            }
        } catch {
            print("Error updating event status: \(error)")
        }
        updatingEventId = nil
    }
}

