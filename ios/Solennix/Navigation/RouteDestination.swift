import SwiftUI

// MARK: - Route Destination

/// Resolves a `Route` to its destination view.
///
/// In Phase 1, most routes render placeholder views. Real views will be
/// substituted as each feature module is implemented.
struct RouteDestination: View {

    let route: Route

    var body: some View {
        switch route {
        // Events
        case .eventDetail(let id):
            PlaceholderView(title: "Detalle del Evento", id: id, phase: 2)
        case .eventForm(let id, let clientId, let date):
            PlaceholderView(
                title: "Formulario de Evento",
                id: id,
                subtitle: [
                    clientId.map { "Cliente: \($0)" },
                    date.map { "Fecha: \($0.formatted(date: .abbreviated, time: .omitted))" }
                ].compactMap { $0 }.joined(separator: " | "),
                phase: 2
            )
        case .eventChecklist(let id):
            PlaceholderView(title: "Checklist del Evento", id: id, phase: 2)

        // Clients
        case .clientDetail(let id):
            PlaceholderView(title: "Detalle del Cliente", id: id, phase: 2)
        case .clientForm(let id):
            PlaceholderView(title: "Formulario de Cliente", id: id, phase: 2)

        // Products
        case .productDetail(let id):
            PlaceholderView(title: "Detalle del Producto", id: id, phase: 3)
        case .productForm(let id):
            PlaceholderView(title: "Formulario de Producto", id: id, phase: 3)

        // Inventory
        case .inventoryDetail(let id):
            PlaceholderView(title: "Detalle de Inventario", id: id, phase: 3)
        case .inventoryForm(let id):
            PlaceholderView(title: "Formulario de Inventario", id: id, phase: 3)

        // Settings
        case .editProfile:
            PlaceholderView(title: "Editar Perfil", phase: 2)
        case .changePassword:
            PlaceholderView(title: "Cambiar Contrasena", phase: 2)
        case .businessSettings:
            PlaceholderView(title: "Ajustes del Negocio", phase: 2)
        case .contractDefaults:
            PlaceholderView(title: "Valores del Contrato", phase: 2)
        case .pricing:
            PlaceholderView(title: "Precios y Planes", phase: 4)
        case .about:
            PlaceholderView(title: "Acerca de", phase: 2)
        case .privacy:
            PlaceholderView(title: "Politica de Privacidad", phase: 2)
        case .terms:
            PlaceholderView(title: "Terminos de Servicio", phase: 2)
        }
    }
}

// MARK: - Placeholder View

/// A temporary view displayed for screens not yet implemented.
/// Shows the screen name, an optional ID, and which phase will deliver it.
struct PlaceholderView: View {

    let title: String
    var id: String? = nil
    var subtitle: String? = nil
    let phase: Int

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            if let id {
                Text("ID: \(id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospaced()
            }

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Disponible en Fase \(phase)")
                .font(.footnote)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
    }
}

// MARK: - Previews

#Preview("Event Detail Placeholder") {
    NavigationStack {
        RouteDestination(route: .eventDetail(id: "evt-123"))
    }
}

#Preview("Event Form Placeholder") {
    NavigationStack {
        RouteDestination(route: .eventForm(clientId: "cli-456", date: .now))
    }
}
