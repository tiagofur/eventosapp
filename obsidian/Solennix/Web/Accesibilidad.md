# Accesibilidad

#web #a11y #calidad

> [!abstract] Resumen
> La app implementa muchas buenas prácticas de accesibilidad: ARIA labels, roles semánticos, focus management, screen reader support. Hay áreas por mejorar.

---

## Lo que ya se hace bien

| Práctica | Implementación |
|----------|---------------|
| **ARIA labels** | Todos los botones interactivos tienen `aria-label` descriptivos |
| **aria-sort** | Headers de tabla indican dirección de sort |
| **aria-invalid** | Inputs de formulario marcan errores |
| **aria-describedby** | Inputs conectados a mensajes de error |
| **role="alert"** | Mensajes de error anunciados por screen readers |
| **role="status"** | Loading states anunciados |
| **sr-only** | Textos ocultos para screen readers (captions de tabla, labels) |
| **type="button"** | Todos los botones no-submit tienen tipo explícito |
| **Semantic HTML** | `<table>`, `<thead>`, `<th scope>`, `<caption>` |
| **Focus visible** | `focus:ring-2 focus:ring-primary/20` en inputs y botones |
| **Keyboard nav** | `onKeyDown` handlers en elementos clickeables no-nativos |

## Áreas de Mejora

> [!warning] Pendientes
> - **Skip to content** link faltante
> - **Focus trap** en modales (parcial — Modal.tsx podría mejorar)
> - **Reduced motion** — No hay `prefers-reduced-motion` media query
> - **Color contrast** — Verificar ratios WCAG AA en todas las combinaciones
> - **Announce route changes** — React Router no anuncia cambios a screen readers
> - **Error summary** — Los formularios muestran errores inline pero no hay resumen al top

## Relaciones

- [[Roadmap Web]] — Mejoras de accesibilidad priorizadas
- [[Design System]] — Tokens de color y contraste
