import SwiftUI
import SolennixCore
import SolennixNetwork
import SolennixDesign

// MARK: - Payment Inbox View

/// Organizer inbox for reviewing client payment submissions.
/// Shows pending (and historical) transfer receipts with approve / reject actions.
public struct PaymentInboxView: View {

    // MARK: - State

    @State private var viewModel: PaymentInboxViewModel
    @State private var rejectTarget: PaymentSubmission? = nil
    @State private var rejectionReason: String = ""
    @State private var showRejectSheet = false
    @State private var selectedSubmission: PaymentSubmission? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var contentMaxWidth: CGFloat { 1200 }

    // MARK: - Init

    public init(apiClient: APIClient) {
        _viewModel = State(wrappedValue: PaymentInboxViewModel(apiClient: apiClient))
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if viewModel.isLoading && viewModel.submissions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isPlanLocked {
                planLockedState
            } else if viewModel.submissions.isEmpty {
                emptyState
            } else {
                submissionContent
            }
        }
        .navigationTitle("Pagos recibidos")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.fetchSubmissions() }
        .refreshable { await viewModel.fetchSubmissions() }
        .sheet(item: $selectedSubmission) { submission in
            submissionDetailSheet(submission)
        }
        .sheet(isPresented: $showRejectSheet) {
            rejectSheet
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Submission Content

    private var submissionContent: some View {
        ScrollView {
            if isRegularWidth {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: Spacing.sm) {
                    ForEach(viewModel.submissions) { submission in
                        Button {
                            selectedSubmission = submission
                        } label: {
                            submissionRow(submission)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
            } else {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(viewModel.submissions) { submission in
                        Button {
                            selectedSubmission = submission
                        } label: {
                            submissionRow(submission)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .background(SolennixColors.surfaceGrouped)
    }

    @ViewBuilder
    private func submissionRow(_ submission: PaymentSubmission) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(submission.clientName ?? "Cliente")
                        .font(.headline)
                        .foregroundStyle(SolennixColors.text)
                    Text(submission.eventLabel ?? "Evento")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)
                }
                Spacer()
                statusBadge(for: submission.status)
            }

            // Amount + reference
            HStack(spacing: 16) {
                Label(formatAmount(submission.amount), systemImage: "dollarsign.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.primary)
                if let ref = submission.transferRef {
                    Label(ref, systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.textSecondary)
                        .lineLimit(1)
                }
            }

            // Submitted date
            Text(formatDate(submission.submittedAt))
                .font(.caption2)
                .foregroundStyle(SolennixColors.textTertiary)

            // Receipt link
            if let urlString = submission.receiptFileUrl,
               let url = APIClient.resolveURL(urlString) {
                Link(destination: url) {
                    Label("Ver pago", systemImage: "paperclip")
                        .font(.caption)
                        .foregroundStyle(SolennixColors.info)
                }
            }

            // Rejection reason
            if submission.status == .rejected, let reason = submission.rejectionReason {
                Text("Motivo: \(reason)")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.error)
                    .padding(.top, 2)
            }

            Divider()
                .padding(.vertical, 2)

            HStack(spacing: Spacing.xs) {
                Text("Toca para revisar")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(SolennixColors.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .shadowSm()
    }

    // MARK: - Submission Detail Sheet

    private func submissionDetailSheet(_ submission: PaymentSubmission) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(submission.clientName ?? "Cliente")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(SolennixColors.text)

                        Text(submission.eventLabel ?? "Evento")
                            .font(.subheadline)
                            .foregroundStyle(SolennixColors.textSecondary)

                        statusBadge(for: submission.status)
                    }

                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Label(formatAmount(submission.amount), systemImage: "dollarsign.circle.fill")
                            .font(.headline)
                            .foregroundStyle(SolennixColors.primary)

                        if let ref = submission.transferRef, !ref.isEmpty {
                            Label(ref, systemImage: "number")
                                .font(.subheadline)
                                .foregroundStyle(SolennixColors.textSecondary)
                        }

                        Label(formatDate(submission.submittedAt), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }

                    if let urlString = submission.receiptFileUrl,
                       let url = APIClient.resolveURL(urlString) {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Comprobante")
                                .font(.headline)
                                .foregroundStyle(SolennixColors.text)

                            if isImageURL(url) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                                    case .failure:
                                        receiptFallback
                                    default:
                                        ProgressView()
                                            .frame(maxWidth: .infinity, minHeight: 180)
                                    }
                                }
                            } else {
                                receiptFallback
                            }

                            Link(destination: url) {
                                Label("Abrir comprobante", systemImage: "paperclip")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    if submission.status == .rejected,
                       let reason = submission.rejectionReason,
                       !reason.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Motivo del rechazo")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(SolennixColors.text)
                            Text(reason)
                                .font(.subheadline)
                                .foregroundStyle(SolennixColors.error)
                        }
                    }

                    if submission.status == .pending {
                        HStack(spacing: Spacing.sm) {
                            Button {
                                Task {
                                    await viewModel.approve(id: submission.id)
                                    selectedSubmission = nil
                                }
                            } label: {
                                if viewModel.approvingId == submission.id {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Label("Aprobar", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(SolennixColors.success)
                            .disabled(viewModel.approvingId != nil || viewModel.rejectingId != nil)

                            Button {
                                selectedSubmission = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    rejectTarget = submission
                                    rejectionReason = ""
                                    showRejectSheet = true
                                }
                            } label: {
                                Label("Rechazar", systemImage: "xmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(SolennixColors.error)
                            .disabled(viewModel.approvingId != nil || viewModel.rejectingId != nil)
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .background(SolennixColors.surfaceGrouped)
            .navigationTitle("Detalle de pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { selectedSubmission = nil }
                }
            }
        }
    }

    private var receiptFallback: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "doc.text.image")
                .font(.largeTitle)
                .foregroundStyle(SolennixColors.textTertiary)
            Text("No se pudo previsualizar el archivo")
                .font(.caption)
                .foregroundStyle(SolennixColors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
    }

    private func isImageURL(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["jpg", "jpeg", "png", "heic", "heif", "webp", "gif"].contains(ext)
    }

    // MARK: - Status Badge

    @ViewBuilder
    private func statusBadge(for status: PaymentSubmissionStatus) -> some View {
        let (label, color): (String, Color) = {
            switch status {
            case .pending:  return ("Pendiente", SolennixColors.warning)
            case .approved: return ("Aprobado",  SolennixColors.success)
            case .rejected: return ("Rechazado", SolennixColors.error)
            }
        }()
        Text(label)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Reject Sheet

    private var rejectSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if let target = rejectTarget {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(target.clientName ?? "Cliente")
                            .font(.headline)
                        Text(formatAmount(target.amount))
                            .font(.subheadline)
                            .foregroundStyle(SolennixColors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Motivo del rechazo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    TextEditor(text: $rejectionReason)
                        .frame(minHeight: 120)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(SolennixColors.border, lineWidth: 1)
                        )
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Rechazar pago")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { showRejectSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rechazar") {
                        guard let target = rejectTarget,
                              rejectionReason.count >= 10 else { return }
                        Task {
                            await viewModel.reject(id: target.id, reason: rejectionReason)
                            showRejectSheet = false
                        }
                    }
                    .disabled(rejectionReason.count < 10 || viewModel.rejectingId != nil)
                    .foregroundStyle(SolennixColors.error)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Plan Locked State

    private var planLockedState: some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .foregroundStyle(SolennixColors.textTertiary)
                Text(String(localized: "payment_inbox.pro_only_title",
                            defaultValue: "Función exclusiva para usuarios Pro."))
                    .font(.headline)
                    .foregroundStyle(SolennixColors.textSecondary)
                    .multilineTextAlignment(.center)
                Text(String(localized: "payment_inbox.pro_only_hint",
                        defaultValue: "Actualiza tu plan para revisar y aprobar pagos recibidos de clientes."))
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.lg)
            .glassSurface(opacity: 0.14, blur: 10)
            .shadowSm()
            .padding(.horizontal, Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            VStack(spacing: 16) {
                Image(systemName: "tray.fill")
                    .font(.largeTitle)
                    .foregroundStyle(SolennixColors.textTertiary)
                Text("Sin pagos pendientes")
                    .font(.headline)
                    .foregroundStyle(SolennixColors.textSecondary)
                Text("Cuando un cliente envíe un pago de transferencia, aparecerá aquí para tu revisión.")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.lg)
            .glassSurface(opacity: 0.14, blur: 10)
            .shadowSm()
            .padding(.horizontal, Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Formatting

    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    private func formatDate(_ isoString: String) -> String {
        let isoFormatterFull = ISO8601DateFormatter()
        isoFormatterFull.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatterBasic = ISO8601DateFormatter()
        isoFormatterBasic.formatOptions = [.withInternetDateTime]
        let date = isoFormatterFull.date(from: isoString) ?? isoFormatterBasic.date(from: isoString)
        if let date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "es_MX")
            return formatter.string(from: date)
        }
        return isoString
    }
}
