import 'package:flutter/foundation.dart';

/// Configuración de tests para el proyecto
class TestConfig {
  /// Coverage mínimo requerido (75%)
  static const double minCoverage = 0.75;

  /// Coverage objetivo (80%)
  static const double targetCoverage = 0.80;

  /// Timeout por defecto para async tests (5 segundos)
  static const Duration defaultTimeout = Duration(seconds: 5);

  /// Timeout para tests de integración (30 segundos)
  static const Duration integrationTestTimeout = Duration(seconds: 30);

  /// Timeout para tests de performance (10 segundos)
  static const Duration performanceTestTimeout = Duration(seconds: 10);

  /// Patrón para excluir archivos del coverage
  static bool shouldExcludeFile(String path) {
    return path.contains('.g.dart') || // Generados por build_runner
        path.contains('.mocks.dart') || // Mocks generados
        path.contains('.freezed.dart') || // Generados por freezed
        path.contains('/test/') || // Los tests mismos
        path.contains('main.dart'); // Punto de entrada
  }

  /// Lista de archivos a excluir del coverage
  static const List<String> excludedPaths = [
    '.g.dart',
    '.mocks.dart',
    '.freezed.dart',
    '/test/',
    'main.dart',
    'generated_plugin_registrant.dart',
  ];

  /// Métricas de performance por defecto
  static const PerformanceMetrics defaultMetrics = PerformanceMetrics(
    maxFrameBuildTime: Duration(milliseconds: 16),
    maxTotalBuildTime: Duration(seconds: 2),
    maxMemoryUsage: 100 * 1024 * 1024, // 100 MB
  );
}

/// Métricas de performance para tests
class PerformanceMetrics {
  final Duration maxFrameBuildTime;
  final Duration maxTotalBuildTime;
  final int maxMemoryUsage;

  const PerformanceMetrics({
    required this.maxFrameBuildTime,
    required this.maxTotalBuildTime,
    required this.maxMemoryUsage,
  });

  /// Verifica que el tiempo de frame esté dentro del límite
  bool isFrameBuildTimeAcceptable(Duration frameTime) {
    return frameTime <= maxFrameBuildTime;
  }

  /// Verifica que el tiempo total esté dentro del límite
  bool isTotalBuildTimeAcceptable(Duration totalTime) {
    return totalTime <= maxTotalBuildTime;
  }

  /// Verifica que el uso de memoria esté dentro del límite
  bool isMemoryUsageAcceptable(int memoryUsage) {
    return memoryUsage <= maxMemoryUsage;
  }
}

/// Constantes de test
class TestConstants {
  /// Email de prueba
  static const String testEmail = 'test@example.com';

  /// Contraseña de prueba
  static const String testPassword = 'Test123!';

  /// Nombre de usuario de prueba
  static const String testUserName = 'Test User';

  /// ID de usuario de prueba
  static const String testUserId = 'test-user-id';

  /// Token de prueba
  static const String testToken = 'test-access-token';

  /// URL de API de prueba
  static const String testApiUrl = 'http://localhost:8080/api';

  /// Moneda de prueba
  static const String testCurrency = '\$';

  /// Locale de prueba
  static const String testLocale = 'es_MX';
}

/// Datos de prueba para entidades
class TestData {
  static Map<String, dynamic> get testUser => {
    'id': TestConstants.testUserId,
    'email': TestConstants.testEmail,
    'name': TestConstants.testUserName,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> get testEvent => {
    'id': 'test-event-id',
    'user_id': TestConstants.testUserId,
    'client_id': 'test-client-id',
    'service_type': 'Boda',
    'event_date': DateTime(2024, 6, 15).toIso8601String(),
    'start_time': '14:00',
    'end_time': '18:00',
    'num_people': 150,
    'location': 'Salón de eventos',
    'city': 'Ciudad de México',
    'status': 'quoted',
    'subtotal': 20000.00,
    'discount': 0.0,
    'tax_rate': 16.0,
    'tax_amount': 3200.00,
    'total_amount': 23200.00,
    'deposit_percent': 30.0,
    'deposit_amount': 6960.00,
    'requires_invoice': true,
    'notes': 'Notas de prueba',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> get testClient => {
    'id': 'test-client-id',
    'user_id': TestConstants.testUserId,
    'name': 'Juan Pérez',
    'email': 'juan@example.com',
    'phone': '+525512345678',
    'address': 'Av. Principal 123',
    'city': 'Ciudad de México',
    'notes': 'Cliente de prueba',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'total_events': 5,
    'total_spent': 100000.00,
  };

  static Map<String, dynamic> get testProduct => {
    'id': 'test-product-id',
    'name': 'Paquete Boda Premium',
    'category': 'Paquetes',
    'description': 'Descripción del producto',
    'price': 15000.00,
    'cost': 10000.00,
    'unit': 'evento',
    'min_quantity': 1,
    'is_active': true,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> get testInventoryItem => {
    'id': 'test-inventory-id',
    'name': 'Ingrediente Test',
    'category': 'Alimentos',
    'current_quantity': 50.0,
    'unit': 'kg',
    'min_quantity': 10.0,
    'max_quantity': 100.0,
    'cost_per_unit': 100.00,
    'supplier': 'Proveedor Test',
    'last_restocked_at': DateTime.now().toIso8601String(),
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };
}

/// Utilidades de log para tests
class TestLogger {
  static const bool _enabled = true;

  static void log(String message) {
    if (_enabled && kDebugMode) {
      debugPrint('🧪 TEST: $message');
    }
  }

  static void logError(String error) {
    if (_enabled && kDebugMode) {
      debugPrint('❌ TEST ERROR: $error');
    }
  }

  static void logSuccess(String message) {
    if (_enabled && kDebugMode) {
      debugPrint('✅ TEST SUCCESS: $message');
    }
  }

  static void logWarning(String warning) {
    if (_enabled && kDebugMode) {
      debugPrint('⚠️  TEST WARNING: $warning');
    }
  }
}
