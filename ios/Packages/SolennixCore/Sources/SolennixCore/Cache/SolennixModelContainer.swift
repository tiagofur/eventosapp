import Foundation
import SwiftData

// MARK: - SolennixModelContainer

/// Factory for creating the app's SwiftData `ModelContainer` with all cached model types.
public enum SolennixModelContainer {

    /// Creates a configured `ModelContainer` for offline caching.
    ///
    /// Tries persistent storage first, falls back to in-memory. If BOTH fail,
    /// throws so the caller can report the error (Sentry, analytics, alert)
    /// before deciding how to terminate — avoids a silent `fatalError`.
    public static func create() throws -> ModelContainer {
        let schema = Schema([
            CachedClient.self,
            CachedEvent.self,
            CachedProduct.self,
            CachedInventoryItem.self,
            CachedPayment.self
        ])

        let configuration = ModelConfiguration(
            "SolennixCache",
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            print("[SolennixModelContainer] Error al crear el contenedor persistente: \(error). Usando almacenamiento en memoria.")
            let fallback = ModelConfiguration(
                "SolennixCacheFallback",
                schema: schema,
                isStoredInMemoryOnly: true
            )
            return try ModelContainer(for: schema, configurations: [fallback])
        }
    }
}
