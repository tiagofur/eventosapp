# Eventos — Setup

## Supabase

1) Crea un proyecto en Supabase.
2) Copia el Project URL y el anon key.
3) Crea un archivo .env (puedes duplicar .env.example) y agrega:

   - VITE_SUPABASE_URL
   - VITE_SUPABASE_ANON_KEY

4) En el SQL Editor de Supabase, ejecuta el esquema consolidado:
   - supabase/migrations/20260215000001_consolidated_schema.sql
   Nota: los archivos legacy de migración ya no son necesarios y pueden eliminarse.
5) En Auth > URL Configuration, configura:
   - Site URL = tu dominio (local o Vercel)
   - Redirect URLs = agrega tu dominio y http://localhost:5173

## Vercel

1) Importa el repo en Vercel.
2) Configura variables de entorno:
   - VITE_SUPABASE_URL
   - VITE_SUPABASE_ANON_KEY
3) Build command: pnpm build
4) Output directory: dist

## Dev local

1) pnpm install
2) pnpm dev

## IVA (Facturación)

- Si el evento requiere factura, el IVA se calcula automáticamente y se suma al total.
- La tasa por defecto es 16% (se puede ajustar en el campo `tax_rate` si se requiere en el futuro).

## Futuro (Multi-usuario por negocio)

Propuesta para habilitar equipos:
- Crear tabla `organizations` y `organization_members` con roles.
- Reemplazar `user_id` por `organization_id` en clientes, eventos, productos e inventario.
- Ajustar políticas RLS para permisos por organización.
