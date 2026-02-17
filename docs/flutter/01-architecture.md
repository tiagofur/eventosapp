# Arquitectura del Proyecto Flutter

## 📐 Clean Architecture

El proyecto sigue el patrón **Clean Architecture** para mantener separación de responsabilidades y facilitar el testing.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  (Screens, Widgets, Controllers, Riverpod Providers)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│           (Use Cases, Entities, Repository Interfaces)      │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                            │
│       (DTOs, Data Sources, Repository Implementations)      │
└─────────────────────────────────────────────────────────────┘
```

## 🏗️ Capas

### 1. Presentation Layer

**Responsabilidades:**
- Pantallas (Screens)
- Widgets reutilizables
- Controladores de UI
- Riverpod Providers para estado local

**Ubicación:** `lib/features/{feature}/presentation/`

**Componentes:**
- `pages/` - Pantallas completas
- `widgets/` - Componentes UI reutilizables
- `providers/` - Riverpod providers (state management)

### 2. Domain Layer

**Responsabilidades:**
- Entidades del negocio (Entities)
- Casos de uso (Use Cases)
- Interfaces de repositorios (Repository interfaces)

**Ubicación:** `lib/features/{feature}/domain/`

**Componentes:**
- `entities/` - Entidades del dominio (puro Dart)
- `repositories/` - Interfaces abstractas de repositorios
- `usecases/` - Lógica de negocio

### 3. Data Layer

**Responsabilidades:**
- DTOs (Data Transfer Objects)
- Fuentes de datos (Data Sources)
- Implementaciones de repositorios

**Ubicación:** `lib/features/{feature}/data/`

**Componentes:**
- `models/` - DTOs (convertidos de JSON)
- `repositories/` - Implementaciones concretas
- `services/` - Servicios API y storage local

## 📦 Modularización por Features

El proyecto está organizado por **features** (características) independientes:

```
lib/
├── features/
│   ├── auth/                 # Autenticación
│   ├── dashboard/            # Dashboard principal
│   ├── events/               # Gestión de eventos
│   ├── clients/              # Gestión de clientes
│   ├── products/             # Gestión de productos
│   ├── inventory/            # Gestión de inventario
│   ├── search/               # Búsqueda global
│   ├── settings/             # Configuración
│   └── pdf/                  # Generación de PDFs
├── core/                     # Código compartido
│   ├── api/                  # Cliente HTTP
│   ├── storage/              # Storage local
│   └── utils/                # Utilidades
└── shared/                   # Widgets y providers compartidos
```

## 🔄 Flujo de Datos

### Flujo de Lectura (Query)

```
UI (Widget) → Provider (Riverpod) → Use Case → Repository → Data Source → API/Cache
```

**Ejemplo:** Cargar lista de eventos

```dart
// UI
class EventsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    return eventsAsync.when(...);
  }
}

// Provider
final eventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  return ref.watch(getEventsUseCaseProvider)();
});

// Use Case
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventsRepositoryProvider));
});

// Repository
class EventsRepositoryImpl implements EventsRepository {
  @override
  Future<List<Event>> getEvents() {
    return _remoteDataSource.getEvents();
  }
}
```

### Flujo de Escritura (Command)

```
UI (Widget) → Provider (Riverpod) → Use Case → Repository → Data Source → API
                        ↓
                   Update State
```

**Ejemplo:** Crear evento

```dart
// UI
ElevatedButton(
  onPressed: () {
    ref.read(eventFormProvider.notifier).submit();
  },
)

// Provider (StateNotifier)
class EventFormNotifier extends StateNotifier<EventFormState> {
  Future<void> submit() async {
    state = EventFormState.submitting();
    try {
      await ref.watch(createEventUseCaseProvider)(state.event);
      state = EventFormState.success();
    } catch (e) {
      state = EventFormState.error(e.toString());
    }
  }
}
```

## 🔌 Dependency Injection

Usamos **Riverpod** para inyección de dependencias:

```dart
// Repository Provider (Singleton)
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    localDataSource: ref.watch(eventLocalDataSourceProvider),
  );
});

// Use Case Provider (Factory)
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventsRepositoryProvider));
});

// UI Provider (State Management)
final eventsProvider = FutureProvider.autoDispose<List<Event>>((ref) {
  return ref.watch(getEventsUseCaseProvider)();
});
```

## 💾 Caching Strategy

### Two-Level Caching

1. **Memory Cache**: Riverpod (auto-dispose)
2. **Persistent Cache**: Hive (local database)

**Estrategia:**

```dart
// Repository Implementation
class EventsRepositoryImpl implements EventsRepository {
  final ApiClient _apiClient;
  final HiveBox _cache;

