# PRD Unificado: Solennix — Plataforma de Gestion de Eventos Multi-Plataforma

**Version:** 1.0
**Fecha:** 2026-03-20
**Autor:** Tiago David + Claude Code
**Estado:** Draft
**Plataformas:** iOS, Android, Web, Backend (Go)

---

## 1. Problema

Los organizadores de eventos en Latinoamerica — banqueteros, decoradores, wedding planners, coordinadores de fiestas infantiles — pierden un promedio de **3+ horas diarias** gestionando su negocio con herramientas fragmentadas:

- **WhatsApp** para recibir solicitudes de cotizacion, negociar precios y confirmar detalles con clientes
- **Excel o Google Sheets** para llevar finanzas, calcular costos de ingredientes y rastrear pagos parciales
- **Libretas de papel** para inventario de equipos (mesas, sillas, manteles, vajilla) y suministros
- **Google Calendar** para agendar eventos y bloquear fechas no disponibles
- **Word o Canva** para generar cotizaciones, contratos y listas de compras
- **La calculadora del telefono** para sumar IVA, aplicar descuentos y calcular margenes de ganancia

**El resultado:** Errores de cotizacion, doble-reservacion de fechas, equipo prometido a dos eventos el mismo dia, pagos perdidos, y clientes frustrados por la falta de profesionalismo.

**Ninguna herramienta integrada existe que entienda las necesidades especificas de LATAM:**

1. **IVA y facturacion regional** — Manejo de impuestos configurables por evento, opcion de facturacion
2. **Precios en moneda local** — Soporte para pesos mexicanos, reales brasileños, pesos colombianos con Stripe regional
3. **Idioma nativo** — Interfaz completa en español (y portugues futuro), no traducciones genericas de apps en ingles
4. **Flujo de trabajo real** — Cotizar → confirmar → cobrar anticipo → ejecutar → cobrar saldo → cerrar; no un flujo generico de "project management"
5. **Catalogo con costos** — Los organizadores necesitan saber su margen real por producto, no solo el precio de venta

**La oportunidad:** Solennix es la primera plataforma SaaS multi-plataforma diseñada desde cero para organizadores de eventos en LATAM. Reemplaza 6+ herramientas con una sola app que entiende el negocio de eventos: desde la cotizacion rapida por WhatsApp hasta el cierre financiero con reporte de pagos.

---

## 2. Vision

> **"Solennix es el centro de comando para organizadores de eventos."**
>
> Una plataforma donde cotizas en segundos, gestionas tu catalogo con costos reales, controlas tu inventario, rastreas cada pago, y generas documentos profesionales — todo desde tu iPhone, Android o navegador web, con los datos siempre sincronizados.

El nombre "Solennix" evoca solemnidad y celebracion — profesional pero festivo, memorable y unico en un mercado lleno de nombres genericos como "Event Planner Pro" y "Party Manager."

---

## 3. Disponibilidad

| Plataforma | Stack | Estado |
|------------|-------|--------|
| **iOS (iPhone/iPad)** | SwiftUI + MVVM + Swift Packages | En desarrollo |
| **Android (Phone/Tablet)** | Kotlin + Jetpack Compose + Multi-module | En desarrollo |
| **Web** | React + TypeScript + Vite | En desarrollo |
| **Backend** | Go (Chi) + PostgreSQL + Stripe | En desarrollo |
| **Widgets iOS** | WidgetKit + Live Activity | En desarrollo |
| **Widgets Android** | Glance (Jetpack Compose) | Planificado |

---

## 4. Objetivos

