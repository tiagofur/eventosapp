import Foundation
import Observation
import SolennixCore
import SolennixNetwork

// MARK: - Sort Key

public enum ClientSortKey: String, CaseIterable {
    case updatedAt
    case name
    case totalEvents
    case totalSpent
    case createdAt

    public var label: String {
        switch self {
        case .updatedAt:   return "Ultima actualizacion"
        case .name:        return "Nombre"
        case .totalEvents: return "Total eventos"
        case .totalSpent:  return "Total gastado"
        case .createdAt:   return "Fecha de creacion"
        }
    }
}

// MARK: - Client List View Model

@Observable
public final class ClientListViewModel {

    // MARK: - Properties

    public var clients: [Client] = []
    public var filteredClients: [Client] = []
    public var searchText: String = "" {
        didSet { applyFilters() }
    }
    public var isLoading: Bool = false
    public var sortKey: ClientSortKey = .updatedAt {
        didSet { applyFilters() }
    }
    public var sortAscending: Bool = false {
        didSet { applyFilters() }
    }
    public var deleteTarget: Client?
    public var showDeleteConfirm: Bool = false
    public var errorMessage: String?

    // MARK: - Dependencies

    private let apiClient: APIClient

    // MARK: - Init

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Computed

    /// Checks whether the user has reached the plan client limit (basic = 15).
    public var isAtLimit: Bool {
        clients.count >= 15
    }

    // MARK: - Data Loading

    @MainActor
    public func loadClients() async {
        isLoading = true
        errorMessage = nil

        do {
            let result: [Client] = try await apiClient.get(Endpoint.clients)
            clients = result
            applyFilters()
        } catch {
            errorMessage = mapError(error)
        }

        isLoading = false
    }

    // MARK: - Delete

    @MainActor
    public func deleteClient(_ client: Client) async {
        do {
            try await apiClient.delete(Endpoint.client(client.id))
            clients.removeAll { $0.id == client.id }
            applyFilters()
        } catch {
            errorMessage = mapError(error)
        }
    }

    // MARK: - Filtering & Sorting

    public func applyFilters() {
        var result = clients

        // Filter by search text
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { client in
                client.name.lowercased().contains(query)
                || client.phone.lowercased().contains(query)
                || (client.email?.lowercased().contains(query) ?? false)
                || (client.city?.lowercased().contains(query) ?? false)
            }
        }

        // Sort
        result.sort { a, b in
            let ascending: Bool
            switch sortKey {
            case .updatedAt:
                ascending = a.updatedAt < b.updatedAt
            case .name:
                ascending = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .totalEvents:
                ascending = (a.totalEvents ?? 0) < (b.totalEvents ?? 0)
            case .totalSpent:
                ascending = (a.totalSpent ?? 0) < (b.totalSpent ?? 0)
            case .createdAt:
                ascending = a.createdAt < b.createdAt
            }
            return sortAscending ? ascending : !ascending
        }

        filteredClients = result
    }

    // MARK: - Error Mapping

    private func mapError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.errorDescription ?? "Ocurrio un error inesperado."
        }
        return "Ocurrio un error inesperado. Intenta de nuevo."
    }
}
