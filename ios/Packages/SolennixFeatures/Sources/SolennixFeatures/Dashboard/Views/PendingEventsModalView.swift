import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

public struct PendingEventsModalView: View {
    @State private var viewModel: PendingEventsViewModel

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: PendingEventsViewModel(apiClient: apiClient))
    }

    public var body: some View {
        Group {
            if viewModel.isPresented && !viewModel.pendingEvents.isEmpty {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay(alignment: .center) {
                        modalContent
                            .padding(Spacing.lg)
                    }
                    .transition(.opacity)
            } else {
                EmptyView()
            }
        }
        .task {
            await viewModel.loadPendingEvents()
        }
    }

    private var modalContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(SolennixColors.primaryLight)
                        .frame(width: 40, height: 40)

                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(SolennixColors.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Eventos Pendientes de Cierre")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(SolennixColors.text)

                    Text("Tienes \(viewModel.pendingEvents.count) evento(s) que requieren tu atencion.")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)
                }

                Spacer()

                Button {
                    withAnimation {
                        viewModel.isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SolennixColors.textTertiary)
                        .padding(8)
                }
            }
            .padding(Spacing.lg)

            // List
            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.pendingEvents) { pendingEvent in
                        eventRow(pendingEvent)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            .frame(maxHeight: 300)

            Divider()

            // Footer Action
            Button {
                withAnimation {
                    viewModel.isPresented = false
                }
            } label: {
                Text("Cerrar por ahora")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            }
        }
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.xl))
        .shadowLg()
    }

    private func eventRow(_ pendingEvent: PendingEventWithReason) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pendingEvent.event.serviceType)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(SolennixColors.text)

                    Text(pendingEvent.event.eventDate)
                        .font(.caption2)
                        .foregroundStyle(SolennixColors.textSecondary)
                }

                Spacer()

                // Reason badge
                Text(pendingEvent.reason)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(SolennixColors.warning)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(SolennixColors.warning.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            }

            HStack(spacing: Spacing.sm) {
                Button {
                    Task {
                        await viewModel.updateEventStatus(eventId: pendingEvent.event.id, newStatus: .completed)
                    }
                } label: {
                    HStack(spacing: 4) {
                        if viewModel.updatingEventId == pendingEvent.event.id {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle")
                            Text("Completar")
                        }
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(SolennixColors.success)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                }
                .disabled(viewModel.updatingEventId != nil)

                Button {
                    Task {
                        await viewModel.updateEventStatus(eventId: pendingEvent.event.id, newStatus: .cancelled)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                        Text("Cancelar")
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(SolennixColors.error)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(SolennixColors.errorBg)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .strokeBorder(SolennixColors.error.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(viewModel.updatingEventId != nil)
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
    }
}
