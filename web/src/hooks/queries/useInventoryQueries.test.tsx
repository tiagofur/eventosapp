import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor, act } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

const mockGetAll = vi.fn();
const mockGetPage = vi.fn();
const mockGetById = vi.fn();
const mockCreate = vi.fn();
const mockUpdate = vi.fn();
const mockDelete = vi.fn();

vi.mock('@/services/inventoryService', () => ({
  inventoryService: {
    getAll: (...args: any[]) => mockGetAll(...args),
    getPage: (...args: any[]) => mockGetPage(...args),
    getById: (...args: any[]) => mockGetById(...args),
    create: (...args: any[]) => mockCreate(...args),
    update: (...args: any[]) => mockUpdate(...args),
    delete: (...args: any[]) => mockDelete(...args),
  },
}));

vi.mock('@/hooks/useToast', () => ({
  useToast: () => ({ addToast: vi.fn() }),
}));

vi.mock('@/lib/errorHandler', () => ({
  logError: vi.fn(),
  getErrorMessage: (_err: any, fallback: string) => fallback,
}));

import {
  useInventoryItems,
  useInventoryItemsPaginated,
  useInventoryItem,
  useCreateInventoryItem,
  useUpdateInventoryItem,
  useDeleteInventoryItem,
} from './useInventoryQueries';

const createWrapper = () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
};

describe('useInventoryQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('useInventoryItems', () => {
    it('fetches all inventory items', async () => {
      mockGetAll.mockResolvedValue([{ id: 'inv1', ingredient_name: 'Harina' }]);
      const { result } = renderHook(() => useInventoryItems(), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetAll).toHaveBeenCalledTimes(1);
    });
  });

  describe('useInventoryItemsPaginated', () => {
    it('fetches paginated inventory items', async () => {
      mockGetPage.mockResolvedValue({ data: [{ id: 'inv1' }], total: 1, total_pages: 1 });
      const { result } = renderHook(
        () => useInventoryItemsPaginated({ page: 1, limit: 10, sort: 'name', order: 'asc' }),
        { wrapper: createWrapper() },
      );

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetPage).toHaveBeenCalledWith({ page: 1, limit: 10, sort: 'name', order: 'asc' });
    });
  });

  describe('useInventoryItem', () => {
    it('does not fetch when id is undefined', () => {
      const { result } = renderHook(() => useInventoryItem(undefined), { wrapper: createWrapper() });
      expect(result.current.fetchStatus).toBe('idle');
    });

    it('fetches single inventory item', async () => {
      mockGetById.mockResolvedValue({ id: 'inv1', ingredient_name: 'Aceite' });
      const { result } = renderHook(() => useInventoryItem('inv1'), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetById).toHaveBeenCalledWith('inv1');
    });
  });

  describe('useCreateInventoryItem', () => {
    it('creates an inventory item', async () => {
      mockCreate.mockResolvedValue({ id: 'new-inv' });
      const { result } = renderHook(() => useCreateInventoryItem(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ ingredient_name: 'Sal' } as any);
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockCreate).toHaveBeenCalledWith({ ingredient_name: 'Sal' });
    });
  });

  describe('useUpdateInventoryItem', () => {
    it('updates an inventory item', async () => {
      mockUpdate.mockResolvedValue({});
      const { result } = renderHook(() => useUpdateInventoryItem(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ id: 'inv1', data: { ingredient_name: 'Pimienta' } as any });
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockUpdate).toHaveBeenCalledWith('inv1', { ingredient_name: 'Pimienta' });
    });
  });

  describe('useDeleteInventoryItem', () => {
    it('deletes an inventory item', async () => {
      mockDelete.mockResolvedValue(undefined);
      const { result } = renderHook(() => useDeleteInventoryItem(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate('inv1');
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockDelete).toHaveBeenCalledWith('inv1');
    });
  });
});
