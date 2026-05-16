import SwiftUI
import SolennixCore
import SolennixDesign
import SolennixNetwork

public struct TeamMemberPortalView: View {

    private enum TeamMemberSection: String, CaseIterable, Identifiable {
        case work
        case calendar

        var id: String { rawValue }
    }

    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var viewModel: TeamMemberPortalViewModel
    @State private var section: TeamMemberSection = .work
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())

    public init(apiClient: APIClient) {
        _viewModel = State(initialValue: TeamMemberPortalViewModel(apiClient: apiClient))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Mi jornada")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            Task { await authManager.signOut() }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .accessibilityLabel("Cerrar sesion")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.loadAssignments() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .accessibilityLabel("Recargar asignaciones")
                    }
                }
        }
        .task {
            await viewModel.loadAssignments()
        }
        .refreshable {
            await viewModel.loadAssignments()
        }
        .background(SolennixColors.surfaceGrouped.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage, viewModel.assignments.isEmpty, !viewModel.isLoading {
            EmptyStateView(
                icon: "exclamationmark.triangle.fill",
                title: "No pudimos cargar tus asignaciones",
                message: errorMessage,
                actionTitle: "Reintentar"
            ) {
                Task { await viewModel.loadAssignments() }
            }
        } else if viewModel.isLoading && viewModel.assignments.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.assignments.isEmpty {
            EmptyStateView(
                icon: "calendar.badge.clock",
                title: "Todavia no tenes asignaciones",
                message: "Cuando te asignen a un evento, va a aparecer aca con respuesta rapida."
            ) {}
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.md) {
                    Picker("Seccion", selection: $section) {
                        Text("Mi jornada").tag(TeamMemberSection.work)
                        Text("Calendario").tag(TeamMemberSection.calendar)
                    }
                    .pickerStyle(.segmented)

                    if section == .work {
                        workSection
                    } else {
                        calendarSection
                    }
                }
                .padding(.horizontal, sizeClass == .regular ? Spacing.xxxl : Spacing.xl)
                .padding(.vertical, Spacing.lg)
            }
        }
    }

    private var pendingAssignments: [TeamMemberAssignment] {
        viewModel.assignments.filter { $0.status == .pending }
    }

    private var selectedDayAssignments: [TeamMemberAssignment] {
        assignmentsByDate[Calendar.current.startOfDay(for: selectedDate)] ?? []
    }

    private var assignmentsByDate: [Date: [TeamMemberAssignment]] {
        var grouped: [Date: [TeamMemberAssignment]] = [:]

        for assignment in viewModel.assignments {
            guard let assignmentDate = parseLocalDate(assignment.eventDate) else { continue }
            let day = Calendar.current.startOfDay(for: assignmentDate)
            grouped[day, default: []].append(assignment)
        }

        return grouped
    }

    private var statusDotsByDate: [Date: [AssignmentStatus]] {
        assignmentsByDate.mapValues { assignments in
            var ordered: [AssignmentStatus] = []

            for status in [AssignmentStatus.pending, .confirmed, .declined, .cancelled] {
                if assignments.contains(where: { $0.status == status }) {
                    ordered.append(status)
                }
            }

            for assignment in assignments where !ordered.contains(assignment.status) {
                ordered.append(assignment.status)
            }

            return Array(ordered.prefix(3))
        }
    }

    private var monthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    private var weekdaySymbols: [String] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        let symbols = formatter.shortStandaloneWeekdaySymbols ?? formatter.shortWeekdaySymbols ?? ["L", "M", "M", "J", "V", "S", "D"]
        let shift = max(0, min(symbols.count - 1, calendar.firstWeekday - 1))
        return Array(symbols[shift...]) + Array(symbols[..<shift])
    }

    private var monthDays: [TeamPortalCalendarDay] {
        let calendar = Calendar.current
        let firstDay = calendar.startOfMonth(for: displayedMonth)
        let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDay)
        let leadingDays = (firstWeekdayOfMonth - calendar.firstWeekday + 7) % 7

        var days: [TeamPortalCalendarDay] = []

        if let startDay = calendar.date(byAdding: .day, value: -leadingDays, to: firstDay) {
            for offset in 0..<42 {
                guard let date = calendar.date(byAdding: .day, value: offset, to: startDay) else { continue }
                let normalizedDate = calendar.startOfDay(for: date)
                days.append(
                    TeamPortalCalendarDay(
                        date: normalizedDate,
                        dayNumber: calendar.component(.day, from: normalizedDate),
                        isCurrentMonth: calendar.isDate(normalizedDate, equalTo: displayedMonth, toGranularity: .month),
                        isToday: calendar.isDateInToday(normalizedDate),
                        isSelected: calendar.isDate(normalizedDate, inSameDayAs: selectedDate)
                    )
                )
            }
        }

        return days
    }

    @ViewBuilder
    private var workSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Pendientes por responder")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SolennixColors.textSecondary)

            if pendingAssignments.isEmpty {
                cardContainer {
                    Text("No tenes invitaciones pendientes.")
                        .font(.subheadline)
                        .foregroundStyle(SolennixColors.textSecondary)
                }
            } else {
                ForEach(pendingAssignments) { assignment in
                    TeamMemberAssignmentCard(
                        assignment: assignment,
                        isResponding: viewModel.isResponding,
                        onAccept: {
                            Task { await viewModel.respond(to: assignment, response: .accept) }
                        },
                        onDecline: {
                            Task { await viewModel.respond(to: assignment, response: .decline) }
                        }
                    )
                }
            }

            Text("Mi agenda")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SolennixColors.textSecondary)
                .padding(.top, Spacing.sm)

            ForEach(viewModel.assignments) { assignment in
                TeamMemberAssignmentCard(
                    assignment: assignment,
                    isResponding: viewModel.isResponding,
                    onAccept: {
                        Task { await viewModel.respond(to: assignment, response: .accept) }
                    },
                    onDecline: {
                        Task { await viewModel.respond(to: assignment, response: .decline) }
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            cardContainer {
                VStack(spacing: Spacing.md) {
                    HStack {
                        Button {
                            displayedMonth = Calendar.current.addingMonths(-1, to: displayedMonth)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel("Mes anterior")

                        Spacer()

                        Text(monthLabel)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SolennixColors.text)

                        Spacer()

                        Button {
                            displayedMonth = Calendar.current.addingMonths(1, to: displayedMonth)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .accessibilityLabel("Mes siguiente")
                    }

                    HStack {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SolennixColors.textSecondary)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
                        ForEach(monthDays) { day in
                            TeamPortalCalendarDayCell(
                                day: day,
                                dots: statusDotsByDate[day.date] ?? [],
                                onTap: {
                                    selectedDate = day.date
                                    displayedMonth = Calendar.current.startOfMonth(for: day.date)
                                }
                            )
                        }
                    }
                }
            }

            Text("Eventos del dia")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SolennixColors.textSecondary)

            if selectedDayAssignments.isEmpty {
                cardContainer {
                    Text("No hay asignaciones para esta fecha.")
                        .font(.subheadline)
                        .foregroundStyle(SolennixColors.textSecondary)
                }
            } else {
                ForEach(selectedDayAssignments) { assignment in
                    TeamMemberAssignmentCard(
                        assignment: assignment,
                        isResponding: viewModel.isResponding,
                        onAccept: {
                            Task { await viewModel.respond(to: assignment, response: .accept) }
                        },
                        onDecline: {
                            Task { await viewModel.respond(to: assignment, response: .decline) }
                        }
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SolennixColors.card)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .shadowSm()
    }

    private func parseLocalDate(_ value: String) -> Date? {
        let parts = value.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}

private struct TeamPortalCalendarDay: Identifiable {
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool

    var id: Date { date }
}

private struct TeamPortalCalendarDayCell: View {
    let day: TeamPortalCalendarDay
    let dots: [AssignmentStatus]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    if day.isSelected {
                        Circle()
                            .fill(SolennixColors.primary)
                            .frame(width: 30, height: 30)
                    } else if day.isToday {
                        Circle()
                            .stroke(SolennixColors.primary, lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                    }

                    Text("\(day.dayNumber)")
                        .font(.subheadline)
                        .fontWeight(day.isSelected || day.isToday ? .semibold : .regular)
                        .foregroundStyle(dayNumberColor)
                }

                HStack(spacing: 3) {
                    ForEach(Array(dots.enumerated()), id: \.offset) { _, status in
                        Circle()
                            .fill(dotColor(for: status))
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .opacity(day.isCurrentMonth ? 1 : 0.35)
    }

    private var dayNumberColor: Color {
        if day.isSelected {
            return .white
        }
        if !day.isCurrentMonth {
            return SolennixColors.textTertiary
        }
        if day.isToday {
            return SolennixColors.primary
        }
        return SolennixColors.text
    }

    private func dotColor(for status: AssignmentStatus) -> Color {
        switch status {
        case .pending:
            return SolennixColors.warning
        case .confirmed:
            return SolennixColors.success
        case .declined:
            return SolennixColors.error
        case .cancelled:
            return SolennixColors.textSecondary
        }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }

    func addingMonths(_ value: Int, to date: Date) -> Date {
        self.date(byAdding: .month, value: value, to: date) ?? date
    }
}

private struct TeamMemberAssignmentCard: View {

    let assignment: TeamMemberAssignment
    let isResponding: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void

    private var isPending: Bool {
        assignment.status == .pending
    }

    private var feeLabel: String? {
        guard let feeAmount = assignment.feeAmount else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "MXN"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: feeAmount))
    }

    private var statusLabel: String {
        switch assignment.status {
        case .pending: return "Pendiente"
        case .confirmed: return "Confirmada"
        case .declined: return "Rechazada"
        case .cancelled: return "Cancelada"
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.eventName)
                        .font(.headline)
                        .foregroundStyle(SolennixColors.text)

                    Text(assignment.eventDate)
                        .font(.subheadline)
                        .foregroundStyle(SolennixColors.textSecondary)
                }

                Spacer()

                Text(statusLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusBackground)
                    .foregroundStyle(statusForeground)
                    .clipShape(Capsule())
            }

            if let roleOverride = assignment.roleOverride {
                Text("Rol: \(roleOverride)")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textSecondary)
            }

            if let feeLabel {
                Text("Pago: \(feeLabel)")
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.primary)
            }

            if let notes = assignment.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(SolennixColors.textSecondary)
            }

            if isPending {
                HStack(spacing: Spacing.sm) {
                    Button {
                        onDecline()
                    } label: {
                        Text("Rechazar")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(SolennixColors.error.opacity(0.14))
                            .foregroundStyle(SolennixColors.error)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                    .disabled(isResponding)

                    Button {
                        onAccept()
                    } label: {
                        Text("Aceptar")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(SolennixColors.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    }
                    .disabled(isResponding)
                }
            }
        }
        .padding(Spacing.lg)
        .background(SolennixColors.card)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        .shadowSm()
    }

    private var statusBackground: Color {
        switch assignment.status {
        case .pending: return SolennixColors.warning.opacity(0.14)
        case .confirmed: return SolennixColors.success.opacity(0.14)
        case .declined: return SolennixColors.error.opacity(0.14)
        case .cancelled: return SolennixColors.textTertiary.opacity(0.14)
        }
    }

    private var statusForeground: Color {
        switch assignment.status {
        case .pending: return SolennixColors.warning
        case .confirmed: return SolennixColors.success
        case .declined: return SolennixColors.error
        case .cancelled: return SolennixColors.textSecondary
        }
    }
}