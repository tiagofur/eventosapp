import SwiftUI
import SolennixDesign

// MARK: - Compact Tab Layout (iPhone)

/// The main tab-based layout for compact (iPhone) horizontal size class.
///
/// Contains four tabs, each with its own `NavigationStack` and independent
/// navigation path. A floating action button (FAB) overlays the tab bar
/// for quick event creation.
struct CompactTabLayout: View {

    @State private var selectedTab: Tab = .home
    @State private var homePath = NavigationPath()
    @State private var calendarPath = NavigationPath()
    @State private var clientsPath = NavigationPath()
    @State private var morePath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Home Tab
                NavigationStack(path: $homePath) {
                    HomeRootView()
                        .navigationDestination(for: Route.self) { route in
                            RouteDestination(route: route)
                        }
                }
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.iconName)
                }
                .tag(Tab.home)

                // Calendar Tab
                NavigationStack(path: $calendarPath) {
                    CalendarRootView()
                        .navigationDestination(for: Route.self) { route in
                            RouteDestination(route: route)
                        }
                }
                .tabItem {
                    Label(Tab.calendar.title, systemImage: Tab.calendar.iconName)
                }
                .tag(Tab.calendar)

                // Clients Tab
                NavigationStack(path: $clientsPath) {
                    ClientsRootView()
                        .navigationDestination(for: Route.self) { route in
                            RouteDestination(route: route)
                        }
                }
                .tabItem {
                    Label(Tab.clients.title, systemImage: Tab.clients.iconName)
                }
                .tag(Tab.clients)

                // More Tab
                NavigationStack(path: $morePath) {
                    MoreRootView()
                        .navigationDestination(for: Route.self) { route in
                            RouteDestination(route: route)
                        }
                }
                .tabItem {
                    Label(Tab.more.title, systemImage: Tab.more.iconName)
                }
                .tag(Tab.more)
            }
            .tint(SolennixColors.tabBarActive)

            // FAB overlay
            NewEventFAB {
                selectedTab = .home
                homePath.append(Route.eventForm())
            }
            .padding(.bottom, 54) // Position above the tab bar
        }
    }
}

// MARK: - New Event FAB

/// Circular floating action button with premium gradient for creating new events.
private struct NewEventFAB: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(SolennixGradient.premium)
                    .frame(width: 56, height: 56)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(SolennixColors.textInverse)
            }
        }
        .shadowFab()
        .accessibilityLabel("Nuevo Evento")
    }
}

// MARK: - Tab Root Views (Phase 1 Placeholders)

/// Placeholder root view for the Home (Dashboard) tab.
private struct HomeRootView: View {
    var body: some View {
        PlaceholderView(title: "Dashboard", phase: 2)
            .navigationTitle("Inicio")
    }
}

/// Placeholder root view for the Calendar tab.
private struct CalendarRootView: View {
    var body: some View {
        PlaceholderView(title: "Calendario", phase: 2)
            .navigationTitle("Calendario")
    }
}

/// Placeholder root view for the Clients tab.
private struct ClientsRootView: View {
    var body: some View {
        PlaceholderView(title: "Clientes", phase: 2)
            .navigationTitle("Clientes")
    }
}

/// Placeholder root view for the More tab.
private struct MoreRootView: View {
    var body: some View {
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
        .navigationTitle("Mas")
    }
}

// MARK: - Preview

#Preview {
    CompactTabLayout()
}
