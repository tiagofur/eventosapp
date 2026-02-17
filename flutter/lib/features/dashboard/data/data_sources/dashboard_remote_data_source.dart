class DashboardRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    return await Future.delayed(
      const Duration(seconds: 1),
      () => {
        'total_sales': 150000.0,
        'total_collected': 125000.0,
        'pending_collections': 25000.0,
        'total_vat': 24000.0,
        'total_events': 48,
        'upcoming_events': 12,
        'pending_payments': 8,
        'low_stock_items': 5,
        'sales_growth': 15.5,
        'active_clients': 32,
        'upcoming_events_list': [
          {
            'id': '1',
            'client_name': 'María García',
            'event_name': 'Boda de Sofía y Alejandro',
            'event_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            'total_amount': 45000.0,
            'collected_amount': 22500.0,
            'status': 'confirmed',
            'location': 'Hacienda Los Pinos'
          },
          {
            'id': '2',
            'client_name': 'Carlos Rodríguez',
            'event_name': 'Aniversario Empresa Tech',
            'event_date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
            'total_amount': 25000.0,
            'collected_amount': 7500.0,
            'status': 'pending',
            'location': 'Hotel Centro'
          },
        ],
        'inventory_alerts': [
          {
            'id': '1',
            'item_name': 'Servilletas de tela',
            'current_stock': 120.0,
            'min_stock': 200.0,
            'unit': 'unidades',
            'events_affected': 3
          },
          {
            'id': '2',
            'item_name': 'Vinos premium',
            'current_stock': 15.0,
            'min_stock': 30.0,
            'unit': 'botellas',
            'events_affected': 2
          },
        ],
        'monthly_revenues': [
          {'month': 'Sep', 'revenue': 42000.0, 'expenses': 28000.0, 'profit': 14000.0},
          {'month': 'Oct', 'revenue': 45000.0, 'expenses': 30000.0, 'profit': 15000.0},
          {'month': 'Nov', 'revenue': 48000.0, 'expenses': 32000.0, 'profit': 16000.0},
          {'month': 'Dic', 'revenue': 50000.0, 'expenses': 33000.0, 'profit': 17000.0},
        ],
      },
    );
  }
}
