# Despliegue

## Supabase (Base de datos)

1. Crea un proyecto en Supabase.
2. En el SQL Editor, ejecuta el esquema consolidado:
   - supabase/migrations/20260215000001_consolidated_schema.sql
3. En Auth > URL Configuration:
   - Site URL: tu dominio (local o Vercel)
   - Redirect URLs: tu dominio y http://localhost:5173

## Variables de entorno

Configura en local y en Vercel:

- VITE_SUPABASE_URL
- VITE_SUPABASE_ANON_KEY

## Vercel

1. Importa el repo.
2. Variables de entorno: agrega las anteriores.
3. Build command: pnpm build
4. Output directory: dist

## Verificación post‑deploy

- Login y registro funcionando.
- Crear evento con factura y verificar IVA en el total.
- Calendario mostrando eventos y horarios.
- Resumen/Contrato sin errores.
