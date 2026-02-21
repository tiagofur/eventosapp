import { clientService } from './clientService';
import { productService } from './productService';
import { inventoryService } from './inventoryService';
import { eventService } from './eventService'; // Will be refactored next
import { Database } from '../types/supabase';

type Client = Database['public']['Tables']['clients']['Row'];
type Event = Database['public']['Tables']['events']['Row'];
type Product = Database['public']['Tables']['products']['Row'];
type InventoryItem = Database['public']['Tables']['inventory']['Row'];

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
  client: SearchResult[];
  event: SearchResult[];
  product: SearchResult[];
  inventory: SearchResult[];
};

const EMPTY_RESULTS: SearchResults = {
  client: [],
  event: [],
  product: [],
  inventory: [],
};

const normalizeQuery = (query: string) => query.trim().toLowerCase();

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

const mapEventResults = (events: any[]): SearchResult[] =>
  events.map((event) => ({
    id: event.id,
    type: 'event',
    title: event.service_type,
    subtitle: event.client?.name || undefined,
    meta: event.event_date,
    status: event.status,
    href: `/events/${event.id}/summary`,
  }));

export const searchService = {
  async searchAll(query: string, limit: number = 6): Promise<SearchResults> {
    const term = normalizeQuery(query);
    if (!term) return EMPTY_RESULTS;

    // Fetch all data in parallel
    const [clients, products, inventory, events] = await Promise.all([
      clientService.getAll(),
      productService.getAll(),
      inventoryService.getAll(),
      eventService.getAll(),
    ]);

    // Filter in memory
    const filteredClients = clients.filter(c => 
      c.name.toLowerCase().includes(term) || 
      c.email?.toLowerCase().includes(term) || 
      c.city?.toLowerCase().includes(term)
    );

    const filteredProducts = products.filter(p => 
      p.name.toLowerCase().includes(term) || 
      p.category.toLowerCase().includes(term)
    );

    const filteredInventory = inventory.filter(i => 
      i.ingredient_name.toLowerCase().includes(term)
    );

    const filteredEvents = events.filter((e: any) => 
      e.service_type.toLowerCase().includes(term) || 
      e.location?.toLowerCase().includes(term) ||
      e.client?.name?.toLowerCase().includes(term)
    );

    return {
      client: limitResults(mapClientResults(filteredClients), limit),
      product: limitResults(mapProductResults(filteredProducts), limit),
      inventory: limitResults(mapInventoryResults(filteredInventory), limit),
      event: limitResults(mapEventResults(filteredEvents), limit),
    };
  },
};
