# Testing

#web #testing #calidad

> [!abstract] Resumen
> Vitest para unit tests, Playwright para E2E, MSW para mocking de API. Estructura por componente con archivos `.test.tsx` colocados junto al archivo que testean.

---

## Stack de Testing

| Herramienta | Versión | Uso |
|------------|---------|-----|
| **Vitest** | 4.0 | Unit tests, component tests |
| **Playwright** | 1.58 | E2E tests |
| **MSW** | 2.12 | Mock Service Worker para interceptar requests |
| **Testing Library** | (via Vitest) | Render y query de componentes React |

## Estructura

```
web/src/
├── components/
│   ├── ToastContainer.tsx
│   └── ToastContainer.test.tsx    # Test junto al componente
├── pages/
│   └── Events/
│       └── components/
│           ├── EventEquipment.tsx
│           └── EventEquipment.test.tsx
```

## Tests Existentes

> [!warning] Cobertura Parcial
> La cobertura de tests es limitada. Hay tests para algunos componentes pero no para todos los servicios ni pages.

### Tests conocidos:
- `ToastContainer.test.tsx` — Rendering y tipos de toast
- `EventEquipment.test.tsx` — Selección de equipamiento, conflictos

## Ejecutar Tests

```bash
# Unit tests
cd web && npx vitest

# E2E tests
cd web && npx playwright test
```

## Relaciones

- [[Arquitectura General]] — Herramientas del stack
- [[Roadmap Web]] — Mejorar cobertura de tests es una tarea pendiente
