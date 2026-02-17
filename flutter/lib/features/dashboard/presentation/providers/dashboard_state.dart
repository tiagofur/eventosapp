import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventosapp/features/dashboard/data/models/dashboard_metrics_model.dart';
import 'package:eventosapp/features/dashboard/domain/entities/dashboard_entities.dart';

class DashboardState {
  final DashboardKPIMetrics? metrics;
  final List<EventSummary> upcomingEvents;
  final List<InventoryAlert> inventoryAlerts;
  final List<MonthlyRevenue> monthlyRevenues;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.metrics,
    this.upcomingEvents = const [],
    this.inventoryAlerts = const [],
    this.monthlyRevenues = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardKPIMetrics? metrics,
    List<EventSummary>? upcomingEvents,
    List<InventoryAlert>? inventoryAlerts,
    List<MonthlyRevenue>? monthlyRevenues,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      inventoryAlerts: inventoryAlerts ?? this.inventoryAlerts,
      monthlyRevenues: monthlyRevenues ?? this.monthlyRevenues,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DashboardState loading() => copyWith(isLoading: true);
  DashboardState error(String message) => copyWith(errorMessage: message, isLoading: false);
  DashboardState loaded(DashboardMetricsModel model) => copyWith(
    metrics: DashboardKPIMetrics(
      totalSales: model.totalSales,
      totalCollected: model.totalCollected,
      pendingCollections: model.pendingCollections,
      totalVAT: model.totalVAT,
      totalEvents: model.totalEvents,
      upcomingEvents: model.upcomingEvents,
      pendingPayments: model.pendingPayments,
      lowStockItems: model.lowStockItems,
      salesGrowth: model.salesGrowth,
      activeClients: model.activeClients,
    ),
    upcomingEvents: model.upcomingEventsList.map((e) => EventSummary(
      id: e.id,
      clientName: e.clientName,
      eventName: e.eventName,
      eventDate: e.eventDate,
      totalAmount: e.totalAmount,
      collectedAmount: e.collectedAmount,
      status: e.status,
      location: e.location,
    )).toList(),
    inventoryAlerts: model.inventoryAlerts.map((e) => InventoryAlert(
      id: e.id,
      itemName: e.itemName,
      currentStock: e.currentStock,
      minStock: e.minStock,
      unit: e.unit,
      eventsAffected: e.eventsAffected,
    )).toList(),
    monthlyRevenues: model.monthlyRevenues.map((e) => MonthlyRevenue(
      month: e.month,
      revenue: e.revenue,
      expenses: e.expenses,
      profit: e.profit,
    )).toList(),
    isLoading: false,
    errorMessage: null,
  );
}
