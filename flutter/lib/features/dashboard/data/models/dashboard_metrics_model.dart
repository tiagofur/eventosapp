class DashboardMetricsModel {
  final double totalSales;
  final double totalCollected;
  final double pendingCollections;
  final double totalVAT;
  final int totalEvents;
  final int upcomingEvents;
  final int pendingPayments;
  final int lowStockItems;
  final double salesGrowth;
  final int activeClients;
  final List<EventSummaryModel> upcomingEventsList;
  final List<InventoryAlertModel> inventoryAlerts;
  final List<MonthlyRevenueModel> monthlyRevenues;

  DashboardMetricsModel({
    required this.totalSales,
    required this.totalCollected,
    required this.pendingCollections,
    required this.totalVAT,
    required this.totalEvents,
    required this.upcomingEvents,
    required this.pendingPayments,
    required this.lowStockItems,
    required this.salesGrowth,
    required this.activeClients,
    required this.upcomingEventsList,
    required this.inventoryAlerts,
    required this.monthlyRevenues,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsModel(
      totalSales: (json['total_sales'] as num).toDouble(),
      totalCollected: (json['total_collected'] as num).toDouble(),
      pendingCollections: (json['pending_collections'] as num).toDouble(),
      totalVAT: (json['total_vat'] as num).toDouble(),
      totalEvents: json['total_events'] as int,
      upcomingEvents: json['upcoming_events'] as int,
      pendingPayments: json['pending_payments'] as int,
      lowStockItems: json['low_stock_items'] as int,
      salesGrowth: (json['sales_growth'] as num).toDouble(),
      activeClients: json['active_clients'] as int,
      upcomingEventsList: (json['upcoming_events_list'] as List)
          .map((e) => EventSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      inventoryAlerts: (json['inventory_alerts'] as List)
          .map((e) => InventoryAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyRevenues: (json['monthly_revenues'] as List)
          .map((e) => MonthlyRevenueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EventSummaryModel {
  final String id;
  final String clientName;
  final String eventName;
  final DateTime eventDate;
  final double totalAmount;
  final double collectedAmount;
  final String status;
  final String? location;

  EventSummaryModel({
    required this.id,
    required this.clientName,
    required this.eventName,
    required this.eventDate,
    required this.totalAmount,
    required this.collectedAmount,
    required this.status,
    this.location,
  });

  factory EventSummaryModel.fromJson(Map<String, dynamic> json) {
    return EventSummaryModel(
      id: json['id'] as String,
      clientName: json['client_name'] as String,
      eventName: json['event_name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      collectedAmount: (json['collected_amount'] as num).toDouble(),
      status: json['status'] as String,
      location: json['location'] as String?,
    );
  }
}

class InventoryAlertModel {
  final String id;
  final String itemName;
  final double currentStock;
  final double minStock;
  final String unit;
  final int eventsAffected;

  InventoryAlertModel({
    required this.id,
    required this.itemName,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.eventsAffected,
  });

  factory InventoryAlertModel.fromJson(Map<String, dynamic> json) {
    return InventoryAlertModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      currentStock: (json['current_stock'] as num).toDouble(),
      minStock: (json['min_stock'] as num).toDouble(),
      unit: json['unit'] as String,
      eventsAffected: json['events_affected'] as int,
    );
  }
}

class MonthlyRevenueModel {
  final String month;
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyRevenueModel({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  factory MonthlyRevenueModel.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueModel(
      month: json['month'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );
  }
}
