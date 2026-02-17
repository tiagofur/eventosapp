import { describe, it, expect, vi, beforeEach } from 'vitest';
import { clientService } from './clientService';
import { api } from '../lib/api';

vi.mock('../lib/api', () => ({
  api: {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn(),
  },
}));

describe('clientService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getAll calls api.get', async () => {
    (api.get as any).mockResolvedValue([]);
    await clientService.getAll();
    expect(api.get).toHaveBeenCalledWith('/clients');
  });

  it('getById calls api.get', async () => {
    (api.get as any).mockResolvedValue({ id: '1' });
    await clientService.getById('1');
    expect(api.get).toHaveBeenCalledWith('/clients/1');
  });

  it('create calls api.post', async () => {
    (api.post as any).mockResolvedValue({ id: '1' });
    await clientService.create({ name: 'Test' } as any);
    expect(api.post).toHaveBeenCalledWith('/clients', { name: 'Test' });
  });

  it('update calls api.put', async () => {
    (api.put as any).mockResolvedValue({ id: '1' });
    await clientService.update('1', { name: 'Updated' } as any);
    expect(api.put).toHaveBeenCalledWith('/clients/1', { name: 'Updated' });
  });

  it('delete calls api.delete', async () => {
    (api.delete as any).mockResolvedValue({});
    await clientService.delete('1');
    expect(api.delete).toHaveBeenCalledWith('/clients/1');
  });
});