| # | Objetivo | Metrica |
|---|----------|---------|
| **G1** | **Ser LA app de gestion de eventos para LATAM** — Solennix debe sentirse como una herramienta hecha por y para organizadores latinos | App Store rating >= 4.7; Play Store rating >= 4.5; Top 10 en categoria Negocios en Mexico y Colombia dentro de 12 meses |
| **G2** | **Eliminar la fragmentacion de herramientas** — Un organizador debe poder gestionar todo su negocio sin salir de Solennix | >= 80% de usuarios activos usan 3+ modulos (eventos, clientes, productos/inventario) semanalmente |
| **G3** | **Reducir el tiempo de cotizacion de 30 minutos a 3 minutos** — Cotizacion rapida con catalogo de precios, IVA automatico y descuentos en un flujo guiado | Tiempo promedio de creacion de evento < 5 minutos; uso de cotizacion rapida >= 40% de eventos creados |
| **G4** | **Conversion premium a traves de valor innegable** — Los usuarios pagan porque el tier gratuito ya los convencio | Conversion a plan de pago >= 10%; ARPU >= $4 USD/mes; churn mensual < 5% |
| **G5** | **Cero perdidas por errores administrativos** — Ningun pago olvidado, ningun equipo doble-reservado, ningun evento sin confirmar | >= 95% de eventos con pagos registrados; deteccion de conflictos de equipo en 100% de asignaciones |
| **G6** | **Paridad cross-platform** — Misma funcionalidad core en iOS, Android y Web | 100% de features P0 disponibles en las tres plataformas simultaneamente; bugs corregidos en una plataforma verificados en las otras |
| **G7** | **Documentos profesionales en un tap** — PDFs de cotizacion, contrato, checklist y reporte de pagos con branding del negocio | >= 70% de eventos confirmados generan al menos un PDF; tiempo de generacion < 3 segundos |

---

## 5. No-Objetivos

| # | No-Objetivo | Razon |
|---|-------------|-------|
| **NG1** | **Sin marketplace de servicios** | Solennix es una herramienta de gestion, no un directorio para que clientes finales busquen organizadores. La adquisicion de clientes es responsabilidad del organizador |
| **NG2** | **Sin generacion de contenido por IA** | No generamos diseños de decoracion, menus sugeridos ni textos de contrato automaticos. El conocimiento del negocio es del organizador; Solennix lo organiza |
| **NG3** | **Sin CRM B2B ni gestion de equipos** | El usuario objetivo es el organizador independiente o negocio pequeño (1-5 personas). Features de equipo, roles y permisos multiples son una iniciativa futura separada |
| **NG4** | **Sin gestion de venue/salon** | No administramos espacios fisicos (reservas de salon, layouts, capacidad). Nos integramos con la ubicacion del evento como campo de texto, no como entidad gestionada |
| **NG5** | **Sin project management generico** | No somos Trello, Asana ni Monday. El flujo de trabajo esta optimizado para el ciclo de vida de un evento (cotizar → confirmar → ejecutar → cerrar), no para proyectos genericos con Kanban |
| **NG6** | **Sin integracion con redes sociales** | No publicamos en Instagram, no gestionamos leads de Facebook Ads, no sincronizamos con TikTok. Las redes son canal de marketing del organizador, fuera del scope de Solennix |

---

## 6. Usuarios Objetivo

### P0 — Core (Lanzamiento)

| Segmento | Descripcion | Plataformas |
|----------|-------------|-------------|
| **Banqueteros / Catering** | Gestionan menus con ingredientes, necesitan calcular costos por persona, rastrear inventario de suministros y equipo de cocina | iOS, Android, Web |
| **Decoradores de eventos** | Manejan catalogo de servicios de decoracion, inventario de materiales (telas, flores, globos, iluminacion), multiples eventos por semana | iOS, Android, Web |
| **Wedding planners** | Eventos de alto valor con multiples pagos parciales, contratos formales, listas de proveedores y checklists detallados | iOS, Android, Web |
| **Organizadores de fiestas infantiles** | Alto volumen de eventos, catalogo de paquetes predefinidos, equipo reutilizable (inflables, mobiliario, vajilla tematica) | iOS, Android |

### P1 — Expansion

