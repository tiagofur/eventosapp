# Auditoría y Estado del Proyecto

Este documento resume los hallazgos de la auditoría inicial y el progreso realizado.

## ✅ Logros Recientes

- **Seguridad Sólida:** Validación de ownership en la capa de servicios del backend y frontend.
- **Búsqueda Global:** Implementada en el Layout y página de resultados.
- **Generación de PDFs:** Presupuestos y Contratos disponibles desde el resumen del evento.
- **Sistema de Pagos:** Registro de abonos y seguimiento de saldo pendiente.
- **Estabilidad de Tests:** Suite de tests (Vitest) pasando al 100% (216 tests).
- **Refactorización de Formularios:** Mejora en el rendimiento de `EventForm` eliminando re-renders infinitos.
- **Dark Mode:** Implementación inicial en componentes clave (Layout, Landing, Dashboard).

## 🛠️ Problemas Identificados y Resueltos

1. **Pluralización inconsistente:** Se corrigió el uso de `client` vs `clients` en mocks y servicios.
2. **Ciclos de renderizado:** Se estabilizaron las referencias de funciones en `EventForm.test.tsx`.
3. **Mocks desactualizados:** Se actualizaron los mocks de `AuthContext` y servicios para reflejar el estado actual del API.

## ❌ Pendientes de Alta Prioridad

1. **Notificaciones de Inventario:** Alertas cuando el stock está por debajo del mínimo.
2. **Dashboard Analytics:** Incluir gráficas de ingresos y margen de utilidad por periodo.
3. **Confirmación de Acciones:** Modal de confirmación antes de eliminar registros (clientes, eventos).
4. **Onboarding:** Guía inicial para nuevos usuarios que llegan a un dashboard vacío.
5. **SEO y Metadatos:** Mejorar la indexación y compartición de la Landing Page.

## 🗺️ Roadmap Sugerido

### Fase Actual: Refinamiento de UX

- [ ] Implementar modales de confirmación.
- [ ] Mejorar los "Empty States" con ilustraciones y CTAs.
- [ ] Paginación en listas largas (Clientes, Eventos).

### Fase Siguiente: Monetización y Crecimiento

- [ ] Integración con Stripe para suscripciones.
- [ ] Limites por plan (Básico vs Premium).
- [ ] Sistema de recordatorios automáticos por email.
