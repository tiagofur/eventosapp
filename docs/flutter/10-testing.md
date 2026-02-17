# Testing — Flutter

Guía completa de pruebas para la aplicación móvil Flutter de EventosApp.

## 📋 Tipos de Tests

### Unit Tests

Pruebas unitarias de lógica de negocio pura (sin dependencias Flutter).

**Características:**
- ✅ Rápidas de ejecutar
- ✅ Aisladas de UI y dependencias externas
- ✅ Fáciles de debuguear
- ✅ Alto coverage de código

**Cuándo usar:**
- Lógica de negocio (use cases, entities)
- Funciones utilitarias
- Validaciones
- Cálculos matemáticos (totales, IVA, etc.)

### Widget Tests

Pruebas de widgets Flutter que verifican comportamiento de UI.

**Características:**
- ✅ Verifican renderizado correcto
- ✅ Verifican interacción del usuario
- ✅ Testean widgets en aislamiento
- ✅ Más rápidas que integration tests

**Cuándo usar:**
- Componentes UI aislados
- Widgets reutilizables (botones, inputs, cards)
- Páginas simples sin dependencias complejas

### Integration Tests

Pruebas end-to-end que verifican flujos completos de la aplicación.

**Características:**
- ✅ Simulan flujo completo de usuario
- ✅ Navegan entre múltiples pantallas
- ✅ Verifican integración entre capas
- ✅ Pueden usar mocks para API

**Cuándo usar:**
- Flujos completos de negocio (login → dashboard → crear evento)
- Interacción con API real
- Navegación compleja

---

## 🛠️ Stack de Testing

```yaml
dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

dev_dependencies:
  # Testing framework
  flutter_test:
    sdk: flutter
  
  # Mocking
  mockito: ^5.4.4
  
  # Network mocking
  http_mock_adapter: ^0.6.1
  
  # Coverage
  coverage: ^1.6.3
```

---

## 📁 Estructura de Tests

```
flutter/
├── test/
│   ├── unit/                 # Unit tests
│   │   ├── usecases/
│   │   │   ├── get_events_usecase_test.dart
│   │   │   ├── create_event_usecase_test.dart
│   │   │   └── ...
│   │   └── utils/
│   │       ├── formatters_test.dart
│   │       └── validators_test.dart
│   │
│   ├── widgets/              # Widget tests
│   │   ├── event_card_test.dart
│   │   ├── search_field_test.dart
│   │   ├── primary_button_test.dart
│   │   └── ...
│   │
│   └── integration/          # Integration tests
│       ├── auth_flow_test.dart
│       ├── event_creation_test.dart
│       └── payment_flow_test.dart
│
└── test_driver/          # Para tests E2E con app real (opcional)
```

---

## 🧪 Ejecutar Tests

### Todos los tests

```bash
# Ejecutar todos los tests
flutter test

# Con coverage
flutter test --coverage

# Reporte detallado
flutter test --coverage --expanded
```

### Tests específicos

```bash
# Solo unit tests
flutter test test/unit/

# Solo widget tests
flutter test test/widgets/

# Solo integration tests
flutter test test/integration/

# Con patrón (wildcard)
flutter test test/unit/**/*_test.dart
```

### Tests en watch mode

```bash
# Reejecutar tests automáticamente cuando cambie código
flutter test --watch
```

---

## 📊 Coverage

### Ver coverage

```bash
# Generar reporte de coverage
flutter pub run build_runner build --delete-conflicting-outputs
flutter test --coverage

# Ver coverage en terminal
lcov --summary lcov.info
```

### Coverage mínimo recomendado

| Tipo de Código | Coverage Mínimo |
|---------------|-----------------|
| Lógica de negocio (use cases) | 80%+ |
| Repositorios | 70%+ |
| Utilidades | 70%+ |
| Widgets reutilizables | 60%+ |
| Pages completas | 50%+ |

---

## 📝 Ejemplos de Tests

### 1. Unit Test - Use Case

