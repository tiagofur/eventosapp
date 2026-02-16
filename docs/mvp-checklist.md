# Checklist MVP

## Seguridad y datos

- [ ] Ejecutar esquema consolidado en Supabase.
- [ ] Verificar que RLS esté activo en todas las tablas.
- [ ] Confirmar que el RPC `update_event_items` funciona.

## Core del negocio

- [ ] Crear clientes, productos e inventario.
- [ ] Crear eventos con extras y productos.
- [ ] Calcular IVA cuando requiere factura.
- [ ] Ver resumen y contrato.

## UX mínima

- [ ] Flujo de login/registro estable.
- [ ] Recuperación de contraseña.
- [ ] Validaciones básicas en formularios.
- [ ] Mensajes claros al guardar (si aplica).

## Reporte rápido

- [ ] Dashboard con eventos del mes.
- [ ] Calendario mostrando próximos eventos.

## Verificación final

- [ ] Crear evento de prueba y eliminarlo.
- [ ] Editar evento y confirmar que productos/extras se actualizan correctamente.
- [ ] Revisar consistencia de totales.
