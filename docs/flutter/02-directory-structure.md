# Estructura de Directorios

Estructura completa del proyecto Flutter siguiendo Clean Architecture.

## 📁 Árbol de Directorios

```
flutter/
├── lib/
│   ├── main.dart                        # Punto de entrada
│   ├── app.dart                         # Configuración de la app
│   │
│   ├── config/                          # Configuración global
│   │   ├── api_config.dart              # Configuración de API
│   │   ├── theme.dart                   # Tema de la app
│   │   └── constants.dart               # Constantes globales
│   │
│   ├── core/                            # Código compartido core
│   │   ├── api/                         # Cliente HTTP
│   │   │   ├── api_client.dart          # Cliente Dio
│   │   │   ├── api_exception.dart       # Excepciones personalizadas
│   │   │   └── interceptors/            # Interceptors de Dio
│   │   │       ├── auth_interceptor.dart
│   │   │       ├── refresh_token_interceptor.dart
│   │   │       ├── logging_interceptor.dart
│   │   │       └── error_interceptor.dart
│   │   │
│   │   ├── storage/                     # Storage local
│   │   │   ├── secure_storage.dart     # Secure storage (tokens)
│   │   │   ├── local_storage.dart      # Local storage (Hive)
│   │   │   └── cache_manager.dart      # Manager de caché
│   │   │
│   │   └── utils/                       # Utilidades
│   │       ├── formatters.dart          # Formateadores (fecha, moneda)
│   │       ├── validators.dart         # Validaciones
│   │       ├── extensions.dart          # Extensiones de Dart
│   │       └── helpers.dart             # Helpers varios
│   │
│   ├── features/                        # Features del negocio
│   │   │
│   │   ├── auth/                        # 📱 Autenticación
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   ├── auth_response_model.dart
│   │   │   │   │   └── tokens_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   ├── data_sources/
│   │   │   │   │   ├── auth_remote_data_source.dart
│   │   │   │   │   └── auth_local_data_source.dart
│   │   │   │   └── services/
│   │   │   │       └── auth_api_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── auth_provider.dart
│   │   │   │   │   └── auth_state.dart
│   │   │   │   └── pages/
│   │   │   │       ├── login_page.dart
│   │   │   │       ├── register_page.dart
│   │   │   │       └── forgot_password_page.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── user_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── auth_repository.dart
│   │   │       └── usecases/
│   │   │           ├── login_usecase.dart
│   │   │           ├── register_usecase.dart
│   │   │           ├── logout_usecase.dart
│   │   │           └── get_current_user_usecase.dart
│   │   │
│   │   ├── dashboard/                   # 📊 Dashboard
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── dashboard_stats_model.dart
│   │   │   │   │   └── upcoming_event_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── dashboard_repository_impl.dart
│   │   │   │   └── data_sources/
│   │   │   │       └── dashboard_remote_data_source.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── dashboard_provider.dart
│   │   │   │   │   └── dashboard_state.dart
│   │   │   │   ├── pages/
│   │   │   │   │   └── dashboard_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── kpi_cards.dart
│   │   │   │       ├── events_chart.dart
│   │   │   │       ├── upcoming_events_list.dart
│   │   │   │       └── inventory_alerts.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── dashboard_stats_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── dashboard_repository.dart
│   │   │       └── usecases/
│   │   │           └── get_dashboard_stats_usecase.dart
│   │   │
│   │   ├── events/                      # 📅 Eventos
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── event_model.dart
│   │   │   │   │   ├── event_product_model.dart
│   │   │   │   │   ├── event_extra_model.dart
│   │   │   │   │   └── payment_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── events_repository_impl.dart
│   │   │   │   ├── data_sources/
│   │   │   │   │   ├── events_remote_data_source.dart
│   │   │   │   │   └── events_local_data_source.dart
│   │   │   │   └── services/
│   │   │   │       └── events_api_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── events_provider.dart
│   │   │   │   │   ├── events_state.dart
│   │   │   │   │   ├── event_form_provider.dart
│   │   │   │   │   ├── event_form_state.dart
│   │   │   │   │   └── payments_provider.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── events_list_page.dart
│   │   │   │   │   ├── event_form_page.dart
│   │   │   │   │   ├── event_detail_page.dart
│   │   │   │   │   └── calendar_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── event_card.dart
│   │   │   │       ├── event_calendar.dart
│   │   │   │       ├── event_stepper.dart
│   │   │   │       ├── event_products_selector.dart
│   │   │   │       ├── event_extras_selector.dart
│   │   │   │       ├── event_financial_calculator.dart
│   │   │   │       ├── payments_list.dart
│   │   │   │       ├── payment_form.dart
│   │   │   │       ├── ingredients_summary.dart
│   │   │   │       └── event_status_badge.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   ├── event_entity.dart
│   │   │       │   ├── event_product_entity.dart
│   │   │       │   ├── event_extra_entity.dart
│   │   │       │   └── payment_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── events_repository.dart
│   │   │       └── usecases/
│   │   │           ├── get_events_usecase.dart
│   │   │           ├── get_event_by_id_usecase.dart
│   │   │           ├── create_event_usecase.dart
│   │   │           ├── update_event_usecase.dart
│   │   │           ├── delete_event_usecase.dart
│   │   │           ├── get_events_by_date_range_usecase.dart
│   │   │           ├── add_payment_usecase.dart
│   │   │           ├── get_payments_usecase.dart
│   │   │           └── delete_payment_usecase.dart
│   │   │
│   │   ├── clients/                     # 👥 Clientes
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── client_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── clients_repository_impl.dart
│   │   │   │   ├── data_sources/
│   │   │   │   │   ├── clients_remote_data_source.dart
│   │   │   │   │   └── clients_local_data_source.dart
│   │   │   │   └── services/
│   │   │   │       └── clients_api_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── clients_provider.dart
│   │   │   │   │   ├── clients_state.dart
│   │   │   │   │   └── client_form_provider.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── clients_list_page.dart
│   │   │   │   │   ├── client_form_page.dart
│   │   │   │   │   └── client_detail_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── client_card.dart
│   │   │   │       ├── client_search.dart
│   │   │   │       └── client_stats.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── client_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── clients_repository.dart
│   │   │       └── usecases/
│   │   │           ├── get_clients_usecase.dart
│   │   │           ├── get_client_by_id_usecase.dart
│   │   │           ├── create_client_usecase.dart
│   │   │           ├── update_client_usecase.dart
│   │   │           └── delete_client_usecase.dart
│   │   │
│   │   ├── products/                    # 📦 Productos
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── product_model.dart
│   │   │   │   │   └── ingredient_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── products_repository_impl.dart
│   │   │   │   ├── data_sources/
│   │   │   │   │   ├── products_remote_data_source.dart
│   │   │   │   │   └── products_local_data_source.dart
│   │   │   │   └── services/
│   │   │   │       └── products_api_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── products_provider.dart
│   │   │   │   │   ├── products_state.dart
│   │   │   │   │   └── product_form_provider.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── products_list_page.dart
│   │   │   │   │   ├── product_form_page.dart
│   │   │   │   │   └── product_detail_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── product_card.dart
│   │   │   │       ├── ingredients_selector.dart
│   │   │   │       └── product_stats.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   ├── product_entity.dart
│   │   │       │   └── ingredient_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── products_repository.dart
│   │   │       └── usecases/
│   │   │           ├── get_products_usecase.dart
│   │   │           ├── get_product_by_id_usecase.dart
│   │   │           ├── create_product_usecase.dart
│   │   │           ├── update_product_usecase.dart
│   │   │           ├── delete_product_usecase.dart
│   │   │           ├── add_ingredient_usecase.dart
│   │   │           └── get_ingredients_usecase.dart
│   │   │
│   │   ├── inventory/                   # 📦 Inventario
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── inventory_item_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── inventory_repository_impl.dart
│   │   │   │   ├── data_sources/
│   │   │   │   │   ├── inventory_remote_data_source.dart
│   │   │   │   │   └── inventory_local_data_source.dart
│   │   │   │   └── services/
│   │   │   │       └── inventory_api_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── inventory_provider.dart
│   │   │   │   │   ├── inventory_state.dart
│   │   │   │   │   └── inventory_form_provider.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── inventory_list_page.dart
│   │   │   │   │   └── inventory_form_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── inventory_card.dart
│   │   │   │       ├── stock_indicator.dart
│   │   │   │       └── low_stock_alert.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── inventory_item_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── inventory_repository.dart
│   │   │       └── usecases/
│   │   │           ├── get_inventory_usecase.dart
│   │   │           ├── get_inventory_item_by_id_usecase.dart
│   │   │           ├── create_inventory_item_usecase.dart
│   │   │           ├── update_inventory_item_usecase.dart
│   │   │           ├── delete_inventory_item_usecase.dart
│   │   │           └── get_low_stock_items_usecase.dart
│   │   │
│   │   ├── search/                      # 🔍 Búsqueda
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── search_result_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── search_repository_impl.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── search_provider.dart
│   │   │   │   │   └── search_state.dart
│   │   │   │   ├── pages/
│   │   │   │   │   └── search_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── search_result_card.dart
│   │   │   │       └── search_filter_chip.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── search_result_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── search_repository.dart
│   │   │       └── usecases/
│   │   │           └── search_usecase.dart
│   │   │
│   │   ├── settings/                    # ⚙️ Configuración
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── settings_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── settings_repository_impl.dart
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   │   ├── settings_provider.dart
│   │   │   │   │   ├── settings_state.dart
│   │   │   │   │   └── profile_provider.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── settings_page.dart
│   │   │   │   │   ├── profile_settings_page.dart
│   │   │   │   │   ├── contract_settings_page.dart
│   │   │   │   │   └── app_settings_page.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── settings_tile.dart
│   │   │   │       ├── theme_selector.dart
│   │   │   │       └── language_selector.dart
│   │   │   └── domain/
│   │   │       ├── entities/
│   │   │       │   └── settings_entity.dart
│   │   │       ├── repositories/
│   │   │       │   └── settings_repository.dart
│   │   │       └── usecases/
│   │   │           ├── get_settings_usecase.dart
│   │   │           ├── update_settings_usecase.dart
│   │   │           ├── update_profile_usecase.dart
│   │   │           └── logout_usecase.dart
│   │   │
│   │   └── pdf/                         # 📄 PDFs
│   │       ├── data/
│   │       │   ├── services/
│   │       │   │   ├── budget_pdf_generator.dart
│   │       │   │   └── contract_pdf_generator.dart
│   │       │   └── models/
│   │       │       └── pdf_options_model.dart
│   │       ├── presentation/
│   │       │   ├── pages/
│   │       │   │   └── pdf_preview_page.dart
│   │       │   └── widgets/
│   │       │       └── pdf_share_sheet.dart
│   │       └── domain/
│   │           └── usecases/
│   │               ├── generate_budget_pdf_usecase.dart
│   │               └── generate_contract_pdf_usecase.dart
│   │
│   ├── shared/                          # Componentes compartidos
│   │   ├── widgets/
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── custom_bottom_nav.dart
│   │   │   ├── custom_scaffold.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── search_field.dart
│   │   │   ├── currency_input.dart
│   │   │   ├── date_picker_field.dart
│   │   │   ├── time_picker_field.dart
│   │   │   ├── dropdown_field.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── confirm_dialog.dart
│   │   │   ├── action_sheet.dart
│   │   │   └── refresh_indicator.dart
│   │   ├── models/
│   │   │   └── base_model.dart
│   │   └── providers/
│   │       ├── app_provider.dart
│   │       ├── theme_provider.dart
│   │       └── locale_provider.dart
│   │
│   └── l10n/                            # Internacionalización
│       ├── app_es.arb                   # Español
│       └── app_en.arb                   # Inglés
│
├── test/                                 # Tests
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── android/                             # Configuración Android
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── kotlin/
│   │   └── build.gradle
│   └── build.gradle
│
├── ios/                                 # Configuración iOS
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   └── Assets.xcassets
│   └── Podfile
│
├── pubspec.yaml                         # Dependencias
├── analysis_options.yaml                 # Configuración de linter
├── README.md
└── docs/                                # Documentación adicional
```

