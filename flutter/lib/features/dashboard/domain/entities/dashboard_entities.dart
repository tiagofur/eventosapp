class DashboardKPIMetrics {
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

  const DashboardKPIMetrics({
    this.totalSales = 0,
    this.totalCollected = 0,
    this.pendingCollections = 0,
    this.totalVAT = 0,
    this.totalEvents = 0,
    this.upcomingEvents = 0,
    this.pendingPayments = 0,
    this.lowStockItems = 0,
    this.salesGrowth = 0,
    this.activeClients = 0,
  });

  double get collectionRate => totalSales > 0 ? (totalCollected / totalSales) * 100 : 0;
  double get pendingAmount => totalSales - totalCollected;
}

class EventSummary {
  final String id;
  final String clientName;
  final String eventName;
  final DateTime eventDate;
  final double totalAmount;
  final double collectedAmount;
  final String status;
  final String? location;

  EventSummary({
    required this.id,
    required this.clientName,
    required this.eventName,
    required this.eventDate,
    required this.totalAmount,
    required this.collectedAmount,
    required this.status,
    this.location,
  });

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  double get pendingAmount => totalAmount - collectedAmount;
}

class InventoryAlert {
  final String id;
  final String itemName;
  final double currentStock;
  final double minStock;
  final String unit;
  final int eventsAffected;

  InventoryAlert({
    required this.id,
    required this.itemName,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.eventsAffected,
  });

  bool get isCritical => currentStock <= minStock * 0.3;
  double get stockLevel => minStock > 0 ? (currentStock / minStock) * 100 : 0;
}

class MonthlyRevenue {
  final String month;
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  double get margin => revenue > 0 ? (profit / revenue) * 100 : 0;
}
