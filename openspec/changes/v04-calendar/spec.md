# Specification: Video 04 - Calendario

## Requirements
- **Duration**: ~20 seconds (600 frames at 30fps).
- **Format**: Vertical (1080x1920) and Square (1080x1080).
- **Branding**: Use `SOCIAL_COLORS` (navyDark, gold, cream).
- **Fonts**: Cinzel (Titles), Inter (Body).

## Content Breakdown
| Time | Scene | Visual | Audio/Text |
|------|-------|--------|------------|
| 0-2s | Hook | Dark background, centered text | "¿Qué eventos tenés esta semana?" |
| 2-7s | Main | `02-calendario.png` with pulse | "CALENDARIO" - Tu agenda visual. |
| 7-13s| Detail| `04-evento-detalle.png` zoom | "DETALLE TOTAL" - Todo en un vistazo. |
| 13-20s| CTA | Logo + Badges | "SIN EXCEL. SIN CAOS." solennix.com |

## Technical Specs
- Component: `V04Calendar` and `V04CalendarSquare`.
- Transitions: `slide({ direction: 'from-right' })`.
- Shared components: `SolennixLogoDark`, `StoreBadge`.
