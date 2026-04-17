import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Staff Form View

public struct StaffFormView: View {

    let staffId: String?

    @State private var viewModel: StaffFormViewModel
    @Environment(\.dismiss) private var dismiss

    public init(staffId: String? = nil, apiClient: APIClient) {
        self.staffId = staffId
        _viewModel = State(initialValue: StaffFormViewModel(apiClient: apiClient))
    }

    public var body: some View {
        Form {
            infoSection
            contactSection
            notificationSection
            notesSection
        }
        .scrollContentBackground(.hidden)
        .background(SolennixColors.surfaceGrouped)
        .navigationTitle(staffId != nil ? "Editar Personal" : "Nuevo Personal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if let _ = await viewModel.validateAndSave() {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Guardar")
                            .fontWeight(.semibold)
                            .foregroundStyle(viewModel.isFormValid ? SolennixColors.primary : SolennixColors.textTertiary)
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isSaving)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Cargando...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(SolennixColors.background.opacity(0.6))
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            if let id = staffId {
                await viewModel.loadStaff(id: id)
            }
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        Section("Informacion") {
            AdaptiveFormRow {
                SolennixTextField(
                    label: "Nombre",
                    text: $viewModel.name,
                    placeholder: "Nombre completo",
                    leftIcon: "person",
                    errorMessage: !viewModel.name.isEmpty && !viewModel.isNameValid
                        ? "Minimo 2 caracteres" : nil,
                    textContentType: .name,
                    autocapitalization: .words
                )
            } right: {
                SolennixTextField(
                    label: "Rol",
                    text: $viewModel.roleLabel,
                    placeholder: "Ej: Mesero, DJ, Fotografo",
                    leftIcon: "briefcase",
                    autocapitalization: .words
                )
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.sm, trailing: Spacing.md))
        }
    }

    // MARK: - Contact Section

    private var contactSection: some View {
        Section("Contacto") {
            AdaptiveFormRow {
                SolennixTextField(
                    label: "Telefono",
                    text: $viewModel.phone,
                    placeholder: "10 digitos",
                    leftIcon: "phone",
                    textContentType: .telephoneNumber,
                    keyboardType: .phonePad
                )
            } right: {
                SolennixTextField(
                    label: "Email",
                    text: $viewModel.email,
                    placeholder: "correo@ejemplo.com",
                    leftIcon: "envelope",
                    errorMessage: !viewModel.email.isEmpty && !viewModel.isEmailValidIfProvided
                        ? "Email invalido" : nil,
                    textContentType: .emailAddress,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.sm, trailing: Spacing.md))
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Toggle(isOn: $viewModel.notificationEmailOptIn) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Avisarle por email al asignarlo a un evento")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(SolennixColors.text)

                        Text("Se activara en Phase 2 (Pro+). Por ahora guardamos la preferencia.")
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }
                }
                .tint(SolennixColors.primary)

                if viewModel.notificationEmailOptIn && !viewModel.isOptInConsistent {
                    Text("Para activar el aviso necesitas un email valido")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.error)
                }
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.sm, trailing: Spacing.md))
        } header: {
            Text("Avisos")
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        Section("Notas") {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Notas")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(SolennixColors.text)

                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 80)
                    .font(.body)
                    .foregroundStyle(SolennixColors.text)
                    .scrollContentBackground(.hidden)
                    .padding(Spacing.sm)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(SolennixColors.border, lineWidth: 1)
                    )
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: Spacing.sm, trailing: Spacing.md))
        }
    }
}

// MARK: - Preview

#Preview("New Staff") {
    NavigationStack {
        StaffFormView(apiClient: APIClient())
    }
}

#Preview("Edit Staff") {
    NavigationStack {
        StaffFormView(staffId: "123", apiClient: APIClient())
    }
}
