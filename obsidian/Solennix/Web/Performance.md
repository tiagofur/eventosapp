# Performance

#web #performance #calidad

> [!abstract] Resumen
> Build con Vite (fast HMR, optimized production). Sin SSR. Áreas de mejora en lazy loading, caching, y bundle optimization.

---

## Lo que ya funciona

| Aspecto | Estado |
|---------|--------|
| **Vite** | Build optimizado, tree-shaking, code splitting automático |
| **Tailwind CSS 4** | Purge automático de clases no usadas |
| **Skeleton states** | Loading states evitan layout shift |
| **httpOnly cookies** | Sin overhead de token en cada request |

## Áreas de Mejora

> [!warning] Oportunidades
> 
> ### Sin React Query / TanStack Query
> Cada página hace fetch al montar. No hay:
> - Cache de datos
> - Refetch en window focus
> - Deduplicación de requests
> - Optimistic updates
> - Stale-while-revalidate
> 
> ### Sin Lazy Loading de Rutas
> Todas las páginas se cargan en el bundle inicial. React.lazy() + Suspense podría reducir significativamente el bundle initial.
> 
> ### Sin Image Optimization
> Las imágenes de productos/clientes se sirven tal cual del backend. No hay:
> - Responsive images (srcSet)
> - Lazy loading nativo (`loading="lazy"`)
> - Formato WebP/AVIF
> - Thumbnails para listas
> 
> ### Sin Service Worker
> No hay caching offline ni PWA capabilities.
> 
> ### Recharts Bundle
> Recharts es una dependencia pesada (~200KB). Solo se usa en Dashboard y Admin. Debería lazy-loadarse.

## Relaciones

- [[Roadmap Web]] — Mejoras priorizadas
- [[Arquitectura General]] — Stack y decisiones técnicas
