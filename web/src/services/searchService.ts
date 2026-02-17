import { supabase, getCurrentUserId } from '../lib/supabase';
import { Database } from '../types/supabase';

type Client = Database['public']['Tables']['clients']['Row'];
type Event = Database['public']['Tables']['events']['Row'];
type Product = Database['public']['Tables']['products']['Row'];
type InventoryItem = Database['public']['Tables']['inventory']['Row'];

type EventWithClient = Event & { clients?: { name: string } | null };

type SearchEntity = 'client' | 'event' | 'product' | 'inventory';

export type SearchResult = {
  id: string;
  type: SearchEntity;
  title: string;
  subtitle?: string;
  meta?: string;
  status?: string;
  href: string;
};

export type SearchResults = {
  clients: SearchResult[];
  events: SearchResult[];
  products: SearchResult[];
  inventory: SearchResult[];
};

const EMPTY_RESULTS: SearchResults = {
  clients: [],
  events: [],
  products: [],
  inventory: [],
};

const normalizeQuery = (query: string) => query.trim().replace(/\s+/g, ' ');

const buildIlike = (query: string) => {
  const safe = query.replace(/[%_]/g, '').replace(/,/g, ' ');
  return `%${safe}%`;
};

const limitResults = <T,>(items: T[], limit: number) => items.slice(0, limit);

const mapClientResults = (clients: Client[]): SearchResult[] =>
  clients.map((client) => {
    const subtitleParts = [client.phone, client.email].filter(Boolean);
    return {
      id: client.id,
      type: 'client',
      title: client.name,
      subtitle: subtitleParts.join(' - '),
      meta: client.city || undefined,
      href: `/clients/${client.id}`,
    };
  });

const mapProductResults = (products: Product[]): SearchResult[] =>
  products.map((product) => ({
    id: product.id,
    type: 'product',
    title: product.name,
    subtitle: product.category || undefined,
    meta: product.base_price ? `$${product.base_price.toFixed(2)}` : undefined,
    href: `/products/${product.id}/edit`,
  }));

const mapInventoryResults = (items: InventoryItem[]): SearchResult[] =>
  items.map((item) => ({
    id: item.id,
    type: 'inventory',
    title: item.ingredient_name,
    subtitle: `${item.type === 'equipment' ? 'Equipo' : 'Ingrediente'} - ${item.unit}`,
    meta: `Stock: ${item.current_stock} ${item.unit}`,
    href: `/inventory/${item.id}/edit`,
  }));

const mapEventResults = (events: EventWithClient[]): SearchResult[] =>
  events.map((event) => ({
    id: event.id,
    type: 'event',
    title: event.service_type,
    subtitle: event.clients?.name || undefined,
    meta: event.event_date,
    status: event.status,
    href: `/events/${event.id}/summary`,
  }));

export const searchService = {
  async searchAll(query: string, limit: number = 6): Promise<SearchResults> {
    const normalized = normalizeQuery(query);
    if (!normalized) return EMPTY_RESULTS;

    const userId = await getCurrentUserId();
    const like = buildIlike(normalized);

    const [clients, products, inventory, eventsByFields] = await Promise.all([
      supabase
        .from('clients')
        .select('id, name, phone, email, city')
        .eq('user_id', userId)
        .or(`name.ilike.${like},phone.ilike.${like},email.ilike.${like},city.ilike.${like}`)
        .order('name')
        .limit(limit),
      supabase
        .from('products')
        .select('id, name, category, base_price')
        .eq('user_id', userId)
        .or(`name.ilike.${like},category.ilike.${like}`)
        .order('name')
        .limit(limit),
      supabase
        .from('inventory')
        .select('id, ingredient_name, unit, current_stock, type')
        .eq('user_id', userId)
        .or(`ingredient_name.ilike.${like},type.ilike.${like},unit.ilike.${like}`)
        .order('ingredient_name')
        .limit(limit),
      supabase
        .from('events')
        .select('id, event_date, service_type, location, city, notes, status, client_id, clients (name)')
        .eq('user_id', userId)
        .or(`service_type.ilike.${like},location.ilike.${like},city.ilike.${like},notes.ilike.${like}`)
        .order('event_date', { ascending: false })
        .limit(limit),
    ]);

    if (clients.error) throw clients.error;
    if (products.error) throw products.error;
    if (inventory.error) throw inventory.error;
    if (eventsByFields.error) throw eventsByFields.error;

    const clientRows = clients.data || [];
    const clientIds = clientRows.map((client) => client.id);

    let eventsByClients: EventWithClient[] = [];
    if (clientIds.length) {
      const { data, error } = await supabase
        .from('events')
        .select('id, event_date, service_type, status, client_id, clients (name)')
        .eq('user_id', userId)
        .in('client_id', clientIds)
        .order('event_date', { ascending: false })
        .limit(limit);

      if (error) throw error;
      eventsByClients = data || [];
    }

    const eventMap = new Map<string, EventWithClient>();
    (eventsByFields.data || []).forEach((event) => eventMap.set(event.id, event));
    eventsByClients.forEach((event) => eventMap.set(event.id, event));

    return {
      clients: limitResults(mapClientResults(clientRows), limit),
      products: limitResults(mapProductResults(products.data || []), limit),
      inventory: limitResults(mapInventoryResults(inventory.data || []), limit),
      events: limitResults(mapEventResults(Array.from(eventMap.values())), limit),
    };
  },
};