## 📝 Convenciones de Nombres

### Archivos

- **lowercase_with_underscores**: `event_form_page.dart`
- **provider files**: `*_provider.dart`
- **state files**: `*_state.dart`
- **entity files**: `*_entity.dart`
- **model files**: `*_model.dart`
- **use case files**: `*_usecase.dart`

### Clases

- **PascalCase**: `EventFormPage`, `EventFormProvider`
- **Entities**: `EventEntity`, `ClientEntity`
- **Models**: `EventModel`, `ClientModel`
- **Use Cases**: `GetEventsUseCase`, `CreateEventUseCase`

### Variables/Métodos

- **camelCase**: `userName`, `getEvents()`
- **Privados**: `_userName`, `_getEvents()`
- **Constantes**: `const MAX_EVENTS = 100`, `static const String kBaseUrl`

## 🔀 Import Statements

```dart
// 1. Dart core
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. External packages
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Internal packages (core)
import 'package:eventosapp/core/api/api_client.dart';
import 'package:eventosapp/core/utils/formatters.dart';

// 5. Internal packages (features)
import 'package:eventosapp/features/events/domain/entities/event_entity.dart';
import 'package:eventosapp/features/events/domain/usecases/get_events_usecase.dart';

// 6. Internal packages (shared)
import 'package:eventosapp/shared/widgets/loading_widget.dart';
```

