# EventosApp Flutter - Documentación Completa

Aplicación móvil Flutter para gestión de eventos, cotizaciones, inventario y pagos.

## 📋 Índice

- [README.md](./README.md) - Archivo principal del proyecto
- [Arquitectura](./docs/flutter/01-architecture.md) - Arquitectura del proyecto Flutter
- [Estructura](./docs/flutter/02-directory-structure.md) - Estructura de directorios
- [API Endpoints](./docs/flutter/03-api-endpoints.md) - Endpoints del backend
- [Data Models](./docs/flutter/04-data-models.md) - Modelos de datos
- [UI Components](./docs/flutter/05-ui-components.md) - Componentes UI reutilizables
- [Roadmap](./docs/flutter/ROADMAP.md) - Plan de desarrollo

## 📋 Descripción

EventosApp es una aplicación móvil Flutter para empresas de gestión de eventos que necesita controlar:

- 👥 **Eventos** - Gestión completa de cotizaciones
- 📅 **Clientes** - Base de datos de clientes con historial
- 📦 **Productos** - Catálogo con recetas y costos
- 📊 **Inventario** - Control de stock con alertas
- 💰 **Pagos** - Seguimiento de pagos y pendientes
- 📄 **Documentos** - Generación de presupuestos en PDF

## 🏗️ Arquitectura

Clean Architecture con Flutter

```
lib/
├── core/              # Configuración, APIs, Almacenamiento
├── shared/            # Widgets compartidos, utilidades
├── features/          # Features del negocio
│   ├── auth/           # Autenticación
│   ├── dashboard/        # Dashboard y KPIs
│   ├── events/           # Gestión de eventos
│   ├── clients/          # Gestión de clientes
│   ├── products/         # Catálogo de productos
│   ├── inventory/        # Gestión de inventario
│   ├── search/           # Búsqueda global
│   ├── pdf/              # Generación de PDFs
│   └── settings/         # Configuración de la app
└── config/            # Configuración de la app
└── utils/             # Utilidades compartidas
```

## 🛠 Stack Tecnológico

**Framework:**
- Flutter 3.24+
- Dart 3.5+

**State Management:**
- Riverpod AsyncNotifier

**Routing:**
- go_router

**HTTP Client:**
- Dio

**Storage:**
- Hive (local)
- flutter_secure_storage (sensible)

**Date Formatting:**
- intl

**Charts:**
- FL Chart

**PDF Generation:**
- syncfusion_pdf (opcional)

## 📂 Estructura del Proyecto

```
eventosapp/flutter/
├── lib/
│   ├── core/
│   │   ├── api/
│   │   │   └── api_client.dart
│   │   ├── storage/
│   │   │   ├── hive_init.dart
│   │   │   ├── secure_storage.dart
│   │   ├── config/
│   │   │   └── api_config.dart
│   │   ├── constants/
│   │   └── theme.dart
│   │   └── app_theme.dart
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   └── status_badge.dart
│   │   │   ├── empty_state_widget.dart
│   │   ├── providers/
│   │   │   └── api_client_provider.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   │   └── data_sources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   └── login_page.dart
│   │   │   │   ├── splash_page.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   │   └── auth_state.dart
│   │   ├── dashboard/
│   │   ├── events/
│   │   ├── clients/
│   │   ├── products/
│   │   ├── inventory/
│   └── config/
├── main.dart
```

## 🚀 Quick Start

### Prerrequisitos

- Flutter 3.24+ y Dart 3.5+
- Xcode (para macOS) o Android Studio (para Android)
- Emulador iOS (opcional para push notifications)
- Docker y PostgreSQL 15+ (opcional para backend)

### Instalación