```dart
// test/unit/usecases/get_events_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eventosapp/features/events/domain/usecases/get_events_usecase.dart';
import 'package:eventosapp/features/events/domain/repositories/events_repository.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('GetEventsUseCase', () {
    late GetEventsUseCase useCase;
    late MockEventsRepository mockRepository;

    setUp(() {
      mockRepository = MockEventsRepository();
      useCase = GetEventsUseCase(mockRepository);
    });

    test('should return list of events when repository returns data', () async {
      // Arrange
      final expectedEvents = [
        EventEntity(id: '1', eventDate: DateTime(2024, 6, 15), ...),
        EventEntity(id: '2', eventDate: DateTime(2024, 6, 20), ...),
      ];

      when(mockRepository.getEvents()).thenAnswer((_) async => expectedEvents);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(expectedEvents));
      verify(mockRepository).getEvents();
    });

    test('should propagate repository error', () async {
      // Arrange
      const expectedError = Exception('Failed to fetch events');
      when(mockRepository.getEvents()).thenThrow(expectedError);

      // Act
      final call = useCase();

      // Assert
      expect(call, throwsA(isA<Exception>()));
      verify(mockRepository).getEvents();
    });

    test('should filter events by status when provided', () async {
      // Arrange
      final allEvents = [
        EventEntity(id: '1', status: EventStatus.confirmed),
        EventEntity(id: '2', status: EventStatus.quoted),
        EventEntity(id: '3', status: EventStatus.completed),
      ];
      final expectedFiltered = [
        EventEntity(id: '1', status: EventStatus.confirmed),
        EventEntity(id: '3', status: EventStatus.completed),
      ];

      when(mockRepository.getEvents()).thenAnswer((_) async => allEvents);

      // Act
      final result = await useCase(status: EventStatus.confirmed);

      // Assert
      expect(result, equals(expectedFiltered));
    });
  });
}
```

### 2. Unit Test - Utility Function

```dart
// test/unit/utils/currency_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/core/utils/formatters.dart';

void main() {
  group('formatCurrency', () {
    test('should format 1000 as $1,000.00', () {
      const result = formatCurrency(1000);
      expect(result, equals('\$1,000.00'));
    });

    test('should format 0 as $0.00', () {
      const result = formatCurrency(0);
      expect(result, equals('\$0.00'));
    });

    test('should format negative numbers correctly', () {
      const result = formatCurrency(-100);
      expect(result, equals('-\$100.00'));
    });

    test('should format with custom locale', () {
      const result = formatCurrency(1234.56, locale: 'es_MX');
      expect(result, contains('\$1,234'));
    });

    test('should handle null values', () {
      const result = formatCurrency(null);
      expect(result, equals('N/A'));
    });
  });

  group('formatDate', () {
    test('should format date in Spanish', () {
      const date = DateTime(2024, 6, 15);
      const result = formatDate(date, locale: 'es');
      expect(result, contains('15 de junio'));
    });

    test('should format date in English', () {
      const date = DateTime(2024, 6, 15);
      const result = formatDate(date, locale: 'en');
      expect(result, contains('June 15'));
    });
  });
}
```

### 3. Widget Test - Simple Component

