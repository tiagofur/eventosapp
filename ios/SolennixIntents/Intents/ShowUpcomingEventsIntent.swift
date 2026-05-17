import AppIntents
import SwiftUI

// MARK: - Show Upcoming Events Intent

struct ShowUpcomingEventsIntent: AppIntent {

    static var title: LocalizedStringResource = "Mostrar Proximos Eventos"
    static var description = IntentDescription("Muestra tus proximos eventos programados")

    static var openAppWhenRun: Bool = false

    nonisolated init() {}

    @Parameter(title: "Numero de eventos", default: 5)
    var count: Int

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard IntentSharedDataStore.hasProAccess else {
            return .result(
                dialog: "Plan Pro requerido para usar este atajo.",
                view: PlanRequiredSnippetView()
            )
        }

        let events = await fetchUpcomingEvents(limit: count)

        if events.isEmpty {
            return .result(
                dialog: "No tienes eventos proximos programados.",
                view: EmptyEventsView()
            )
        }

        _ = events.map { "\($0.date): \($0.clientName) - \($0.eventType)" }.joined(separator: "\n")

        return .result(
            dialog: "Tienes \(events.count) eventos proximos.",
            view: UpcomingEventsSnippetView(events: events)
        )
    }

    private func fetchUpcomingEvents(limit: Int) async -> [EventSummary] {
        let upcoming = IntentSharedDataStore.loadUpcomingEvents()
        let safeLimit = max(1, min(limit, 10))

        return upcoming
            .sorted { $0.eventDate < $1.eventDate }
            .prefix(safeLimit)
            .map {
                EventSummary(
                    id: $0.id,
                    clientName: $0.clientName,
                    eventType: $0.eventType,
                    date: $0.formattedDate,
                    time: $0.startTime ?? "all day"
                )
            }
    }
}

// MARK: - Event Summary Model

struct EventSummary: Identifiable {
    let id: String
    let clientName: String
    let eventType: String
    let date: String
    let time: String
}

// MARK: - Snippet Views

struct UpcomingEventsSnippetView: View {
    let events: [EventSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(events) { event in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.date)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)

                        Text(event.clientName)
                            .font(.headline)

                        HStack(spacing: 4) {
                            Text(event.eventType)
                            Text("•")
                            Text(event.time)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)

                if event.id != events.last?.id {
                    Divider()
                }
            }
        }
        .padding()
    }
}

struct EmptyEventsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Sin eventos proximos")
                .font(.headline)
        }
        .padding()
    }
}