1. **Clonar el repositorio:**
```bash
git clone https://github.com/tuusuario/eventosapp.git
cd eventosapp
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Configurar variables de entorno:**
```bash
# En Android Studio: lib/main.dart (para local development)
# En iOS: lib/main.dart (para local development)
# Para producción: lib/config/api_config.dart
```

4. **Ejecutar la aplicación:**
```bash
flutter run
```

## 📚 Características

### Gestión de Eventos

- ✅ Crear y gestionar cotizaciones
- ✅ Múltiples estados: Cotizado, Confirmado, Completado, Cancelado
- ✅ Asignar productos y extras a cada evento
- ✅ Calcular totales con IVA opcional
- ✅ Seguimiento de pagos y depósitos

### Gestión de Clientes

- ✅ Base de datos de clientes
- ✅ Historial de eventos por cliente
- ✅ Información de contacto: teléfono, email, dirección
- ✅ Información de empresa y RFC

### Productos e Inventario

- ✅ Catálogo de productos con precios
- ✅ Recetas/ingredientes por producto con costos
- ✅ Control de inventario con alertas de bajo stock
- ✅ Proveedores e precios de venta

### Documentos

- ✅ Generación de PDF de presupuestos
- ✅ Generación de PDF de contratos
- ✅ Personalización con datos del negocio

### Dashboard

- ✅ Métricas de ventas
- ✅ Eventos próximos
- ✅ Alertas de inventario
- ✅ Gráficos de rendimiento

## 🎯 Roadmap

### Fases Completadas

- ✅ Fase 1: Setup y Autenticación
- ✅ Fase 2: Dashboard con KPIs
- ✅ Fase 3: Dashboard enriquecido con Revenue Charts
- ✅ Fase 4: Clientes (listado, búsqueda, detalle, formulario multi-step)
- ✅ Fase 5: Productos (catálogo, filtros, recetas, stock, proveedores)
- ✅ Fase 6: Inventario (por evento, ajustes, alertas de bajo stock)

### Pendientes (Fases 7+)

- 🔜 Fase 7: Búsqueda global
- 🔜 Fase 8: Calendario interactivo (drag & drop para cotizaciones)
- 🔜 Fase 9: Sistema de Notificaciones Push
- 🔜 Fase 10: Integración con pasarelas de pago (Stripe, MercadoPago)
- 🔜 Fase 11: Reportes avanzados (financieros, métricas detalladas)
- 🔜 Fase 12: App móvil nativa (performance, UI nativo)
- 🔜 Fase 13: API pública para partners
- 🔜 Fase 14: Modo administrativo
- 🔜 Fase 15: Actualización automática de precios de productos

## 🔧 Configuración

### API Backend

Configurar la URL del backend en `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static String get baseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static String get wsUrl => const String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8080',
  );
}
```

### Firebase (Opcional)

Para habilitar notificaciones push y backend real:

1. Crear proyecto en Firebase
2. Descargar `google-services.json`
3. Agregar Android/iOS app
4. Configurar Flutter con Firebase
5. Copiar `google-services.json` en `android/app/` o `ios/Runner/`

## 🧪 Testing

### Unit Tests

```bash
# Ejecutar tests unitarios
flutter test
```

### Widget Tests

```bash
# Ejecutar tests de widgets
flutter test --tags widget
```

### Integration Tests

```bash
# Ejecutar tests de integración
flutter test --tags integration
```

## 🚀 Deployment

### Preparación

1. Android:
   ```bash
   flutter build apk --release
   ```

2. iOS:
   ```bash
   flutter build ios --release
   ```

3. Firebase:
   - Subir APK/IPA a Firebase Console
   - Configurar Firebase Crashlytics

4. Web (opcional):
   ```bash
   flutter build web
   ```

## 📄 Documentación

### Flutter
- [Arquitectura](./docs/flutter/01-architecture.md) - Arquitectura del proyecto Flutter
- [Estructura](./docs/flutter/02-directory-structure.md) - Estructura de directorios
- [API Endpoints](./docs/flutter/03-api-endpoints.md) - Endpoints del backend
- [Data Models](./docs/flutter/04-data-models.md) - Modelos de datos
- [UI Components](./docs/flutter/05-ui-components.md) - Componentes UI reutilizables
- [Roadmap](./docs/flutter/ROADMAP.md) - Plan de desarrollo

### General
- [Documentación del Sistema](./docs/README.md) - Documentación general de EventosApp
- [Guía de Despliegue](./docs/deploy.md) - Guía completa de despliegue
- [Testing](./docs/testing.md) - Pruebas E2E
- [Checklist MVP](./docs/mvp-checklist.md) - Verificación del MVP
- [Mejoras](./docs/mejoras.md) - Auditoría y mejoras sugeridas

## 🔒 Seguridad

La aplicación implementa múltiples capas de seguridad:

- JWT Authentication con expiración
- Passwords hasheados con bcrypt
- Todas las queries filtran por usuario
- HTTPS en producción
- Input validation en frontend y backend
- Secure Storage para tokens de autenticación

## 📄 Contribuir

Las contribuciones son bienvenidas. Por favor lee [CONTRIBUTING.md](../CONTRIBUTING.md) para detalles sobre cómo contribuir.

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](../LICENSE) para detalles.

## 🤝 Soporte

Si tienes preguntas o problemas:

1. Revisa la [documentación](./docs/flutter/README.md)
2. Busca en [Issues](../../issues)
3. Crea un nuevo issue con detalles del problema
