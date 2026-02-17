import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/features/dashboard/domain/entities/dashboard_entities.dart';

void main() {
  group('DashboardStatsEntity', () {
    const testId = 'test-stats-id';
    const testUserId = 'test-user-id';
    final testStartDate = DateTime(2024, 1, 1);
    final testEndDate = DateTime(2024, 1, 31);
    final testCurrentDate = DateTime(2024, 1, 15);

    group('Constructor', () {
      test('should create DashboardStatsEntity with all fields', () {
        final stats = DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          startDate: testStartDate,
          endDate: testEndDate,
          currentDate: testCurrentDate,
          totalEvents: 10,
          confirmedEvents: 7,
          completedEvents: 3,
          cancelledEvents: 0,
          pendingEvents: 0,
          totalRevenue: 150000.00,
          collectedRevenue: 60000.00,
          pendingRevenue: 90000.00,
          averageRevenue: 15000.00,
          totalClients: 5,
          newClientsThisMonth: 2,
          revenueThisMonth: 50000.00,
          monthOverMonth: 0.1,
          monthOverYear: -0.05,
          revenueGrowthRate: 15.0,
          clientRetentionRate: 0.8,
          topServices: [
            Service(name: 'Boda', count: 5, revenue: 75000.00),
            Service(name: 'Boda Premium', count: 2, revenue: 20000.00),
          ],
          topProducts: [
            Product(name: 'Paquete Boda Premium', count: 8, revenue: 40000.00),
            Product(name: 'Servicio de Menús', count: 5, revenue: 5000.00),
          ],
          topRegions: [
            Region(name: 'Norte', count: 3, revenue: 60000.00),
            Region(name: 'Centro', count: 2, revenue: 40000.00),
          ],
          eventsByStatus: {
            'quoted': 2,
            'confirmed': 4,
            'completed': 3,
            'cancelled': 1,
          },
        upcomingEvents: [
          Event(id: '1', date: DateTime(2024, 1, 20), client: 'Juan', revenue: 5000.00),
          Event(id: '2', date: DateTime(2024, 1, 25), client: 'María', revenue: 3000.00),
          Event(id: '3', date: DateTime(2024, 1, 30), client: 'Pedro', revenue: 8000.00),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.id, equals(testId));
        expect(stats.userId, equals(testUserId));
        expect(stats.startDate, equals(testStartDate));
        expect(stats.endDate, equals(testEndDate));
        expect(stats.currentDate, equals(testCurrentDate));
        expect(stats.totalEvents, equals(10));
        expect(stats.confirmedEvents, equals(7));
        expect(stats.completedEvents, equals(3));
        expect(stats.cancelledEvents, equals(0));
        expect(stats.pendingEvents, equals(0));
        expect(stats.totalRevenue, equals(150000.00));
        expect(stats.collectedRevenue, equals(60000.00));
        expect(stats.pendingRevenue, equals(90000.00));
        expect(stats.averageRevenue, equals(15000.00));
        expect(stats.totalClients, equals(5));
        expect(stats.newClientsThisMonth, equals(2));
        expect(stats.revenueThisMonth, equals(50000.00));
        expect(stats.monthOverMonth, equals(0.1));
        expect(stats.monthOverYear, equals(-0.05));
        expect(stats.revenueGrowthRate, equals(15.0));
        expect(stats.clientRetentionRate, equals(0.8));
        expect(stats.topServices.length, equals(3));
        expect(stats.topProducts.length, equals(2));
        expect(stats.topRegions.length, equals(2));
        expect(stats.eventsByStatus.length, equals(4));
        expect(stats.upcomingEvents.length, equals(3));
        expect(stats.createdAt, equals(testCreatedAt));
        expect(stats.updatedAt, equals(testUpdatedAt));
      });

      test('should create DashboardStatsEntity with minimal required fields', () {
        final stats = const DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          totalEvents: 0,
          totalRevenue: 0,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.id, equals(testId));
        expect(stats.userId, equals(testUserId));
        expect(stats.totalEvents, equals(0));
        expect(stats.totalRevenue, equals(0));
        expect(stats.createdAt, equals(testCreatedAt));
        expect(stats.updatedAt, equals(testUpdatedAt));
      });
    });

    group('Getters', () {
      test('monthlyGrowth should calculate correctly', () {
        final stats = const DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          revenueThisMonth: 50000.00,
          revenueLastMonth: 45000.00,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.monthlyGrowthRate, equals(11.1));
      });

      test('yearlyGrowth should calculate correctly', () {
        final stats = const DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          revenueThisMonth: 50000.00,
          revenueLastMonth: 45000.00,
          revenueLastYear: 45000.00,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.yearlyGrowthRate, equals(0.0));
      });

      test('clientRetentionRate should calculate correctly', () {
        final stats = const DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          totalRevenue: 150000.00,
          totalClients: 5,
          revenueThisMonth: 50000.00,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.clientRetentionRate, equals(3.3));
      });

      test('revenueGrowthRate should calculate correctly', () {
        final stats = const DashboardStatsEntity(
          id: testId,
          userId: testUserId,
          revenueThisMonth: 50000.00,
          revenueLastMonth: 45000.00,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(stats.revenueGrowthRate, equals(11.1));
      });
    });
}
