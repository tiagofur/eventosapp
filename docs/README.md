# Documentación — EventosApp

## Índice

- [Arquitectura](#arquitectura)
- [Base de datos](#base-de-datos)
- [IVA y facturación](#iva-y-facturación)
- [Actualización de eventos](#actualización-de-eventos)
- [Multi‑usuario (futuro)](#multiusuario-futuro)
- [Despliegue](deploy.md)
- [Checklist MVP](mvp-checklist.md)
- [Pruebas E2E (Playwright)](testing.md)

## Arquitectura

- Frontend: React + TypeScript + Vite
- Estilos: Tailwind CSS
- Backend: Supabase (Auth + Postgres + RLS)

## Base de datos

- Esquema consolidado: [supabase/migrations/20260215000001_consolidated_schema.sql](../supabase/migrations/20260215000001_consolidated_schema.sql)
- Contiene todas las tablas, políticas RLS, triggers y funciones necesarias.

### Tablas principales

- `users`: perfil de usuario y configuración de contratos
- `clients`: clientes por usuario
- `events`: eventos con fecha, horario, impuestos y totales
- `products`: catálogo de productos
- `inventory`: inventario de ingredientes/equipo
- `event_products`: productos por evento
- `event_extras`: extras por evento
- `product_ingredients`: receta por producto

## IVA y facturación

- Cuando `requires_invoice = true`, el IVA se calcula automáticamente en la UI.
- La tasa se controla con `tax_rate` (por defecto 16).
- El resultado se guarda en `tax_amount` y se suma al `total_amount`.

## Actualización de eventos

- Se usa una función SQL transaccional `update_event_items` para reemplazar
  productos y extras en una sola operación, evitando inconsistencias.

## Multi‑usuario (futuro)

Sugerencia de diseño para equipos:

1. Crear `organizations` y `organization_members` con roles.
2. Reemplazar `user_id` por `organization_id` en `clients`, `events`, `products`, `inventory`.
3. RLS basada en membresía de organización.
4. Panel de administración de miembros y roles.
