# Estrategia de Testing

El proyecto cuenta con una suite de pruebas robusta para asegurar la calidad y estabilidad de las funcionalidades críticas.

## Suite de Pruebas (Vitest)

Utilizamos **Vitest** con **React Testing Library** para pruebas unitarias y de integración del frontend.

### Ejecución

- **Correr todos los tests:**
  ```bash
  npx vitest run
  ```
- **Modo Watch (desarrollo):**
  ```bash
  npx vitest
  ```

### Áreas Cubiertas

- **Formularios:** Validaciones, flujos de creación (wizard), manejo de estados.
- **Servicios:** Comunicación con el API, manejo de errores, mocks de datos.
- **Componentes UI:** Renderizado dinámico, tematización (Dark/Light), navegación.
- **Generación de Archivos:** Pruebas sobre la lógica de generación de PDFs.

### Mantenimiento de Mocks

Es crucial mantener los mocks sincronizados con la estructura del backend. Recientemente se estandarizaron las propiedades de datos (ej. `client` vs `clients`) para evitar fallos por cambios de esquema.

## Tests End-to-End (Playwright)

_(En proceso / Opcional)_
Se encuentran configurados en la carpeta `tests/` para validar flujos completos de usuario en el navegador.

## Mejores Prácticas

1. **Evitar Re-renders Infinitos:** Siempre usar mocks estables (fuera del cuerpo del test) para funciones pasadas a componentes que usan hooks de efecto.
2. **Selectores Resilientes:** Priorizar `getByRole`, `getByLabelText` o `getByTitle` sobre selectores de texto frágiles.
3. **Limpieza:** Usar `vi.clearAllMocks()` en el `beforeEach` para asegurar aislamiento entre pruebas.
