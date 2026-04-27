# Design: Video 04 - Calendario

## Component Structure
The video will be built using `TransitionSeries` for major scene transitions.

### Scenes
1. **HookScene**: Uses `AbsoluteFill` with centered text. Opacity and scale interpolation for a soft entrance.
2. **MainScene**: Displays `02-calendario.png`.
   - Intro: Spring scale-in.
   - Loop: A subtle pulse effect on a specific area of the screen (simulating "event days") using `Math.sin(frame)`.
3. **DetailScene**: Displays `04-evento-detalle.png`.
   - Zoom effect: `interpolate(frame, [0, duration], [1.1, 1.3])`.
   - Slide-up text overlay for "DETALLE TOTAL".
4. **CTAScene**: Same as `V03Clients.tsx` for consistency.

## Code Patterns
- Use `staticFile('screenshots/02-calendario.png')` for images.
- Use `interpolate` for all frame-based animations.
- Shared `SOCIAL_COLORS` from `../constants`.

## Square Adaptation
`V04CalendarSquare.tsx` will adjust paddings and font sizes to fit the 1:1 aspect ratio, likely using a wider container for the screenshots.