## 📦 Archivos de Configuración

### pubspec.yaml

```yaml
name: eventosapp
description: App móvil de gestión de eventos
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # HTTP
  dio: ^5.4.0
  json_annotation: ^4.8.1

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # UI
  fl_chart: ^0.66.0
  syncfusion_flutter_pdf: ^24.1.41
  intl: ^0.18.1
  cupertino_icons: ^1.0.6
  lucide_icons: ^0.277.0

  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0

  # Utilities
  image_picker: ^1.0.5
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  flutter_slidable: ^3.0.1
  pull_to_refresh: ^2.0.0
  infinite_scroll_pagination: ^4.0.0

  # Notifications
  flutter_local_notifications: ^16.3.0

  # Location & Maps
  geolocator: ^10.1.0
  geocoding: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  mockito: ^5.4.4

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

## 🎯 Patrones de Organización

### Por Feature vs Por Capa

Este proyecto usa **organización por feature** porque:

✅ **Cohesión**: Código relacionado está cerca
✅ **Escalabilidad**: Fácil agregar nuevos features
✅ **Mantenibilidad**: Cambios localizados en un feature
✅ **Lazy Loading**: Posible cargar features bajo demanda

### Layer Separation

Cada feature mantiene separación de capas:

```
feature/
├── data/          # Solo conoce a data sources
├── domain/         # Solo conoce entities y repos
└── presentation/   # Solo conoce a domain y shared
```

### Dependencies

- **Domain Layer**: No depende de nada más
- **Data Layer**: Depende solo de Domain
- **Presentation Layer**: Depende de Domain y Shared

## 🚀 Comandos de Desarrollo

```bash
# Crear nueva estructura
flutter create --org com.eventosapp eventosapp

# Crear directorio de feature
mkdir -p lib/features/new_feature/{data,domain,presentation}/{models,repositories,usecases,pages,widgets}

# Ejecutar code generation
flutter pub run build_runner build

# Ejecutar tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```
