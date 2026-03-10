# Estrategia de Testing

Solennix cuenta con una suite de pruebas robusta para asegurar la calidad y estabilidad del proyecto en todas las plataformas.

## Web Frontend (Vitest + React Testing Library)

### Ejecución

- **Correr todos los tests:**
  ```bash
  cd web && npx vitest run
  ```
- **Modo Watch (desarrollo):**
  ```bash
  cd web && npx vitest
  ```

### Cobertura

- **783 tests** distribuidos en 51 archivos de test.
- **Umbrales estrictos:** 95% líneas/funciones/statements, 90% branches.

### Áreas Cubiertas

- **Servicios (7/7):** Comunicación con la API, mocks con MSW.
- **Hooks (4/4):** `usePagination`, `usePlanLimits`, `useToast`, `useTheme`.
- **Utilidades (5/5):** Cálculos financieros, error handling, PDF generation.
- **Componentes (11/12):** Renderizado dinámico, dark/light mode, navegación.
- **Páginas (24/25):** Formularios, validaciones, flujos de creación, estados de carga/error.

### Mantenimiento de Mocks

Los mocks (MSW handlers en `tests/mocks/`) deben mantenerse sincronizados con la estructura del backend. Los handlers simulan respuestas de la API para tests sin dependencia del servidor.

## Backend (Go Tests)

### Ejecución

```bash
cd backend && go test ./...
```

### Cobertura

- **21 archivos de test** cubriendo middleware, repositorios, servicios y handlers.
- Middleware (6/6), Repositories (6/6), Services (2/2), Handlers (7/9).

## Tests End-to-End (Playwright)

Configurados en `testsprite_tests/` para validar flujos completos de usuario en el navegador:

```bash
npx playwright test
```

- 5 archivos E2E: login, eventos, pagos, PDF, upgrade.
- Ejecuta contra Chromium por defecto.
- Requiere backend + frontend corriendo localmente.

## Mejores Prácticas

1. **Evitar Re-renders Infinitos:** Usar mocks estables fuera del cuerpo del test.
2. **Selectores Resilientes:** Priorizar `getByRole`, `getByLabelText` o `getByTitle`.
3. **Limpieza:** Usar `vi.clearAllMocks()` en el `beforeEach` para aislamiento.
4. **Error Paths:** Complementar happy-path tests con scenarios de error (400, 500, network).
5. **Financial Precision:** Verificar redondeo a 2 decimales en todos los cálculos monetarios.

## Referencia

Para análisis detallado de gaps de cobertura, consultar `docs/archive/test-coverage-analysis.md`.
