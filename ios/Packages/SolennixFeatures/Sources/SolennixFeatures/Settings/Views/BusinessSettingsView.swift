import SwiftUI
import PhotosUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Business Settings View

public struct BusinessSettingsView: View {

    @State private var viewModel: BusinessSettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: BusinessSettingsViewModel(apiClient: apiClient))
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                formContent
            }
        }
        .navigationTitle("Ajustes del Negocio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }
        }
        .onChange(of: viewModel.selectedPhoto) { _, newValue in
            if newValue != nil {
                Task { await viewModel.handleLogoSelection() }
            }
        }
        .task { await viewModel.loadUser() }
    }

    // MARK: - Form Content

    private var formContent: some View {
        Form {
            // Logo section
            Section {
                HStack {
                    Spacer()

                    VStack(spacing: Spacing.md) {
                        // Logo preview
                        if let logoUrl = viewModel.logoUrl, let url = APIClient.resolveURL(logoUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                                case .failure:
                                    logoPlaceholder
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                @unknown default:
                                    logoPlaceholder
                                }
                            }
                        } else {
                            logoPlaceholder
                        }

                        // Upload button
                        PhotosPicker(
                            selection: $viewModel.selectedPhoto,
                            matching: .images
                        ) {
                            HStack {
                                if viewModel.isUploadingLogo {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                } else {
                                    Image(systemName: "photo")
                                    Text(viewModel.logoUrl != nil ? "Cambiar Logo" : "Subir Logo")
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                        }
                        .disabled(viewModel.isUploadingLogo)
                    }

                    Spacer()
                }
                .padding(.vertical, Spacing.md)
            } header: {
                Text("Logo")
            } footer: {
                Text("Tu logo aparecera en los contratos y cotizaciones que generes.")
            }

            // Business name + Brand color section (2-col on iPad)
            Section {
                AdaptiveFormRow {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        TextField("Nombre del negocio", text: $viewModel.businessName)
                        Toggle("Mostrar en PDFs", isOn: $viewModel.showBusinessNameInPdf)
                        Text("Si activas esta opcion, tu nombre comercial aparecera en los documentos en lugar de tu nombre personal.")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
                    }
                } right: {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ColorPicker("Color de marca", selection: $viewModel.brandColor)
                        Text("Este color se usara como acento en los documentos PDF que generes.")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textTertiary)
                    }
                }
            } header: {
                Text("Negocio e Identidad Visual")
            }

            // Error message
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(SolennixColors.error)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(SolennixColors.surfaceGrouped)
    }

    // MARK: - Logo Placeholder

    private var logoPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(SolennixColors.surface)
                .frame(width: 100, height: 100)

            Image(systemName: "building.2")
                .font(.system(size: 32))
                .foregroundStyle(SolennixColors.textTertiary)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task {
                let success = await viewModel.saveBusinessSettings()
                if success {
                    dismiss()
                }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView()
            } else {
                Text("Guardar")
                    .fontWeight(.semibold)
            }
        }
        .disabled(viewModel.isSaving)
    }
}

// MARK: - Preview

#Preview("Business Settings") {
    NavigationStack {
        BusinessSettingsView(apiClient: APIClient())
    }
}
