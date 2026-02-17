# Integración API — Web App

Guía completa de integración con Supabase y el backend Go.

## 📋 Arquitectura de Datos

```
┌─────────────┐      HTTP/REST      ┌─────────────┐      SQL       ┌─────────────┐
│  React Web │ ◄─────────────────► │  Supabase  │ ◄───────────► │ PostgreSQL  │
│   (Vite)   │   (JS Client)      │             │              │             │
└─────────────┘                     └─────────────┘              └─────────────┘
        │                                                        │
        │ (Opcional para features avanzadas)                           │
        ▼                                                        │
┌─────────────┐                                                    │
│ Go Backend  │ ─────────────────────────────────────────────────────────────┘
│  (Chi/Go)  │
└─────────────┘
```

## 🔗 Conexión con Supabase

### Configuración Inicial

```typescript
// src/services/supabase.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL!;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});
```

### Auth State Management

```typescript
// src/contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react';
import { User, Session, AuthError } from '@supabase/supabase-js';
import { supabase } from '../services/supabase';

interface AuthContextType {
  user: User | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Obtener sesión inicial
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);
    });

    // Escuchar cambios de auth
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
  };

  const signUp = async (email: string, password: string) => {
    const { error } = await supabase.auth.signUp({
      email,
      password,
    });
    if (error) throw error;
  };

  const signOut = async () => {
    await supabase.auth.signOut();
  };

  return (
    <AuthContext.Provider value={{ user, session, loading, signIn, signUp, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

## 📦 Servicios CRUD

### Patrón General

Todos los servicios siguen este patrón:

```typescript
// src/services/[entity]Service.ts
import { supabase } from './supabase';
import { [Entity] } from '../types';

export const [entity]Service = {
  // READ - Obtener todos
  async getAll(filters?: Record<string, any>) {
    let query = supabase.from('[table]').select('*');

    // Aplicar filtros si existen
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        query = query.eq(key, value);
      });
    }

    const { data, error } = await query.order('created_at', {
      ascending: false,
    });
    return { data, error };
  },

  // READ - Obtener uno por ID
  async getById(id: string) {
    const { data, error } = await supabase
      .from('[table]')
      .select('*')
      .eq('id', id)
      .single();
    return { data, error };
  },

  // CREATE
  async create(entity: Partial<[Entity]>) {
    const { data, error } = await supabase
      .from('[table]')
      .insert(entity)
      .select()
      .single();
    return { data, error };
  },

  // UPDATE
  async update(id: string, entity: Partial<[Entity]>) {
    const { data, error } = await supabase
      .from('[table]')
      .update(entity)
      .eq('id', id)
      .select()
      .single();
    return { data, error };
  },

  // DELETE
  async delete(id: string) {
    const { error } = await supabase
      .from('[table]')
      .delete()
      .eq('id', id);
    return { error };
  },
};
```

### Servicio de Clientes

```typescript
// src/services/clientService.ts
import { supabase } from './supabase';
import { Client } from '../types';

