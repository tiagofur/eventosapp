---
tags:
  - super-plan
  - traceability
  - execution
  - governance
aliases:
  - Master Traceability Table
  - Tabla Maestra de Trazabilidad
status: active
created: 2026-04-10
updated: 2026-04-10
---

# 13 - Master Traceability Table

## Objetivo

Convertir el SUPER PLAN en ejecucion verificable: cada objetivo debe mapearse a una ola, un epic, criterios de aceptacion, evidencia y KPI de salida.

## Tabla Maestra

| ID   | Objetivo                                     | Ola      | Epic                        | Criterios de Aceptacion                                                                   | Evidencia Obligatoria                                                        | KPI Principal                           | Estado      |
| ---- | -------------------------------------------- | -------- | --------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------- | ----------- |
| T-01 | Estabilizar crear evento end-to-end          | Wave 1-2 | Event Lifecycle Reliability | Crear/editar/guardar evento sin bloqueos en 4 plataformas; sin placeholders en pasos core | Tests de flujo core + video de smoke por plataforma + logs sin errores P0/P1 | Crash-free sessions; P0 open count      | In Progress |
| T-02 | Congelar contrato API de eventos             | Wave 1   | Backend Contract Freeze     | Contratos versionados y validados; sin breaking changes no anunciados                     | Schema diff + contract tests + changelog de endpoints                        | Divergencias activas por contrato       | In Progress |
| T-03 | Cerrar gaps de paridad P0                    | Wave 3   | Core Parity Program         | Todas las features P0 en estado Green en matriz de paridad                                | Matriz actualizada + evidencia funcional por plataforma                      | Features P0 Green ratio                 | Planned     |
| T-04 | Reforzar UX nativa smartphone/tablet/desktop | Wave 4   | Native UX Excellence        | Flujos core pasan checklist UX por dispositivo                                            | Checklist UX aprobada + capturas comparativas                                | Flujos core completados por dispositivo | Planned     |
| T-05 | Hardening de resiliencia y observabilidad    | Wave 5   | Reliability and Telemetry   | Alertas, trazas y errores accionables en todos los entornos                               | Dashboards + alert rules + runbook de incidentes                             | MTTR P0/P1; Change failure rate         | Planned     |
| T-06 | Ejecutar release train con gates estrictos   | Wave 6   | Controlled Release Train    | RC aprobado sin fallas criticas de estabilidad/paridad                                    | Go/No-Go checklist + scorecard final + acta de release                       | Build success rate; Go/No-Go pass rate  | Planned     |

## Regla de Actualizacion

1. Cada story cerrada debe actualizar una fila de esta tabla.
2. Ningun epic cambia a In Progress sin evidencia minima definida.
3. Ningun epic cambia a Done si falta KPI o evidencia.

## Mapeo de Estado

- Planned: definido, aun no iniciado.
- In Progress: en ejecucion con evidencia parcial.
- Blocked: depende de riesgo, contrato o incidente.
- Done: aceptacion completa y evidencia validada.

## Ritual Semanal

1. **Lunes 9am**: Kick-off Wave — revisar T-XX status, desbloquear riesgos.
2. **Viernes 5pm**: Cierre — actualizar estados, KPIs, evidencias.
3. **Viernes 5:30pm**: OST — confirmar impactos en paridad y release.

## Próximas Acciones (Semana 1-2)

- **T-01**: Ver [[14_WAVE_1_BREAKDOWN]] para stories de Event Lifecycle.
- **T-02**: Contrato backend ya expandido en `backend/docs/openapi.yaml` con auth, subscriptions, CRUD core, dashboard, search, uploads, devices y unavailable-dates.
- **T-02**: Contract suite activa en `backend/internal/handlers/contract_test.go` validando presencia de endpoints, schemas y responses críticas.
- **T-01**: Backend ya cubre validación de `event_date` inválida y solapamiento con unavailable dates en `CreateEvent`.

## Enlaces

- [[SUPER PLAN MOC]]
- [[07_WAVE_PLAN_12_WEEKS]]
- [[10_BACKLOG_STRUCTURE_AND_ACCEPTANCE]]
- [[11_CROSS_PLATFORM_KPI_SCORECARD]]
- [[12_EXECUTION_CHECKLISTS]]
- [[03_CROSS_PLATFORM_PARITY_MODEL]]
- [[05_RELEASE_GOVERNANCE_AND_QUALITY_GATES]]
- [[11_CURRENT_STATUS]]

#super-plan #traceability #execution