| Segmento | Descripcion | Plataformas |
|----------|-------------|-------------|
| **Coordinadores corporativos** | Eventos empresariales, conferencias, team buildings; presupuestos mas altos, necesidad de facturacion formal | Web, iOS, Android |
| **Floristias y pastelerias de eventos** | Negocio de producto con componente de servicio; necesitan recetas con costeo de ingredientes y control de inventario | iOS, Android, Web |
| **Organizadores de XV años / quinceañeras** | Eventos culturalmente significativos en Mexico y Centroamerica; alta demanda estacional, paquetes complejos | iOS, Android |

### P2 — Futuro

| Segmento | Descripcion | Plataformas |
|----------|-------------|-------------|
| **Agencias de eventos medianas (5-15 personas)** | Necesitan roles, permisos y vista de equipo; requiere features B2B futuros | Web, iOS, Android |
| **Organizadores en Brasil** | Segundo mercado mas grande de LATAM; requiere localizacion a portugues y adaptacion fiscal | iOS, Android, Web |

---

## 7. Tipos de Evento Soportados

| Tipo de evento | Catalogo de productos | Inventario / Equipo | Suministros | Pagos parciales | Contrato PDF | Fotos |
|---------------|----------------------|---------------------|-------------|-----------------|-------------|-------|
| **Fiestas infantiles** | Si | Si (inflables, mesas, sillas) | Si (desechables, globos) | Si | Opcional | Si |
| **Bodas** | Si | Si (mobiliario, iluminacion) | Si (flores, telas) | Si (anticipo + saldos) | Si | Si |
| **XV años / Quinceañeras** | Si | Si (decoracion, audio) | Si | Si | Si | Si |
| **Eventos corporativos** | Si | Si (equipo AV, mobiliario) | Si (papeleria, gafetes) | Si | Si (con factura) | Si |
| **Baby showers** | Si | Si (mobiliario tematico) | Si (decoracion) | Si | Opcional | Si |
| **Bautizos / Primera comunion** | Si | Si | Si | Si | Opcional | Si |
| **Graduaciones** | Si | Si | Si | Si | Opcional | Si |
| **Banquetes / Catering** | Si (menus con recetas) | Si (equipo de cocina, vajilla) | Si (ingredientes) | Si | Si | Si |
| **Despedidas de soltero/a** | Si | Si | Si | Si | Opcional | Si |
| **Eventos sociales genericos** | Si | Si | Si | Si | Opcional | Si |

> **Nota:** El campo `service_type` en el modelo de evento es de texto libre, permitiendo al organizador definir cualquier tipo de evento. La tabla anterior muestra los tipos mas comunes con sus features aplicables.

---

## 8. Historias de Usuario

### 8.1 Gestion de Eventos

| ID | Historia | Plataforma |
|----|----------|------------|
| US-1 | Como organizador de fiestas, quiero crear un evento en un formulario guiado por pasos (datos generales → productos → equipo/suministros → resumen) para no olvidar ningun detalle de la cotizacion. | [Todas] |
| US-2 | Como banquetera, quiero seleccionar productos de mi catalogo al crear un evento y que el precio total se calcule automaticamente con IVA y descuentos para entregar una cotizacion precisa en minutos. | [Todas] |
| US-3 | Como wedding planner, quiero cambiar el estado de un evento (cotizado → confirmado → completado → cancelado) para rastrear en que fase esta cada evento de mi agenda. | [Todas] |
| US-4 | Como decoradora, quiero ver los conflictos de equipo cuando asigno mobiliario a un evento para evitar prometer las mismas sillas a dos fiestas el mismo dia. | [Todas] |
| US-5 | Como organizador, quiero recibir sugerencias automaticas de equipo y suministros basadas en los productos seleccionados para agilizar la preparacion del evento. | [Todas] |
| US-6 | Como banquetera, quiero subir fotos a cada evento para tener un portafolio visual de mi trabajo y mostrarlo a futuros clientes. | [Todas] |
| US-7 | Como organizadora de XV años, quiero aplicar descuentos (porcentaje o monto fijo) a la cotizacion para ofrecer promociones sin recalcular manualmente. | [Todas] |

