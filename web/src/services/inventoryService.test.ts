import { describe, it, expect, vi, beforeEach } from 'vitest';
import { inventoryService } from './inventoryService';
import { api } from '../lib/api';

vi.mock('../lib/api', () => ({
  api: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
  },
}));

describe('inventoryService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getAll calls api.get', async () => {
    (api.get as any).mockResolvedValue([]);
    await inventoryService.getAll();
    expect(api.get).toHaveBeenCalledWith('/inventory');
  });

  it('getAll returns empty array when api returns null', async () => {
    (api.get as any).mockResolvedValue(null);
    await expect(inventoryService.getAll()).resolves.toEqual([]);
  });

  it('getById calls api.get', async () => {
    (api.get as any).mockResolvedValue({ id: '1' });
    await inventoryService.getById('1');
    expect(api.get).toHaveBeenCalledWith('/inventory/1');
  });

  it('create calls api.post', async () => {
    (api.post as any).mockResolvedValue({ id: '1' });
    await inventoryService.create({ ingredient_name: 'Harina' } as any);
    expect(api.post).toHaveBeenCalledWith('/inventory', { ingredient_name: 'Harina' });
  });

  it('update calls api.put', async () => {
    (api.put as any).mockResolvedValue({ id: '1' });
    await inventoryService.update('1', { current_stock: 10 } as any);
    expect(api.put).toHaveBeenCalledWith('/inventory/1', { current_stock: 10 });
  });

  it('delete calls api.delete', async () => {
    (api.delete as any).mockResolvedValue({});
    await inventoryService.delete('1');
    expect(api.delete).toHaveBeenCalledWith('/inventory/1');
  });
});
