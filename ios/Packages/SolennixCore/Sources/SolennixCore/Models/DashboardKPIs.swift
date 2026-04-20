import Foundation

/// Server-aggregated KPIs for the dashboard header.
///
/// Mirrors the shape of `backend/internal/repository/DashboardKPIs`.
/// Fetched via `GET /api/dashboard/kpis`. Backend is the single source of
/// truth for every metric on the dashboard header — clients no longer
/// aggregate from raw lists.
///
/// Monthly fields (net sales, cash collected, VAT collected / outstanding)
/// are scoped to events with `event_date` in the current calendar month
/// AND status ∈ {confirmed, completed}. VAT is prorated per event by paid
/// ratio. Cash collected is scoped by `payment_date` in the current month.
public struct DashboardKPIs: Codable, Sendable, Hashable {
    public let totalRevenue: Double
    public let eventsThisMonth: Int
    public let pendingQuotes: Int
    public let lowStockItems: Int
    public let upcomingEvents: Int
    public let totalClients: Int
    public let averageEventValue: Double
    public let netSalesThisMonth: Double
    public let cashCollectedThisMonth: Double
    public let vatCollectedThisMonth: Double
    public let vatOutstandingThisMonth: Double

    enum CodingKeys: String, CodingKey {
        case totalRevenue = "total_revenue"
        case eventsThisMonth = "events_this_month"
        case pendingQuotes = "pending_quotes"
        case lowStockItems = "low_stock_items"
        case upcomingEvents = "upcoming_events"
        case totalClients = "total_clients"
        case averageEventValue = "average_event_value"
        case netSalesThisMonth = "net_sales_this_month"
        case cashCollectedThisMonth = "cash_collected_this_month"
        case vatCollectedThisMonth = "vat_collected_this_month"
        case vatOutstandingThisMonth = "vat_outstanding_this_month"
    }

    public init(
        totalRevenue: Double,
        eventsThisMonth: Int,
        pendingQuotes: Int,
        lowStockItems: Int,
        upcomingEvents: Int,
        totalClients: Int,
        averageEventValue: Double,
        netSalesThisMonth: Double,
        cashCollectedThisMonth: Double,
        vatCollectedThisMonth: Double,
        vatOutstandingThisMonth: Double
    ) {
        self.totalRevenue = totalRevenue
        self.eventsThisMonth = eventsThisMonth
        self.pendingQuotes = pendingQuotes
        self.lowStockItems = lowStockItems
        self.upcomingEvents = upcomingEvents
        self.totalClients = totalClients
        self.averageEventValue = averageEventValue
        self.netSalesThisMonth = netSalesThisMonth
        self.cashCollectedThisMonth = cashCollectedThisMonth
        self.vatCollectedThisMonth = vatCollectedThisMonth
        self.vatOutstandingThisMonth = vatOutstandingThisMonth
    }
}

/// One data point returned by `GET /api/dashboard/revenue-chart`.
/// Mirrors `backend/internal/repository/RevenueDataPoint`.
public struct DashboardRevenuePoint: Codable, Sendable, Hashable {
    public let month: String        // "YYYY-MM"
    public let revenue: Double
    public let eventCount: Int

    enum CodingKeys: String, CodingKey {
        case month
        case revenue
        case eventCount = "event_count"
    }

    public init(month: String, revenue: Double, eventCount: Int) {
        self.month = month
        self.revenue = revenue
        self.eventCount = eventCount
    }
}
