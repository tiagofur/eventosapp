# EventosApp Flutter - Documentación Completa

Aplicación móvil Flutter para gestión de eventos, cotizaciones, inventario y pagos.

## 📋 Índice

- [README](./README.md) - Este archivo
- [Arquitectura](./01-architecture.md) - Arquitectura del proyecto
- [Estructura de Directorios](./02-directory-structure.md) - Estructura del código
- [API Endpoints](./03-api-endpoints.md) - Endpoints del backend
- [Modelos de Datos](./04-data-models.md) - Modelos Dart
- [Componentes UI](./05-ui-components.md) - Componentes reutilizables
- [Flujo de Usuario](./06-user-flows.md) - Flujos de usuario
- [Estado y Providers](./07-state-management.md) - State management con Riverpod
- [Generación de PDF](./08-pdf-generation.md) - PDFs de presupuestos y contratos
- [Seguridad](./09-security.md) - Seguridad y autenticación
- [Testing](./10-testing.md) - Estrategia de testing
- [Deployment](./11-deployment.md) - Deployment en stores

## 🎯 Objetivos

Crear la mejor app móvil de gestión de eventos con:

1. **Experiencia móvil nativa** optimizada para iOS y Android
2. **Mejoras de UI/UX** vs la versión web
3. **Offline-first** con sincronización automática
4. **Features móviles específicas**: push notifications, cámara, sharing
5. **Performance** óptima con código nativo

## 🚀 Tecnologías Principales

| Categoría | Tecnología |
|-----------|-----------|
| Framework | Flutter 3.24+ |
| Lenguaje | Dart 3.5+ |
| State Management | Riverpod |
| Arquitectura | Clean Architecture |
| HTTP Client | Dio |
| Storage Local | Hive + Secure Storage |
| Gráficos | FL Chart |
| PDF | Syncfusion PDF |
| Notificaciones | flutter_local_notifications |
| Testing | flutter_test + mockito |

## 📱 Características

- ✅ Autenticación segura con JWT
- ✅ Dashboard con KPIs y gráficos
- ✅ Calendario interactivo
- ✅ Gestión completa de eventos (CRUD)
- ✅ Formulario multi-paso para eventos
- ✅ Gestión de clientes
- ✅ Gestión de productos con recetas
- ✅ Gestión de inventario con alertas
- ✅ Sistema de pagos
- ✅ Generación de PDFs (presupuestos, contratos)
- ✅ Búsqueda global
- ✅ Configuración de app y contratos
- ✅ Dark mode
- ✅ Offline mode con sync
- ✅ Push notifications
- ✅ Compartir archivos

## 🔗 Links Importantes

- **Backend**: `/backend/` - API Go con endpoints REST
- **Web App**: `/web/` - Versión web de referencia
- **Database**: Esquema en `/web/supabase/migrations/`

## 📖 Guía de Inicio Rápido

### Prerrequisitos

- Flutter SDK 3.24+
- Dart 3.5+
- Xcode (para iOS) o Android Studio (para Android)
- Backend corriendo en `http://localhost:8080`

### Instalación

```bash
# Navegar al directorio flutter
cd flutter

# Instalar dependencias
flutter pub get

# Configurar variables de entorno
# Crear lib/config/env.dart con la URL del backend

# Ejecutar en dispositivo o emulador
flutter run
```

### Estructura del Proyecto

Ver [Estructura de Directorios](./02-directory-structure.md) para detalles completos.

## 🤝 Contribución

1. Seguir el patrón Clean Architecture
2. Usar Riverpod para state management
3. Escribir tests para nuevas features
4. Mantener la documentación actualizada
5. Code review obligatorio

## 📄 Licencia

Propiedad de EventosApp. Todos los derechos reservados.
