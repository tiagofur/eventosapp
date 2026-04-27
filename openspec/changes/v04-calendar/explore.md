# Exploration: Video 04 - Calendario

## Context
We need to create Video 04 for Solennix marketing. The focus is on the Calendar feature.
Existing videos (01, 02, 03) use a specific style:
- Dark navy background (`SOCIAL_COLORS.navyDark`).
- Gold/Cream typography (Cinzel/Inter).
- `TransitionSeries` with `slide` transitions.
- Scenes: Hook -> Main Screen -> Detail/Zoom -> CTA.

## Assets
- `remotion/public/screenshots/02-calendario.png`: Main calendar view.
- `marketing/ios_screens/final/iphone/04-evento-detalle.png`: Can be used for the detail zoom scene.

## Implementation Details
- New file: `remotion/src/marketing/V04Calendar.tsx` (Reel 9:16).
- New file: `remotion/src/marketing/V04CalendarSquare.tsx` (Square 1:1).
- Register in `remotion/src/Root.tsx`.
- Use `SOCIAL_COLORS`, `SolennixLogoDark`, and other shared components.

## Storyboard (from Obsidian)
1. **Hook**: "¿Qué eventos tenés esta semana?" (0-2s)
2. **Main View**: `02-calendario.png` with pulse effect on events (2-7s)
3. **Detail**: `04-evento-detalle.png` with zoom/slide-up (7-13s)
4. **CTA**: Benefit text + Logo + App Store/Play Store (13-20s)
