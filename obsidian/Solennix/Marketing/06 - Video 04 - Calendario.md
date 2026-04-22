---
tags:
  - marketing
  - video
  - v04
date: 2026-04-21
status: concept
duration: 20s
screenshots: pending
---

# V04 — Calendario Inteligente

> [!quote] Mensaje clave
> "Visualizá tu mes entero. Un vistazo. Cero sorpresas."

---

## Objetivo

Mostrar el calendario interactivo como reemplazo de Google Calendar desordenado y notas sueltas.

## Audiencia

Organizadores que usan Google Calendar + papel para llevar la agenda de eventos.

---

## Storyboard

### Escena 1: Hook (Frames 0-60 / 0-2s)

- Pregunta: "¿Qué eventos tenés esta semana?"
- Fondo oscuro

### Escena 2: Calendario Mensual (Frames 60-210 / 2-7s)

- Screenshot `calendar-view.png` aparece con scale-up
- Días con eventos se "encienden" uno por uno con efecto de pulso
- Cada día ilumina → muestra badge de evento

### Escena 3: Detalle del Día (Frames 210-390 / 7-13s)

- Zoom in a un día específico
- Aparece `calendar-day-detail.png` con slide-up
- Muestra: nombre del cliente, tipo de evento, cantidad de personas, estado

### Escena 4: Beneficio + CTA (Frames 390-600 / 13-20s)

- Texto: "Tu agenda visual. Sin Google Calendar. Sin papel."
- Logo + CTA

---

## Screenshots

| Archivo | Qué mostrar | Listo |
|---------|-------------|-------|
| `calendar-view.png` | Calendario mensual con eventos | ⬜ |
| `calendar-day-detail.png` | Detalle de un día con eventos | ⬜ |

## Notas Técnicas

- Efecto de "pulso" en días: `interpolate()` con `scale` y `opacity`
- Zoom in: `transform: scale()` interpolado desde 1.0 a 2.0
- Los días pueden encenderse en secuencia con `delayRender` pattern

---

## Ver también

- [[01 - Plan de Videos Solennix|Plan General]]
- [[02 - Assets Necesarios]]
- [[MOC|Marketing Hub]]
