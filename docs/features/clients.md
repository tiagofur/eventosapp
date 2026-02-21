# Gestión de Clientes

La base de datos de clientes permite centralizar la información de contacto y el historial de eventos.

## Funcionalidades

- **Registro Detallado:** Almacenamiento de nombre, email, teléfono, dirección y notas.
- **Historial Automático:** Los clientes muestran un resumen de sus eventos pasados y futuros.
- **Estadísticas de Valor:** Visualización de `total_spent` y `total_events` por cliente (calculado mediante triggers en la base de datos).
- **Acceso Rápido:** Búsqueda integrada para encontrar clientes por nombre o contacto.

## Privacidad

Cada organizador solo puede ver y gestionar sus propios clientes. Los datos están aislados por `user_id` a nivel de aplicación.