  @override
  Future<List<Event>> getEvents() async {
    // 1. Try cache first
    final cached = _cache.get('events');
    if (cached != null) return Event.fromListJson(cached);

    // 2. Fetch from API
    final events = await _apiClient.get('/events');

    // 3. Update cache
    await _cache.put('events', events);

    return events;
  }
}
```

### Cache Invalidation

- **Time-based**: Expirar cache después de X minutos
- **Event-based**: Invalidar al crear/editar eventos
- **Manual**: Pull-to-refresh

## 🌐 API Client Layer

### Dio Interceptors

1. **Auth Interceptor**: Agregar token JWT a las requests
2. **Refresh Token Interceptor**: Renovar token automáticamente
3. **Logging Interceptor**: Log requests/responses (debug only)
4. **Error Interceptor**: Manejo centralizado de errores

```dart
class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      RefreshTokenInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
}
```

## 🔒 Seguridad

### Token Management

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### Refresh Token Flow

```
Request → 401 Error → Refresh Token → Retry Request → Success
                                 ↓
                            Update Tokens
```

## 📊 State Management

### Riverpod Providers

| Tipo de Provider | Uso |
|------------------|-----|
| `Provider` | Dependencies (singletons) |
| `FutureProvider` | Async data (read-only) |
| `AsyncNotifierProvider` | Async data with mutations |
| `StateNotifierProvider` | Complex state with mutations |
| `StreamProvider` | Real-time data streams |

### Ejemplo Completo

```dart
// 1. Repository Provider
final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

// 2. Use Case Provider
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventsRepositoryProvider));
});

// 3. UI Provider con loading/error/data
final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);

class EventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    final useCase = ref.watch(getEventsUseCaseProvider);
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.watch(getEventsUseCaseProvider);
      return useCase();
    });
  }

  Future<void> createEvent(Event event) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.watch(eventsRepositoryProvider);
      await repo.createEvent(event);
      final useCase = ref.watch(getEventsUseCaseProvider);
      return useCase();
    });
  }
}
```

## 🧪 Testing Strategy

### Unit Tests

- Domain Layer: Test use cases con mocks
- Data Layer: Test repositories con mocks de API

### Widget Tests

- Test de widgets aislados
- Test de providers con `ProviderContainer`

### Integration Tests

- Test de flujos completos (screen a screen)
- Mock del backend con `http_mock_adapter`

## 📐 SOLID Principles

### Single Responsibility
Cada clase tiene una única responsabilidad:
- `EventsRepository`: Solo maneja datos de eventos
- `GetEventsUseCase`: Solo obtiene eventos
- `EventsListPage`: Solo muestra eventos

### Open/Closed
Abierto para extensión, cerrado para modificación:
- Nuevas features sin modificar código existente
- Use cases extensibles

### Liskov Substitution
Interfaces pueden ser sustituídas por implementaciones:
- `EventsRepository` → `EventsRepositoryImpl`
- `RemoteDataSource` → `MockDataSource` (testing)

### Interface Segregation
Interfaces específicas y pequeñas:
- `EventsRepository` solo tiene métodos de eventos
- `ClientsRepository` solo tiene métodos de clientes

### Dependency Inversion
Depender de abstracciones, no de implementaciones:
- Use cases dependen de `EventsRepository` (interface)
- No de `EventsRepositoryImpl` (implementation)

## 🚀 Performance Optimizations

1. **Lazy Loading**: Cargar features bajo demanda
2. **AutoDispose**: Liberar memoria de providers no usados
3. **const Constructors**: Widgets inmutables
4. **ListView.builder**: Listas eficientes
5. **Image Caching**: CachedNetworkImage
6. **Isolates**: Procesamiento pesado en background

## 📦 Bundle Size Optimization

1. **Tree Shaking**: Eliminar código no usado
2. **Split by Feature**: Lazy loading de routes
3. **Proguard/R8**: Ofuscar y optimizar (Android)
4. **App Thinning**: Slicing por dispositivo (iOS)

## 🔄 State Synchronization

### Offline-First Pattern

```dart
class SyncManager {
  Future<void> sync() async {
    // 1. Get pending changes
    final pending = await _localDataSource.getPendingChanges();

    // 2. Sync with server
    for (final change in pending) {
      await _apiClient.sync(change);
    }

    // 3. Mark as synced
    await _localDataSource.markAsSynced(pending);

    // 4. Fetch latest data
    await _refreshAllData();
  }
}
```

## 🎯 Conclusión

Esta arquitectura garantiza:

- ✅ **Mantenibilidad**: Código organizado y modular
- ✅ **Testabilidad**: Cada capa testeable de forma aislada
- ✅ **Escalabilidad**: Fácil agregar nuevos features
- ✅ **Performance**: Optimizaciones implementadas
- ✅ **Type Safety**: Dart + Riverpod = tipos estáticos
