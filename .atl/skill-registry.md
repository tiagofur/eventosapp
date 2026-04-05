# Skill Registry — Solennix

## Compact Rules (auto-resolved)

### Android Architecture (MVVM + Clean)
- Modules: `app`, `feature/*`, `core/*`
- Layers: UI (Compose) -> ViewModel (StateFlow) -> Repository -> Local (Room) / Remote (Ktor)
- DI: Hilt (Dagger)
- State: `*UiState` data class + `StateFlow`
- Navigation: Type-safe Compose Navigation with `@Serializable` routes

### Android Quality
- Linter: `./gradlew lint`
- Testing: JUnit 5 + MockK + Turbine (not yet implemented)
- Offline-first: Room is the single source of truth

### Design System
- Theme: Material 3 custom (Gold/Navy)
- Components: `SolennixTopAppBar`, `SolennixTextField`, `KPICard`, `StatusBadge`
- Adaptive: Support compact (mobile) and expanded (tablet) layouts

## User Skills

| Skill | Trigger | Location |
|-------|---------|----------|
| remotion-best-practices | remotion, video creation | /Users/tiagofur/Dev/eventosapp/.agents/skills/remotion-best-practices/SKILL.md |
| solennix-video-creator | video management | /Users/tiagofur/Dev/eventosapp/.agent/skills/solennix-video-creator/SKILL.md |

## Project Conventions
- `AGENTS.md`: Global project overview and task guides.
- `CLAUDE.md`: Personality and detailed Android rules.
- `GEMINI.md`: Core mandates and operational guidelines.