```dart
// test/widgets/event_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/features/events/presentation/widgets/event_card.dart';
import 'package:eventosapp/features/events/domain/entities/event_entity.dart';

void main() {
  testWidgets('EventCard displays event information correctly', (WidgetTester tester) async {
    // Arrange
    const event = EventEntity(
      id: '1',
      serviceName: 'Boda',
      eventDate: DateTime(2024, 6, 15),
      status: EventStatus.confirmed,
      totalAmount: 25000.00,
      client: ClientEntity(id: '1', name: 'Juan Pérez'),
    );

    // Act
    await tester.pumpWidget(EventCard(event: event));

    // Assert - Verificar renderizado
    expect(find.text('Boda'), findsOneWidget);
    expect(find.text('15/06/2024'), findsOneWidget);
    expect(find.text('\$25,000.00'), findsOneWidget);
    expect(find.text('Juan Pérez'), findsOneWidget);
    
    // Verificar badge de estado
    expect(find.text('Confirmado'), findsOneWidget);
  });

  testWidgets('EventCard shows correct status color', (WidgetTester tester) async {
    // Test para cada estado
    final statuses = [
      EventStatus.quoted,
      EventStatus.confirmed,
      EventStatus.completed,
      EventStatus.cancelled,
    ];

    for (final status in statuses) {
      final event = EventEntity(
        id: '1',
        serviceName: 'Test',
        eventDate: DateTime.now(),
        status: status,
        totalAmount: 10000,
        client: ClientEntity(id: '1', name: 'Test'),
      );

      await tester.pumpWidget(EventCard(event: event));

      final container = tester.widget<EventCard>(
        find.byType(EventCard),
      );

      // Verificar color según estado
      final colorProperty = container.color;
      switch (status) {
        case EventStatus.confirmed:
          expect(colorProperty, equals(Colors.green));
          break;
        case EventStatus.cancelled:
          expect(colorProperty, equals(Colors.red));
          break;
        default:
          expect(colorProperty, equals(Colors.grey));
      }
    }
  });

  testWidgets('EventCard handles null client gracefully', (WidgetTester tester) async {
    // Arrange
    const event = EventEntity(
      id: '1',
      serviceName: 'Boda',
      eventDate: DateTime(2024, 6, 15),
      status: EventStatus.quoted,
      totalAmount: 10000,
      client: null,
    );

    // Act
    await tester.pumpWidget(EventCard(event: event));

    // Assert - No debe crash
    expect(tester.takeException(), throwsA(isA<FlutterError>()));
  });

  testWidgets('EventCard calls onTap when tapped', (WidgetTester tester) async {
    // Arrange
    var tappedEventId = '';
    const event = EventEntity(
      id: 'test-id',
      serviceName: 'Boda',
      eventDate: DateTime.now(),
      status: EventStatus.confirmed,
      totalAmount: 10000,
      client: ClientEntity(id: '1', name: 'Test'),
    );

    await tester.pumpWidget(
      EventCard(
        event: event,
        onTap: (id) => tappedEventId = id,
      ),
    );

    // Act - Simular tap
    await tester.tap(find.byType(EventCard));

    // Assert
    expect(tappedEventId, equals('test-id'));
  });
}
```

### 4. Widget Test - Form Component

```dart
// test/widgets/currency_input_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/shared/widgets/currency_input.dart';

void main() {
  testWidgets('CurrencyInput displays initial value correctly', (WidgetTester tester) async {
    // Arrange
    const initialValue = 1000.0;
    await tester.pumpWidget(
      CurrencyInput(
        value: initialValue,
        onChanged: (_) {},
      ),
    );

    // Assert
    expect(find.text('\$1,000.00'), findsOneWidget);
  });

  testWidgets('CurrencyInput formats input correctly', (WidgetTester tester) async {
    var lastValue = 0.0;

    await tester.pumpWidget(
      CurrencyInput(
        onChanged: (value) => lastValue = value,
      ),
    );

    // Act - Simular input de texto
    await tester.enterText(find.byType(TextField), '2500');

    // Assert
    expect(lastValue, equals(2500.0));
    expect(find.text('\$2,500.00'), findsOneWidget);
  });

  testWidgets('CurrencyInput validates non-numeric input', (WidgetTester tester) async {
    await tester.pumpWidget(
      CurrencyInput(
        onChanged: (_) {},
      ),
    );

    // Act - Intentar input de texto
    await tester.enterText(find.byType(TextField), 'abc');

    // Assert - No debe cambiar el valor
    expect(find.text('\$0.00'), findsOneWidget);
  });

  testWidgets('CurrencyInput handles disabled state', (WidgetTester tester) async {
    await tester.pumpWidget(
      CurrencyInput(
        value: 1000.0,
        onChanged: (_) {},
        enabled: false,
      ),
    );

    // Assert - Campo debe estar deshabilitado
    final textField = tester.widget<TextField>(
      find.byType(TextField),
    );
    expect(textField.enabled, isFalse);
    expect(textField.decoration?.filled, isTrue);
  });
}
```

### 5. Integration Test - Auth Flow

```dart
// test/integration/auth_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eventosapp/main.dart';
import 'package:mockito/mockito.dart';
import 'package:eventosapp/core/api/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  IntegrationTestWidgets testWidgets('Authentication flow', (tester) async {
    // Arrange - Setup del app con mock
    final mockApiClient = MockApiClient();

    // Mock respuesta de login exitoso
    when(mockApiClient.post(any, any)).thenAnswer(
      (_) async => {
        return {'access_token': 'test-token', 'refresh_token': 'refresh-token'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(
          apiClientOverride: mockApiClient,
        ),
      ),
    );

    // Act - Navegar a login
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    await tester.enterText(
      find.byKey(Key('email-field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(Key('password-field')),
      'password123',
    );
    await tester.tap(find.byType(ElevatedButton));

    await tester.pumpAndSettle();

    // Assert - Debería navegar al dashboard
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);

    // Verify que el mock API fue llamado
    verify(mockApiClient).post(
      '/api/auth/login',
      any,
    );
  });
}
```

