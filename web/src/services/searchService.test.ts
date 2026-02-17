import { describe, it, expect, vi, beforeEach } from 'vitest';
import { searchService } from './searchService';
import { clientService } from './clientService';
import { productService } from './productService';
import { inventoryService } from './inventoryService';
import { eventService } from './eventService';

vi.mock('./clientService');
vi.mock('./productService');
vi.mock('./inventoryService');
vi.mock('./eventService');

describe('searchService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns empty results for empty query', async () => {
    const result = await searchService.searchAll('');
    expect(result).toEqual({ clients: [], events: [], products: [], inventory: [] });
  });

  it('filters clients by name', async () => {
    (clientService.getAll as any).mockResolvedValue([
      { id: '1', name: 'Juan', email: 'juan@test.com', city: 'CDMX', phone: '123' },
    ]);
    (productService.getAll as any).mockResolvedValue([]);
    (inventoryService.getAll as any).mockResolvedValue([]);
    (eventService.getAll as any).mockResolvedValue([]);

    const result = await searchService.searchAll('juan');
    expect(result.clients).toHaveLength(1);
    expect(result.clients[0].title).toBe('Juan');
  });

  it('maps and filters across entities', async () => {
    (clientService.getAll as any).mockResolvedValue([
      { id: '1', name: 'Maria', email: 'maria@test.com', city: 'GDL', phone: '555' },
      { id: '2', name: 'Luis', email: 'luis@test.com', city: 'MTY', phone: '' },
    ]);
    (productService.getAll as any).mockResolvedValue([
      { id: 'p1', name: 'Churros', category: 'Postre', base_price: 25 },
    ]);
    (inventoryService.getAll as any).mockResolvedValue([
      { id: 'i1', ingredient_name: 'Harina', type: 'ingredient', unit: 'kg', current_stock: 10 },
      { id: 'i2', ingredient_name: 'Horno', type: 'equipment', unit: 'pieza', current_stock: 1 },
    ]);
    (eventService.getAll as any).mockResolvedValue([
      { id: 'e1', service_type: 'Boda', event_date: '2024-01-02', status: 'confirmed', clients: { name: 'Maria' } },
    ]);

    const result = await searchService.searchAll('ma', 1);

    expect(result.clients).toHaveLength(1);
    expect(result.clients[0].subtitle).toContain('maria@test.com');
    expect(result.products).toHaveLength(0);
    expect(result.inventory).toHaveLength(0);
    expect(result.events).toHaveLength(1);
    expect(result.events[0].href).toBe('/events/e1/summary');
  });

  it('handles events with client shape and inventory equipment', async () => {
    (clientService.getAll as any).mockResolvedValue([]);
    (productService.getAll as any).mockResolvedValue([
      { id: 'p1', name: 'Tacos', category: 'Comida', base_price: 0 },
    ]);
    (inventoryService.getAll as any).mockResolvedValue([
      { id: 'i2', ingredient_name: 'Horno', type: 'equipment', unit: 'pieza', current_stock: 1 },
    ]);
    (eventService.getAll as any).mockResolvedValue([
      { id: 'e2', service_type: 'XV', event_date: '2024-02-10', status: 'quoted', client: { name: 'Ana' } },
    ]);

    const result = await searchService.searchAll('ho');

    expect(result.inventory[0].subtitle).toBe('Equipo - pieza');
    expect(result.products).toHaveLength(0);
    expect(result.events).toHaveLength(0);
  });

  it('maps product meta only when base price exists', async () => {
    (clientService.getAll as any).mockResolvedValue([]);
    (productService.getAll as any).mockResolvedValue([
      { id: 'p1', name: 'Tacos', category: 'Comida', base_price: 0 },
    ]);
    (inventoryService.getAll as any).mockResolvedValue([]);
    (eventService.getAll as any).mockResolvedValue([]);

    const result = await searchService.searchAll('tacos');

    expect(result.products).toHaveLength(1);
    expect(result.products[0].meta).toBeUndefined();
  });
});
