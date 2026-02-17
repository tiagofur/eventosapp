# Guía de Setup — Web App (React)

Guía completa de configuración y desarrollo para la aplicación web de EventosApp.

## 📋 Requisitos Previos

- **Node.js** 18+ (recomendado usar [fnm](https://github.com/Schniz/fnm) o [nvm](https://github.com/nvm-sh/nvm))
- **pnpm** (recomendado) o npm
- **Cuenta de Supabase** (para Auth y Database)
- **Editor de código**: VS Code (recomendado)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/tiagofur/eventosapp.git
cd eventosapp/web
```

### 2. Instalar dependencias

```bash
# Usando pnpm (recomendado)
pnpm install

# O usando npm
npm install
```

### 3. Configurar Supabase

1. Crear un proyecto en [Supabase](https://supabase.com)
2. Ir a Settings → API
3. Copiar las siguientes variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

4. Crear archivo `.env` en la raíz del proyecto web:

```env
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Configurar esquema de base de datos

Ejecutar las migraciones SQL en Supabase:

1. Ir a SQL Editor en Supabase
2. Copiar y ejecutar el contenido de los archivos de migración (deben estar en el proyecto)
3. Verificar que las tablas se crearon correctamente

### 5. Configurar RLS (Row Level Security)

Para cada tabla, ejecutar:

```sql
-- Ejemplo para tabla clients
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own clients"
ON clients
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own clients"
ON clients
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own clients"
ON clients
FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own clients"
ON clients
FOR DELETE
USING (auth.uid() = user_id);
```

Repetir para: `events`, `products`, `inventory`, `payments`, etc.

## 🏃 Ejecutar en Desarrollo

### Modo desarrollo

```bash
pnpm dev
# o
npm run dev
```

La app estará disponible en `http://localhost:5173`

### Modo producción (local)

```bash
pnpm build
pnpm preview
```

El build estará en `dist/` y servido en `http://localhost:4173`

## 🧪 Ejecutar Tests

```bash
# Instalar navegadores Playwright (solo primera vez)
pnpm exec playwright install

# Ejecutar tests E2E
pnpm test:e2e

# Ejecutar tests con UI
pnpm test:e2e:ui

# Ejecutar tests en modo headless
pnpm test:e2e:ci
```

## 📦 Estructura del Proyecto

```
web/
├── src/
│   ├── components/          # Componentes reutilizables
│   │   ├── ui/            # Componentes UI base (Button, Input, etc.)
│   │   ├── layout/        # Componentes de layout (Header, Sidebar)
│   │   └── features/      # Componentes específicos de features
│   │
│   ├── pages/              # Páginas principales
│   │   ├── Landing.tsx     # Landing page pública
│   │   ├── Dashboard.tsx   # Dashboard principal
│   │   ├── Events.tsx      # Listado de eventos
│   │   ├── Clients.tsx     # Listado de clientes
│   │   ├── Products.tsx    # Catálogo de productos
│   │   ├── Inventory.tsx    # Gestión de inventario
│   │   └── Settings.tsx    # Configuración
│   │
│   ├── contexts/            # Contextos React
│   │   ├── AuthContext.tsx      # Contexto de autenticación
│   │   └── ThemeContext.tsx    # Contexto de tema
│   │
│   ├── hooks/               # Custom hooks
│   │   ├── useAuth.ts          # Hook de autenticación
│   │   ├── useEvents.ts        # Hook de eventos
│   │   └── useLocalStorage.ts   # Hook de localStorage
│   │
│   ├── services/            # Servicios de API (Supabase)
│   │   ├── supabase.ts       # Cliente Supabase
│   │   ├── authService.ts     # Servicios de auth
│   │   ├── clientService.ts    # Servicios de clientes
│   │   ├── eventService.ts     # Servicios de eventos
│   │   ├── productService.ts   # Servicios de productos
│   │   └── inventoryService.ts # Servicios de inventario
│   │
│   ├── lib/                # Utilidades
│   │   ├── utils.ts          # Funciones helper
│   │   ├── constants.ts      # Constantes globales
│   │   └── validations.ts   # Validaciones Zod
│   │
│   ├── types/              # Tipos TypeScript
│   │   ├── index.ts         # Exportaciones de tipos
│   │   ├── user.ts          # Tipos de usuario
│   │   ├── event.ts         # Tipos de eventos
│   │   ├── client.ts        # Tipos de clientes
│   │   └── product.ts       # Tipos de productos
│   │
│   └── main.tsx            # Punto de entrada
│
├── public/               # Archivos estáticos
│   ├── favicon.ico
│   └── robots.txt
│
├── tests/                # Tests E2E con Playwright
│   ├── auth.spec.ts
│   ├── events.spec.ts
│   └── ...
│
├── .env                 # Variables de entorno (no commitear)
├── .env.example          # Ejemplo de variables
├── index.html            # HTML template
├── package.json          # Dependencias
├── tsconfig.json        # Configuración TypeScript
├── tailwind.config.js   # Configuración Tailwind
└── vite.config.ts       # Configuración Vite
```

## 🔧 Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `VITE_SUPABASE_URL` | URL del proyecto Supabase | `https://xxx.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Clave pública de Supabase | `eyJ...` |
| `VITE_API_URL` | URL del backend Go (opcional) | `http://localhost:8080` |

## 🛠 Stack Tecnológico

| Tecnología | Versión | Uso |
|------------|----------|------|
| React | 18.3+ | UI Framework |
| TypeScript | 5.3+ | Tipado estático |
| Vite | 5.0+ | Build tool |
| Tailwind CSS | 3.4+ | Estilos |
| Lucide Icons | Latest | Iconos |
| Supabase JS | 2.39+ | Backend as a service |
| React Router DOM | 6.22+ | Routing |
| Zustand | 4.5+ | State management global |
| React Hook Form | 7.51+ | Formularios |
| Zod | 3.22+ | Validación de schemas |
| Recharts | 2.10+ | Gráficos |
| Playwright | 1.41+ | Tests E2E |

## 🎨 Estilos y Theming

### Tailwind CSS

El proyecto usa Tailwind CSS con configuración personalizada:

```js
// tailwind.config.js
export default {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#FFF0EB',
          500: '#FF6B35',
          600: '#E55A2B',
          // ...
        },
      },
    },
  },
  plugins: [],
};
```

### Dark Mode

El soporte de dark mode está implementado con `ThemeContext`:

```tsx
// Usar dark mode
const { theme } = useTheme();

<div className={`${theme === 'dark' ? 'dark' : ''}`}>
  <Component />
</div>
```

## 🔐 Autenticación

La autenticación se maneja con Supabase Auth:

```typescript
// src/services/authService.ts
import { supabase } from './supabase';

export const authService = {
  async signUp(email: string, password: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    return { data, error };
  },

  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  },

  async signOut() {
    await supabase.auth.signOut();
  },
};
```

## 📡 Servicios de API

Los servicios siguen un patrón consistente:

```typescript
// src/services/clientService.ts
import { supabase } from './supabase';
import { Client } from '../types';

export const clientService = {
  async getAll() {
    const { data, error } = await supabase
      .from('clients')
      .select('*')
      .order('created_at', { ascending: false });
    return { data, error };
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('clients')
      .select('*')
      .eq('id', id)
      .single();
    return { data, error };
  },

  async create(client: Partial<Client>) {
    const { data, error } = await supabase
      .from('clients')
      .insert(client)
      .select()
      .single();
    return { data, error };
  },

  async update(id: string, client: Partial<Client>) {
    const { data, error } = await supabase
      .from('clients')
      .update(client)
      .eq('id', id)
      .select()
      .single();
    return { data, error };
  },

  async delete(id: string) {
    const { error } = await supabase
      .from('clients')
      .delete()
      .eq('id', id);
    return { error };
  },
};
```

## 📝 Formularios

Los formularios usan React Hook Form + Zod:

```tsx
// src/pages/ClientForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const clientSchema = z.object({
  name: z.string().min(1, 'Nombre requerido'),
  email: z.string().email('Email inválido').optional(),
  phone: z.string().min(10, 'Teléfono requerido'),
});

type ClientForm = z.infer<typeof clientSchema>;

export function ClientForm() {
  const { register, handleSubmit, formState: { errors } } =
    useForm<ClientForm>({
      resolver: zodResolver(clientSchema),
    });

  const onSubmit = async (data: ClientForm) => {
    await clientService.create(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} />
      {errors.name && <span>{errors.name.message}</span>}
      {/* ... */}
    </form>
  );
}
```

## 🚀 Build para Producción

### Build

```bash
pnpm build
```

Esto genera una carpeta `dist/` con los archivos optimizados.

### Despliegue en Vercel

1. Instalar Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Desplegar:
   ```bash
   vercel --prod
   ```

3. Configurar variables de entorno en el dashboard de Vercel

## 🔧 Linting y Format

```bash
# Linting con ESLint
pnpm lint

# Lint con auto-fix
pnpm lint:fix

# Type checking
pnpm type-check
```

## 📚 Recursos Útiles

- [React docs](https://react.dev)
- [TypeScript docs](https://www.typescriptlang.org/docs)
- [Tailwind CSS docs](https://tailwindcss.com/docs)
- [Supabase docs](https://supabase.com/docs)
- [Vite docs](https://vitejs.dev)
- [React Router docs](https://reactrouter.com)

## 🐛 Troubleshooting

### Error: "supabase is not defined"

Verificar que `.env` tenga las variables correctas:
```env
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=xxx
```

### Error: "RLS policy violation"

Verificar que las políticas RLS estén configuradas correctamente en Supabase:
```sql
-- Ejemplo: permitir a usuarios ver sus propios clientes
CREATE POLICY "Users can view their own clients"
ON clients
FOR SELECT
USING (auth.uid() = user_id);
```

### Error: "import failed"

Verificar que las dependencias estén instaladas:
```bash
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

---

Última actualización: 2026-02-17
