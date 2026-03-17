import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Client List View

public struct ClientListView: View {

    @State private var viewModel: ClientListViewModel
    @Environment(\.openURL) private var openURL

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: ClientListViewModel(apiClient: apiClient))
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            fabButton
        }
        .navigationTitle("Clientes")
        .searchable(text: $viewModel.searchText, prompt: "Buscar clientes...")
        .refreshable { await viewModel.loadClients() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                sortMenu
            }
        }
        .confirmationDialog(
            "Eliminar cliente",
            isPresented: $viewModel.showDeleteConfirm,
            presenting: viewModel.deleteTarget
        ) { client in
            Button("Eliminar", role: .destructive) {
                Task { await viewModel.deleteClient(client) }
            }
            Button("Cancelar", role: .cancel) {}
        } message: { client in
            Text("Estas seguro de que quieres eliminar a \(client.name)? Esta accion no se puede deshacer.")
        }
        .task { await viewModel.loadClients() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.clients.isEmpty {
            skeletonList
        } else if viewModel.filteredClients.isEmpty && !viewModel.isLoading {
            if viewModel.searchText.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "Sin clientes",
                    message: "Agrega tu primer cliente para empezar",
                    actionTitle: "Agregar Cliente"
                ) {
                    // FAB handles navigation; empty state CTA is visual only
                }
            } else {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Sin resultados",
                    message: "No se encontraron clientes que coincidan con \"\(viewModel.searchText)\""
                )
            }
        } else {
            clientList
        }
    }

    // MARK: - Client List

    private var clientList: some View {
        List(viewModel.filteredClients) { client in
            NavigationLink(value: Route.clientDetail(id: client.id)) {
                clientRow(client)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    viewModel.deleteTarget = client
                    viewModel.showDeleteConfirm = true
                } label: {
                    Label("Eliminar", systemImage: "trash")
                }

                NavigationLink(value: Route.clientForm(id: client.id)) {
                    Label("Editar", systemImage: "pencil")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                if let email = client.email, !email.isEmpty,
                   let url = URL(string: "mailto:\(email)") {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Email", systemImage: "envelope.fill")
                    }
                    .tint(.blue)
                }

                if !client.phone.isEmpty,
                   let url = URL(string: "tel:\(client.phone)") {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Llamar", systemImage: "phone.fill")
                    }
                    .tint(.green)
                }
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Client Row

    private func clientRow(_ client: Client) -> some View {
        HStack(spacing: Spacing.md) {
            Avatar(name: client.name, photoURL: client.photoUrl, size: 40)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(client.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(SolennixColors.text)

                if let city = client.city, !city.isEmpty {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                            .foregroundStyle(SolennixColors.textTertiary)
                        Text(city)
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }
                }

                HStack(spacing: Spacing.sm) {
                    if !client.phone.isEmpty {
                        Text(client.phone)
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
                    }
                    if let email = client.email, !email.isEmpty {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, Spacing.xs)
    }

    // MARK: - Skeleton Loading

    private var skeletonList: some View {
        List(0..<5, id: \.self) { _ in
            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(SolennixColors.surfaceAlt)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(SolennixColors.surfaceAlt)
                        .frame(width: 140, height: 14)

                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(SolennixColors.surfaceAlt)
                        .frame(width: 100, height: 10)
                }

                Spacer()
            }
            .padding(.vertical, Spacing.xs)
        }
        .listStyle(.plain)
        .redacted(reason: .placeholder)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            Picker("Ordenar por", selection: $viewModel.sortKey) {
                ForEach(ClientSortKey.allCases, id: \.self) { key in
                    Text(key.label).tag(key)
                }
            }

            Divider()

            Button {
                viewModel.sortAscending.toggle()
            } label: {
                Label(
                    viewModel.sortAscending ? "Ascendente" : "Descendente",
                    systemImage: viewModel.sortAscending ? "arrow.up" : "arrow.down"
                )
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.body)
                .foregroundStyle(SolennixColors.primary)
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        NavigationLink(value: Route.clientForm()) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(SolennixGradient.premium)
                .clipShape(Circle())
                .shadowFab()
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Preview

#Preview("Client List") {
    NavigationStack {
        ClientListView(apiClient: APIClient())
    }
}
