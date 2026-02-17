# Copilot Instructions for EventosApp

## Build, test, and lint commands

### Web (`web/`)
- Install deps: `cd web && pnpm install` (lockfiles for both pnpm and npm exist; Playwright config uses pnpm)
- Dev server: `cd web && pnpm dev`
- Build: `cd web && pnpm build`
- Lint: `cd web && pnpm lint`
- Type-check: `cd web && pnpm check`
- Unit tests (all): `cd web && pnpm test:run`
- Unit test (single file): `cd web && pnpm vitest run src/lib/api.test.ts`
- E2E tests (all): `cd web && pnpm test:e2e`
- E2E test (single file): `cd web && pnpm test:e2e tests/e2e/login.spec.ts`

### Backend (`backend/`)
- Run tests (all): `cd backend && go test ./...`
- Run a single backend test by name: `cd backend && go test ./internal/router -run TestNew`
- Build/check packages: `cd backend && go build ./...`
- Local DB only (Docker): `cd backend && docker-compose up -d`

### Flutter (`flutter/`)
- Install deps: `cd flutter && flutter pub get`
- Run app: `cd flutter && flutter run`
- Analyze (lint): `cd flutter && flutter analyze`
- Tests (all): `cd flutter && flutter test`
- Test (single file): `cd flutter && flutter test test/unit/entities/user_entity_test.dart`
- Build Android: `cd flutter && flutter build apk --release`
- Build iOS: `cd flutter && flutter build ios --release`

## High-level architecture

- Monorepo with three active surfaces:
  - `web/`: React + TypeScript SPA
  - `backend/`: Go API (Chi router + service/repository layers)
  - `flutter/`: Flutter mobile app using Riverpod and Dio
- Web and Flutter both target the Go API:
  - Web API client is `web/src/lib/api.ts` (`VITE_API_URL`, token in `localStorage`, emits `auth:logout` on 401)
  - Flutter API client is `flutter/lib/core/api/api_client.dart` (Dio with auth/refresh/logging/error interceptors)
- Web routing is split into public auth routes and authenticated routes wrapped with `ProtectedRoute` + `Layout` (`web/src/App.tsx`).
- Backend route surface is centralized in `backend/internal/router/router.go` under `/api`:
  - public `/auth/*` routes
  - authenticated CRUD domains (`clients`, `events`, `products`, `inventory`, `payments`)
- Data model consistency is maintained through shared naming conventions:
  - frontend uses camelCase objects
  - backend payloads often require snake_case for nested item updates (e.g., event items, product ingredients)

## Key repository conventions

- Follow existing service-layer pattern in web: each domain exposes a `*Service` in `web/src/services/` and all HTTP goes through `web/src/lib/api.ts` (avoid raw `fetch` in pages/components).
- Keep auth token key consistent as `auth_token` in web localStorage; logout flow depends on 401 handling in `api.ts` and `auth:logout` listener in `AuthContext`.
- Preserve backend API contract mapping in web services when sending nested arrays:
  - `productId -> product_id`, `unitPrice -> unit_price`, `inventoryId -> inventory_id`, etc.
- Web route structure convention:
  - unauthenticated: `/`, `/login`, `/register`, `/forgot-password`
  - authenticated app: `/dashboard`, `/search`, `/calendar`, `/clients`, `/products`, `/inventory`, `/settings`
- Flutter code organization follows feature-first Clean Architecture structure (`features/*/{data,domain,presentation}`) with Riverpod providers in presentation.
- For contributions, keep Conventional Commits format from `CONTRIBUTING.md` (`feat(scope): ...`, `fix(scope): ...`, etc.).