### 8.2 Gestion de Clientes

| ID | Historia | Plataforma |
|----|----------|------------|
| US-8 | Como organizador, quiero registrar clientes con nombre, telefono, email y direccion para tener un directorio centralizado de mis contactos. | [Todas] |
| US-9 | Como wedding planner, quiero ver el historial de eventos y gasto total de cada cliente para identificar mis mejores clientes y ofrecerles trato preferencial. | [Todas] |
| US-10 | Como organizador, quiero buscar clientes rapidamente por nombre o telefono para encontrar informacion cuando me llaman por WhatsApp. | [Todas] |

### 8.3 Finanzas y Pagos

| ID | Historia | Plataforma |
|----|----------|------------|
| US-11 | Como wedding planner, quiero registrar pagos parciales (anticipo del 50%, segundo pago, saldo final) con diferentes metodos de pago para rastrear exactamente cuanto falta por cobrar de cada evento. | [Todas] |
| US-12 | Como organizador, quiero generar un PDF de cotizacion/presupuesto con el logo y nombre de mi negocio para enviar documentos profesionales a mis clientes. | [Todas] |
| US-13 | Como banquetera, quiero generar un contrato PDF con terminos de cancelacion, porcentaje de anticipo y politica de reembolso configurables para formalizar cada evento. | [Todas] |
| US-14 | Como organizador premium, quiero que mis clientes puedan pagar el anticipo por Stripe directamente desde un enlace para reducir la friccion de cobro. | [Web] |
| US-15 | Como organizador, quiero ver un reporte de pagos por evento que muestre total, pagado, pendiente y metodos utilizados. | [Todas] |

### 8.4 Catalogo de Productos

| ID | Historia | Plataforma |
|----|----------|------------|
| US-16 | Como banquetera, quiero crear productos con precio base, costo y categoria para tener un catalogo organizado que puedo reutilizar en cada evento. | [Todas] |
| US-17 | Como pastelera, quiero agregar recetas con ingredientes a mis productos para calcular el costo real de cada pastel y conocer mi margen de ganancia. | [Todas] |
| US-18 | Como organizadora, quiero vincular ingredientes de mi inventario a las recetas de mis productos para que al cotizar un evento, el sistema sepa automaticamente que suministros necesito comprar. | [Todas] |

### 8.5 Inventario

| ID | Historia | Plataforma |
|----|----------|------------|
| US-19 | Como decoradora, quiero registrar mi equipo (mesas, sillas, manteles) con stock actual, stock minimo y costo unitario para saber que tengo disponible y cuanto vale. | [Todas] |
| US-20 | Como organizador, quiero diferenciar entre equipo reutilizable (sillas, mesas) y suministros consumibles (globos, servilletas, flores) para gestionar cada tipo correctamente. | [Todas] |
| US-21 | Como banquetera, quiero ver alertas cuando el stock de un suministro esta por debajo del minimo para reabastecerme a tiempo antes de un evento. | [Todas] |

### 8.6 Calendario y Agenda

| ID | Historia | Plataforma |
|----|----------|------------|
| US-22 | Como organizador, quiero ver todos mis eventos en un calendario mensual con indicadores de estado (cotizado/confirmado) para tener una vision clara de mi carga de trabajo. | [Todas] |
| US-23 | Como organizador, quiero bloquear fechas como no disponibles (vacaciones, dias personales) para que no me pidan cotizaciones en esas fechas. | [Todas] |
| US-24 | Como organizador, quiero ver los proximos eventos pendientes por confirmar en mi dashboard para darles seguimiento oportuno. | [Todas] |

### 8.7 Productividad y Ecosistema

