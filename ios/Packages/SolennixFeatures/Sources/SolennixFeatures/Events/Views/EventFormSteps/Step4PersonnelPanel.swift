import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

// MARK: - Step 4: Personnel Panel

/// Subpanel dentro del Step 4 del form de eventos. Permite elegir
/// colaboradores de la libreta de Personal y definir el costo por evento.
/// NO es un Step 5 — vive dentro de Step 4 bajo supplies + equipment.
struct Step4PersonnelPanel: View {

    @Bindable var viewModel: EventFormViewModel

    @State private var showStaffPicker = false
    @State private var staffSearch = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Personal")
                .font(.headline)
                .foregroundStyle(SolennixColors.text)

            // Selected staff
            ForEach(Array(viewModel.selectedStaff.enumerated()), id: \.element.id) { index, assignment in
                staffRow(assignment: assignment, index: index)
            }

            // Add staff button
            Button {
                showStaffPicker = true
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(SolennixColors.primary)

                    Text("Agregar Personal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(SolennixColors.primary)

                    Spacer()
                }
                .padding(Spacing.md)
                .background(SolennixColors.primaryLight)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(SolennixColors.primary.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Staff cost total (informativo — no suma al total en Phase 1)
            if !viewModel.selectedStaff.isEmpty {
                HStack {
                    Text("Costo Personal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(SolennixColors.textSecondary)

                    Spacer()

                    Text(formatCurrency(viewModel.staffCost))
                        .font(.headline)
                        .foregroundStyle(SolennixColors.text)
                }
                .padding(Spacing.md)
                .background(SolennixColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
        }
        .sheet(isPresented: $showStaffPicker) {
            staffPickerSheet
        }
    }

    // MARK: - Staff Row

    private func staffRow(assignment: SelectedStaffAssignment, index: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Avatar(name: assignment.staffName.isEmpty ? "?" : assignment.staffName, photoURL: nil, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(assignment.staffName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(SolennixColors.text)

                    if let role = assignment.staffRoleLabel, !role.isEmpty {
                        Text(role)
                            .font(.caption)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }
                }

                Spacer()

                Button {
                    viewModel.removeStaff(at: index)
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(SolennixColors.error)
                }
                .buttonStyle(.plain)
            }

            // Fee amount
            VStack(alignment: .leading, spacing: 2) {
                Text("Costo (MXN)")
                    .font(.caption2)
                    .foregroundStyle(SolennixColors.textTertiary)

                TextField("0.00", value: $viewModel.selectedStaff[index].feeAmount, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
                    .font(.body)
                    .foregroundStyle(SolennixColors.text)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(SolennixColors.border, lineWidth: 1)
                    )
            }

            // Role override (opcional — para este evento solamente)
            VStack(alignment: .leading, spacing: 2) {
                Text("Rol en este evento (opcional)")
                    .font(.caption2)
                    .foregroundStyle(SolennixColors.textTertiary)

                TextField("Ej: Lider de barra", text: $viewModel.selectedStaff[index].roleOverride)
                    .font(.body)
                    .foregroundStyle(SolennixColors.text)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(SolennixColors.border, lineWidth: 1)
                    )
            }

            // Notes
            VStack(alignment: .leading, spacing: 2) {
                Text("Notas (opcional)")
                    .font(.caption2)
                    .foregroundStyle(SolennixColors.textTertiary)

                TextField("Notas de la asignacion", text: $viewModel.selectedStaff[index].notes)
                    .font(.body)
                    .foregroundStyle(SolennixColors.text)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 6)
                    .background(SolennixColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(SolennixColors.border, lineWidth: 1)
                    )
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(SolennixColors.border, lineWidth: 1)
        )
    }

    // MARK: - Staff Picker Sheet

    private var staffPickerSheet: some View {
        NavigationStack {
            Group {
                if viewModel.staff.isEmpty {
                    EmptyStateView(
                        icon: "person.3",
                        title: "Sin personal",
                        message: "Agrega colaboradores desde el menu Personal para asignarlos a este evento"
                    )
                } else {
                    List {
                        ForEach(filteredStaff) { item in
                            Button {
                                viewModel.addStaff(item)
                                showStaffPicker = false
                            } label: {
                                HStack(spacing: Spacing.sm) {
                                    Avatar(name: item.name, photoURL: nil, size: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundStyle(SolennixColors.text)

                                        if let role = item.roleLabel, !role.isEmpty {
                                            Text(role)
                                                .font(.caption)
                                                .foregroundStyle(SolennixColors.textSecondary)
                                        }
                                    }

                                    Spacer()

                                    if viewModel.selectedStaff.contains(where: { $0.staffId == item.id }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(SolennixColors.success)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .searchable(text: $staffSearch, prompt: "Buscar personal")
                }
            }
            .navigationTitle("Agregar Personal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        showStaffPicker = false
                    }
                    .foregroundStyle(SolennixColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Filtered List

    private var filteredStaff: [Staff] {
        if staffSearch.isEmpty { return viewModel.staff }
        return viewModel.staff.filter {
            $0.name.localizedCaseInsensitiveContains(staffSearch)
            || ($0.roleLabel?.localizedCaseInsensitiveContains(staffSearch) ?? false)
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        "$\(String(format: "%.2f", value))"
    }
}

// MARK: - Preview

#Preview("Step 4 Personnel Panel") {
    Step4PersonnelPanel(viewModel: EventFormViewModel(apiClient: APIClient()))
        .padding()
}