### 6. Integration Test - Event Creation Flow

```dart
// test/integration/event_creation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eventosapp/main.dart';

void main() {
  IntegrationTestWidgets('Complete event creation flow', (tester) async {
    // Test 1: Navegar desde dashboard a crear evento
    await tester.pumpWidget(MyApp());
    
    // Debería estar en dashboard
    expect(find.text('Dashboard'), findsOneWidget);
    
    // Tap en botón de crear evento
    await tester.tap(find.text('Nuevo Evento'));
    await tester.pumpAndSettle();

    // Test 2: Verificar formulario de evento
    expect(find.text('Crear Nuevo Evento'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);

    // Test 3: Seleccionar cliente
    await tester.tap(find.text('Seleccionar Cliente'));
    await tester.pumpAndSettle();
    
    // Verificar lista de clientes
    expect(find.text('Juan Pérez'), findsOneWidget);
    await tester.tap(find.text('Juan Pérez'));
    await tester.pumpAndSettle();

    // Test 4: Ingresar datos del evento
    await tester.enterText(find.byKey(Key('service-type')), 'Boda');
    await tester.enterText(find.byKey(Key('event-date')), '15/06/2024');
    await tester.enterText(find.byKey(Key('num-people')), '150');

    // Test 5: Agregar productos
    await tester.tap(find.text('Agregar Productos'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Paquete Boda Premium'));
    await tester.pumpAndSettle();

    // Test 6: Calcular y mostrar total
    final totalText = find.text('\$20,000.00');
    expect(totalText, findsOneWidget);

    // Test 7: Guardar evento
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Assert - Volver al listado y verificar evento creado
    expect(find.text('Boda'), findsOneWidget);
    expect(find.text('15/06/2024'), findsOneWidget);
  });
}
```

---

## 🔧 Setup de Tests

### mockito Configuration

Crear `mockito.yaml` en la raíz del proyecto:

```yaml
# mockito.yaml
mocks:
  - lib/**
```

### test_helper.dart

Crear helper para tests comunes:

```dart
// test/test_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wrapp de MaterialApp para tests
class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
  }
}

/// Crea test widget pump con wrapper
Future<WidgetTester> createTestWidget(Widget widget) async {
  final tester = WidgetTester(child: widget);
  await tester.pump();
  return tester;
}
```

---

## 🎯 Checklist de Testing

### Por Feature

Cada feature debería tener:

#### Auth
- [ ] Login con credenciales válidas
- [ ] Login con credenciales inválidas
- [ ] Login exitoso navega a dashboard
- [ ] Refresh token funciona
- [ ] Logout cierra sesión correctamente
- [ ] Maneja errores de red

#### Events
- [ ] Listado de eventos
- [ ] Filtrado por estado
- [ ] Crear evento vacío
- [ ] Crear evento completo con productos
- [ ] Editar evento existente
- [ ] Eliminar evento con confirmación
- [ ] Validar fecha futura
- [ ] Calcular totales correctamente (subtotal, IVA, total)

#### Clients
- [ ] Listado de clientes
- [ ] Búsqueda de clientes
- [ ] Crear cliente nuevo
- [ ] Editar cliente existente
- [ ] Eliminar cliente con confirmación
- [ ] Ver historial de eventos por cliente

#### Products
- [ ] Listado de productos
- [ ] Crear producto con receta
- [ ] Editar producto
- [ ] Eliminar producto
- [ ] Calcular costo de ingredientes
- [ ] Verificar stock disponible

#### Inventory
- [ ] Listado de inventario
- [ ] Alertas de stock bajo
- [ ] Crear nuevo ítem
- [ ] Editar ítem
- [ ] Actualizar stock
- [ ] Verificar consistencia de unidades

#### Payments
- [ ] Listado de pagos
- [ ] Registrar pago
- [ ] Editar pago
- [ ] Eliminar pago
- [ ] Calcular saldo pendiente
- [ ] Verificar monto no exceda total

---

## 📦 Mocks para Services

### API Client Mock