| ID | Historia | Plataforma |
|----|----------|------------|
| US-25 | Como organizadora que usa iPhone, quiero ver mi proximo evento en un widget de pantalla de inicio para tener la informacion a la vista sin abrir la app. | [iOS] |
| US-26 | Como organizador en campo, quiero ver el progreso de un evento activo en la Dynamic Island / Live Activity para monitorear sin desbloquear el telefono. | [iOS] |
| US-27 | Como organizadora, quiero buscar eventos, clientes y productos desde Spotlight (iOS) para encontrar informacion rapidamente desde cualquier pantalla. | [iOS] |
| US-28 | Como organizador, quiero autenticarme con biometria (Face ID / huella) para acceder rapido a la app sin escribir mi contraseña cada vez. | [iOS/Android] |
| US-29 | Como administrador del sistema, quiero un panel web con estadisticas de usuarios, suscripciones activas y herramientas de debug para monitorear la salud de la plataforma. | [Web] |

---

## 9. Principio de Paridad Cross-Platform

### Regla Obligatoria

La paridad cross-platform es **MANDATORIA** en este proyecto. Esto significa:

> **Cada feature core construida en una plataforma DEBE ser construida en las demas. Cada bug corregido en una plataforma DEBE ser verificado y corregido en las otras.**

### Matriz de Paridad

| Cambio en... | Debe verificarse y aplicarse en... |
|--------------|-------------------------------------|
| iOS | Android, Web |
| Android | iOS, Web |
| Web | iOS, Android |
| Backend (API) | Verificar que los 3 clientes lo consumen correctamente |

### Implementacion de la Paridad

| Aspecto | iOS | Android | Web |
|---------|-----|---------|-----|
| **Lenguaje** | Swift | Kotlin | TypeScript |
| **UI Framework** | SwiftUI | Jetpack Compose | React |
| **Arquitectura** | MVVM + Swift Packages | Multi-module + MVVM | Context + Hooks |
| **Red** | URLSession / async-await | Ktor Client | Fetch API / Axios |
| **Auth** | Keychain + Biometric | EncryptedSharedPrefs + Biometric | httpOnly cookies |
| **Pagos** | StoreKit 2 / RevenueCat | Google Play Billing / RevenueCat | Stripe Checkout |
| **Push** | APNs | FCM | — |
| **Widgets** | WidgetKit | Glance (Jetpack Compose) | — |
| **Live Activity** | ActivityKit + Dynamic Island | — | — |
| **Busqueda del OS** | Core Spotlight | — | — |
| **PDF** | Generacion nativa | Generacion nativa | Generacion en servidor |

### Proceso de Verificacion

1. **Al corregir un bug:** Antes de cerrar el issue, verificar si el mismo bug puede existir en las otras plataformas. Si si, corregirlo.
2. **Al implementar una feature:** La feature no se considera completa hasta que exista en todas las plataformas aplicables con comportamiento equivalente.
3. **En code review:** Siempre preguntar: "Tiene esto equivalente en las otras plataformas? Esta actualizado?"

### Excepciones Aceptables

Las unicas diferencias aceptables son las **impuestas por la plataforma o el contexto de uso:**

| Feature | iOS | Android | Web | Razon |
|---------|-----|---------|-----|-------|
| **Widgets de pantalla de inicio** | Si | Si (planificado) | No | No aplica en navegadores web |
| **Live Activity / Dynamic Island** | Si | No | No | API exclusiva de iOS |
| **Biometric auth** | Face ID / Touch ID | Huella / Face Unlock | No | No aplica en web |
| **Core Spotlight** | Si | No | No | API exclusiva de iOS |
| **Panel de administracion** | No | No | Si | Requiere pantalla grande y es una herramienta interna |
| **Push notifications** | APNs | FCM | No | Implementacion futura para web |
| **Google Sign-In** | Si | Si | Planificado | En progreso para web |
| **Apple Sign-In** | Si | No | No | API exclusiva del ecosistema Apple |

En todos los casos donde la funcionalidad es posible en multiples plataformas, la **funcionalidad equivalente** debe existir aunque la implementacion tecnica difiera.

---

*Este documento es la fuente de verdad para la vision del producto Solennix. Todos los demas documentos del PRD (`02_FEATURES.md` a `10_...`) deben ser consistentes con lo aqui definido.*
