import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Contract Defaults View

public struct ContractDefaultsView: View {

    @State private var viewModel: BusinessSettingsViewModel
    @Environment(\.dismiss) private var dismiss

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
        .navigationTitle("Valores del Contrato")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }
        }
        .task { await viewModel.loadUser() }
    }

    // MARK: - Form Content

    private var formContent: some View {
        Form {
            // Deposit section
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Porcentaje de anticipo")
                        Spacer()
                        Text("\(Int(viewModel.depositPercent))%")
                            .font(.headline)
                            .foregroundStyle(SolennixColors.primary)
                    }

                    Slider(value: $viewModel.depositPercent, in: 0...100, step: 5) {
                        Text("Anticipo")
                    }
                }
            } header: {
                Text("Anticipo")
            } footer: {
                Text("Porcentaje del total que solicitas como anticipo al confirmar un evento.")
            }

            // Cancellation section
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Dias de anticipacion")
                        Spacer()
                        Text("\(Int(viewModel.cancellationDays)) dias")
                            .font(.headline)
                            .foregroundStyle(SolennixColors.primary)
                    }

                    Slider(value: $viewModel.cancellationDays, in: 1...30, step: 1) {
                        Text("Dias")
                    }
                }
            } header: {
                Text("Cancelacion")
            } footer: {
                Text("Numero minimo de dias antes del evento para permitir cancelacion con reembolso.")
            }

            // Refund section
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Porcentaje de reembolso")
                        Spacer()
                        Text("\(Int(viewModel.refundPercent))%")
                            .font(.headline)
                            .foregroundStyle(SolennixColors.primary)
                    }

                    Slider(value: $viewModel.refundPercent, in: 0...100, step: 5) {
                        Text("Reembolso")
                    }
                }
            } header: {
                Text("Reembolso")
            } footer: {
                Text("Porcentaje del anticipo que devuelves en caso de cancelacion dentro del plazo permitido.")
            }

            // Contract template section
            Section {
                TextEditor(text: $viewModel.contractTemplate)
                    .frame(minHeight: 200)
            } header: {
                Text("Plantilla del Contrato")
            } footer: {
                Text("Puedes personalizar el texto adicional que aparecera en tus contratos. Usa {{nombre_cliente}}, {{fecha_evento}}, {{total}} para variables.")
            }

            // Preview section
            Section {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Vista previa de terminos")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        previewRow(label: "Anticipo requerido", value: "\(Int(viewModel.depositPercent))% del total")
                        previewRow(label: "Cancelacion sin penalizacion", value: "\(Int(viewModel.cancellationDays)) dias antes")
                        previewRow(label: "Reembolso por cancelacion", value: "\(Int(viewModel.refundPercent))% del anticipo")
                    }
                    .padding(Spacing.md)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                }
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
    }

    // MARK: - Preview Row

    private func previewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(SolennixColors.textSecondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(SolennixColors.text)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task {
                let success = await viewModel.saveContractDefaults()
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

#Preview("Contract Defaults") {
    NavigationStack {
        ContractDefaultsView(apiClient: APIClient())
    }
}