```dart
// test/mocks/mock_api_client.dart
import 'package:eventosapp/core/api/api_client.dart';
import 'package:mockito/mockito.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  // Ejemplo de uso en tests
  test('should handle network error gracefully', () async {
    final mockClient = MockApiClient();

    when(mockClient.get('/events'))
        .thenThrow(Exception('Network error'));

    final service = EventsService(mockClient);

    expect(
      () => service.getEvents(),
      throwsA(isA<Exception>()),
    );
  });
}
```

### Repository Mock

```dart
// test/mocks/mock_events_repository.dart
import 'package:eventosapp/features/events/domain/repositories/events_repository.dart';
import 'package:mockito/mockito.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  testWidgets('EventListPage handles repository error', (tester) async {
    final mockRepo = MockEventsRepository();
    when(mockRepo.getEvents()).thenThrow(Exception('Database error'));

    await tester.pumpWidget(
      EventsListPage(repository: mockRepo),
    );

    await tester.pumpAndSettle();

    // Debería mostrar mensaje de error
    expect(find.text('Error al cargar eventos'), findsOneWidget);
  });
}
```

---

## 🚀 Scripts de Testing

### En `package.json` del root

```json
{
  "scripts": {
    "test": "flutter test",
    "test:unit": "flutter test test/unit/",
    "test:widget": "flutter test test/widgets/",
    "test:integration": "flutter test test/integration/",
    "test:watch": "flutter test --watch",
    "test:coverage": "flutter test --coverage",
    "test:ci": "flutter test --coverage --no-sound-null-safety"
  }
}
```

---

## 🔍 Debugging Tests

### Mostrar logs de tests

```dart
testWidgets('some test', (tester) async {
  // Habilitar debug prints en tests
  debugPrint('Starting test...');

  await tester.pumpWidget(MyWidget());

  debugPrint('Widget pumped');
  
  // Pausar para ver logs
  await tester.pump(Duration(seconds: 2));
  
  expect(find.text('Expected'), findsOneWidget);
});
```

### Puntos de interrupción

```dart
testWidgets('complex flow', (tester) async {
  await tester.pumpWidget(MyWidget());

  // Punto de interrupción 1
  expect(find.text('Step 1'), findsOneWidget);
  debugPrint('✅ Step 1 verified');
  
  // Pausar para inspección visual
  await tester.pumpAndSettle();
  
  expect(find.byKey(Key('pause-button')), findsOneWidget);
  
  // Punto de interrupción 2
  // ... más código ...
  
  expect(find.text('Success'), findsOneWidget);
});
```

---

## 📊 Métricas de Testing

### Objetivos de Coverage

| Categoría | Coverage Objetivo | Métrica |
|-----------|-------------------|---------|
| Lógica de negocio | 85%+ | % de funciones probadas |
| Repositorios | 75%+ | % de métodos probados |
| UI Widgets | 65%+ | % de estados renderizados |
| Pages completas | 55%+ | % de flujos cubiertos |
| Overall | 70%+ | Coverage general del proyecto |

---

## 🐛 Troubleshooting

### Error: "No tests found"

```bash
# Verificar estructura de directorios
ls -la test/unit test/widget test/integration

# Asegurar que los archivos terminan en _test.dart
```

### Error: "Widget library not found"

```bash
# Agregar dependencia a pubspec.yaml
flutter pub add flutter_test

# O limpiar caché
flutter clean
flutter pub get
```

### Tests muy lentos

```dart
// Usa pumpAndSettle() en lugar de pump() para async operations
await tester.pumpAndSettle();

// O usa pump() con duración específica
await tester.pump(Duration(milliseconds: 100));

// Evita esperar frames innecesarios
tester.binding.scheduleFrame();
await tester.pump(Duration(milliseconds: 50));
```

### Mocks no funcionan

```dart
// Verificar que los mocks implementen todas las interfaces requeridas

class MockApiClient extends Mock implements ApiClient {
  // Implementa todos los métodos de ApiClient
  @override
  Future<Response> get(String path) { /* ... */ }
  
  @override
  Future<Response> post(String path, {Map<String, dynamic>? body}) { /* ... */ }
  
  // ... más métodos
}
```

---

## 📚 Recursos

- [Flutter Testing Documentation](https://docs.flutter.dev/cookbook/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget-introduction)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)

---

Última actualización: 2026-02-17