export const clientService = {
  async getAll(search?: string) {
    let query = supabase.from('clients').select('*');

    if (search) {
      query = query.or(`name.ilike.%${search}%,email.ilike.%${search}%,phone.ilike.%${search}%`);
    }

    const { data, error } = await query.order('created_at', {
      ascending: false,
    });
    return { data, error };
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('clients')
      .select('*, events(*, total_spent)')
      .eq('id', id)
      .single();
    return { data, error };
  },

  async create(client: Omit<Client, 'id' | 'created_at' | 'updated_at' | 'user_id'>) {
    const { data: { user } } = await supabase.auth.getUser();

    const { data, error } = await supabase
      .from('clients')
      .insert({ ...client, user_id: user?.id })
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

### Servicio de Eventos

```typescript
// src/services/eventService.ts
import { supabase } from './supabase';
import { Event } from '../types';

export const eventService = {
  async getAll(filters?: {
    status?: string;
    client_id?: string;
    start?: string;
    end?: string;
  }) {
    let query = supabase
      .from('events')
      .select(`
        *,
        clients (name, email, phone),
        event_products (
          *,
          products (name, category)
        ),
        event_extras (*),
        payments (*)
      `);

    if (filters?.status) {
      query = query.eq('status', filters.status);
    }
    if (filters?.client_id) {
      query = query.eq('client_id', filters.client_id);
    }
    if (filters?.start) {
      query = query.gte('event_date', filters.start);
    }
    if (filters?.end) {
      query = query.lte('event_date', filters.end);
    }

    const { data, error } = await query.order('event_date', {
      ascending: true,
    });
    return { data, error };
  },

  async getById(id: string) {
    const { data, error } = await supabase
      .from('events')
      .select(`
        *,
        clients (*),
        event_products (*, products (*)),
        event_extras (*),
        payments (*)
      `)
      .eq('id', id)
      .single();
    return { data, error };
  },

  async create(event: Partial<Event>) {
    const { data: { user } } = await supabase.auth.getUser();

    const { data, error } = await supabase
      .from('events')
      .insert({ ...event, user_id: user?.id })
      .select()
      .single();
    return { data, error };
  },

  async update(id: string, event: Partial<Event>) {
    const { data, error } = await supabase
      .from('events')
      .update(event)
      .eq('id', id)
      .select()
      .single();
    return { data, error };
  },

  async updateItems(id: string, products: any[], extras: any[]) {
    // Usar RPC para actualizar items en una transacción
    const { data, error } = await supabase.rpc('update_event_items', {
      p_event_id: id,
      p_products: products,
      p_extras: extras,
    });
    return { data, error };
  },

  async delete(id: string) {
    const { error } = await supabase
      .from('events')
      .delete()
      .eq('id', id);
    return { error };
  },
};
```

## 🔐 Seguridad con RLS

Todas las consultas deben filtrar por `user_id`:

### Opción 1: Filtro manual en servicio

```typescript
async getAll() {
  const { data: { user } } = await supabase.auth.getUser();

  const { data, error } = await supabase
    .from('events')
    .select('*')
    .eq('user_id', user?.id); // ← Filtro por user

  return { data, error };
}
```

### Opción 2: RLS automático (recomendado)

```sql
-- En Supabase SQL Editor
CREATE POLICY "Users can only view their own events"
ON events
FOR SELECT
USING (auth.uid() = user_id);
```

Con RLS configurado, no necesitas filtrar explícitamente en el código.

## 🔄 Real-time Subscriptions

Supabase soporta suscripciones en tiempo real:

```typescript
// src/hooks/useRealtimeEvents.ts
export function useRealtimeEvents() {
  useEffect(() => {
    const channel = supabase
      .channel('events')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'events',
        },
        (payload) => {
          console.log('Cambio en eventos:', payload);
          // Actualizar estado o recargar datos
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);
}
```

## 📊 Cálculos en el Frontend

### Totales de Evento

```typescript
// src/lib/eventCalculations.ts
export function calculateEventTotals(event: Event) {
  const productsTotal = event.event_products?.reduce((sum, ep) => {
    return sum + (ep.quantity * (ep.unit_price - ep.discount));
  }, 0) ?? 0;

  const extrasTotal = event.event_extras?.reduce((sum, ee) => {
    return sum + ee.price;
  }, 0) ?? 0;

  const subtotal = productsTotal + extrasTotal;
  const discount = event.discount ?? 0;
  const taxableAmount = Math.max(0, subtotal - discount);

  const taxRate = event.requires_invoice ? (event.tax_rate ?? 16) / 100 : 0;
  const taxAmount = taxableAmount * taxRate;
  const totalAmount = taxableAmount + taxAmount;

  return {
    productsTotal,
    extrasTotal,
    subtotal,
    discount,
    taxableAmount,
    taxRate,
    taxAmount,
    totalAmount,
  };
}
```

### Estadísticas de Cliente

```typescript
// src/lib/clientStats.ts
export function calculateClientStats(client: Client) {
  const totalEvents = client.events?.length ?? 0;
  const totalSpent = client.events?.reduce((sum, event) => {
    return sum + event.total_amount;
  }, 0) ?? 0;

  return {
    totalEvents,
    totalSpent,
    avgSpentPerEvent: totalEvents > 0 ? totalSpent / totalEvents : 0,
  };
}
```

## 🖼️ Manejo de Imágenes

### Subir a Supabase Storage

```typescript
// src/services/storageService.ts
export const storageService = {
  async uploadImage(file: File, path: string) {
    const { data, error } = await supabase.storage
      .from('event-images')
      .upload(path, file);

    return { data, error };
  },

  async getPublicUrl(path: string) {
    const { data } = supabase.storage
      .from('event-images')
      .getPublicUrl(path);

    return data?.publicUrl;
  },
};
```

### Uso en componente

```tsx
// src/pages/EventForm.tsx
const handleImageUpload = async (file: File) => {
  const path = `events/${Date.now()}_${file.name}`;

  const { error } = await storageService.uploadImage(file, path);

  if (!error) {
    const publicUrl = await storageService.getPublicUrl(path);
    setEvent((prev) => ({ ...prev, image_url: publicUrl }));
  }
};
```

## 🌐 Integración con Backend Go (Opcional)

Para features avanzadas que requieran lógica server-side:

```typescript
// src/services/backendApi.ts
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

export const backendApi = {
  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const { data: { session } } = await supabase.auth.getSession();

    const response = await fetch(`${API_URL}/api${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${session?.access_token}`,
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.statusText}`);
    }

    return response.json();
  },

  // Ejemplo: Generar PDF en backend
  async generateEventPDF(eventId: string): Promise<Blob> {
    const response = await fetch(`${API_URL}/api/events/${eventId}/pdf`, {
      headers: {
        'Authorization': `Bearer ${session?.access_token}`,
      },
    });

    return response.blob();
  },
};
```

## 📝 Validación de Formularios

### Schema con Zod

```typescript
// src/lib/validations/eventSchema.ts
import { z } from 'zod';

