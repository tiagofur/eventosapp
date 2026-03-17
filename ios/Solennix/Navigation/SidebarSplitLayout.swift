import SwiftUI
import SolennixDesign

// MARK: - Sidebar Split Layout (iPad / Mac)

/// The main navigation layout for regular (iPad/Mac) horizontal size class.
///
/// Uses `NavigationSplitView` with a sidebar listing all sections,
/// a content column for section-specific lists, and a detail column
/// for item-level views.
struct SidebarSplitLayout: View {

    @State private var selectedSection: SidebarSection? = .dashboard
    @State private var detailPath = NavigationPath()

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle("Solennix")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            detailPath.append(Route.eventForm())
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Nuevo Evento")
                    }
                }
        } content: {
            if let section = selectedSection {
                sectionListView(for: section)
            } else {
                ContentUnavailableView(
                    "Selecciona una seccion",
                    systemImage: "sidebar.left",
                    description: Text("Elige una seccion del menu lateral.")
                )
            }
        } detail: {
            NavigationStack(path: $detailPath) {
                ContentUnavailableView(
                    "Selecciona un elemento",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Elige un elemento de la lista para ver los detalles.")
                )
                .navigationDestination(for: Route.self) { route in
                    RouteDestination(route: route)
                }
            }
        }
    }

    // MARK: - Sidebar Content

    @ViewBuilder
    private var sidebarContent: some View {
        List(selection: $selectedSection) {
            // Main sections
            Section("Principal") {
                ForEach(SidebarSection.mainSections, id: \.self) { section in
                    Label(section.title, systemImage: section.iconName)
                        .tag(section)
                }
            }

            // Utility sections
            Section("Herramientas") {
                ForEach(SidebarSection.utilitySections, id: \.self) { section in
                    Label(section.title, systemImage: section.iconName)
                        .tag(section)
                }
            }

            // Settings at the bottom
            Section {
                Label(SidebarSection.settings.title, systemImage: SidebarSection.settings.iconName)
                    .tag(SidebarSection.settings)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Section List Views

    @ViewBuilder
    private func sectionListView(for section: SidebarSection) -> some View {
        switch section {
        case .dashboard:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .calendar:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .clients:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .products:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .inventory:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .search:
            SidebarSectionPlaceholder(section: section)
                .navigationTitle(section.title)
        case .settings:
            settingsListView
                .navigationTitle(section.title)
        }
    }

    // MARK: - Settings List

    @ViewBuilder
    private var settingsListView: some View {
        List {
            Section("Cuenta") {
                NavigationLink(value: Route.editProfile) {
                    Label("Editar Perfil", systemImage: "person.circle")
                }
                NavigationLink(value: Route.changePassword) {
                    Label("Cambiar Contrasena", systemImage: "lock.rotation")
                }
            }

            Section("Negocio") {
                NavigationLink(value: Route.businessSettings) {
                    Label("Ajustes del Negocio", systemImage: "building.2")
                }
                NavigationLink(value: Route.contractDefaults) {
                    Label("Valores del Contrato", systemImage: "doc.text")
                }
                NavigationLink(value: Route.pricing) {
                    Label("Precios y Planes", systemImage: "creditcard")
                }
            }

            Section("Legal") {
                NavigationLink(value: Route.about) {
                    Label("Acerca de", systemImage: "info.circle")
                }
                NavigationLink(value: Route.privacy) {
                    Label("Privacidad", systemImage: "hand.raised")
                }
                NavigationLink(value: Route.terms) {
                    Label("Terminos", systemImage: "doc.plaintext")
                }
            }
        }
    }
}

// MARK: - Sidebar Section Placeholder

/// Placeholder list view for a sidebar section that hasn't been implemented yet.
private struct SidebarSectionPlaceholder: View {

    let section: SidebarSection

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: section.iconName)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(section.title)
                .font(.title2)
                .fontWeight(.semibold)

            Text("Disponible en Fase 2")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SidebarSection Grouping

extension SidebarSection {

    /// Main navigation sections (displayed first in the sidebar).
    static let mainSections: [SidebarSection] = [
        .dashboard, .calendar, .clients, .products, .inventory
    ]

    /// Utility sections (search, etc.).
    static let utilitySections: [SidebarSection] = [
        .search
    ]
}

// MARK: - Preview

#Preview {
    SidebarSplitLayout()
}
