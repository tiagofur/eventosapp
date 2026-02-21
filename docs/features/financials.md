# Gestión Financiera

La plataforma ofrece herramientas avanzadas para el control de costos y la automatización de la facturación.

## Reportes de Costos

El sistema calcula automáticamente el costo de cada evento basándose en:

- **Ingredientes:** Basado en las recetas vinculadas a los productos y el costo unitario del inventario.
- **Extras:** Servicios adicionales con sus respectivos costos operativos.

## IVA y Facturación

- **Tasa Configurable:** El usuario puede definir la tasa de IVA (por defecto 16%).
- **Cálculo Automático:** Al marcar "Requiere Factura", el sistema calcula el `tax_amount` y actualiza el `total_amount`.
- **Transparencia:** El desglose es visible tanto en el resumen interno como en los presupuestos generados para clientes.

## Pagos y Abonos

El módulo de pagos permite:

- Registrar múltiples pagos por evento (anticipos, liquidación).
- Ver el estado de la cuenta en tiempo real (Total Cobrado vs Total Pagado).
- Seguimiento visual de saldos pendientes.

## Generación de Documentos

- **Presupuesto (PDF):** Documento formal con desglose de servicios para enviar al cliente.
- **Contrato (PDF):** Generación automática de contrato legal basado en la configuración del usuario (días de cancelación, porcentajes de reembolso).
- **Lista de Compras (PDF):** Agregación de todos los ingredientes necesarios para facilitar la logística.