export const eventSchema = z.object({
  client_id: z.string().min(1, 'Cliente requerido'),
  event_date: z.string().min(1, 'Fecha requerida'),
  service_type: z.string().min(1, 'Tipo de servicio requerido'),
  num_people: z.number().min(1, 'Número de personas requerido'),
  status: z.enum(['quoted', 'confirmed', 'completed', 'cancelled']),
  discount: z.number().min(0).default(0),
  requires_invoice: z.boolean().default(false),
  tax_rate: z.number().min(0).max(100).default(16),
});

export type EventFormInput = z.infer<typeof eventSchema>;
```

### Uso en Form

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { eventSchema } from '../lib/validations/eventSchema';

export function EventForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<EventFormInput>({
    resolver: zodResolver(eventSchema),
    defaultValues: {
      status: 'quoted',
      discount: 0,
      requires_invoice: false,
      tax_rate: 16,
    },
  });

  const onSubmit = async (data: EventFormInput) => {
    await eventService.create(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <select {...register('status')}>
        <option value="quoted">Cotizado</option>
        <option value="confirmed">Confirmado</option>
        <option value="completed">Completado</option>
        <option value="cancelled">Cancelado</option>
      </select>
      {errors.status && <span>{errors.status.message}</span>}
      {/* ... otros campos */}
    </form>
  );
}
```

## 🔍 Búsqueda y Filtrado

### Búsqueda con índices

```typescript
async searchEvents(query: string) {
  const { data, error } = await supabase
    .from('events')
    .select(`
      *,
      clients (name)
    `)
    .or(`
      service_type.ilike.%${query}%,
      clients.name.ilike.%${query}%
    `)
    .limit(20);

  return { data, error };
}
```

### Filtros compuestos

```typescript
async filterEvents(filters: EventFilters) {
  let query = supabase.from('events').select('*');

  if (filters.status) {
    query = query.eq('status', filters.status);
  }
  if (filters.client_id) {
    query = query.eq('client_id', filters.client_id);
  }
  if (filters.date_from && filters.date_to) {
    query = query
      .gte('event_date', filters.date_from)
      .lte('event_date', filters.date_to);
  }

  const { data, error } = await query.order('event_date');
  return { data, error };
}
```

## 📚 Referencias de API Supabase

- [Supabase JS Client Reference](https://supabase.com/docs/reference/javascript)
- [Auth Reference](https://supabase.com/docs/reference/javascript/auth-signup)
- [Database Reference](https://supabase.com/docs/reference/javascript/select)
- [Storage Reference](https://supabase.com/docs/reference/javascript/storage-upload)
- [Realtime Reference](https://supabase.com/docs/reference/javascript/subscribe)

---

Última actualización: 2026-02-17
