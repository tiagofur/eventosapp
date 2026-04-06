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
const mockUploadPhoto = vi.fn();

vi.mock('@/services/clientService', () => ({
  clientService: {
    getAll: (...args: any[]) => mockGetAll(...args),
    getPage: (...args: any[]) => mockGetPage(...args),
    getById: (...args: any[]) => mockGetById(...args),
    create: (...args: any[]) => mockCreate(...args),
    update: (...args: any[]) => mockUpdate(...args),
    delete: (...args: any[]) => mockDelete(...args),
    uploadPhoto: (...args: any[]) => mockUploadPhoto(...args),
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
  useClients,
  useClientsPaginated,
  useClient,
  useCreateClient,
  useUpdateClient,
  useDeleteClient,
  useUploadClientPhoto,
} from './useClientQueries';

const createWrapper = () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
};

describe('useClientQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('useClients', () => {
    it('fetches all clients', async () => {
      mockGetAll.mockResolvedValue([{ id: 'cl1', name: 'Ana' }]);
      const { result } = renderHook(() => useClients(), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetAll).toHaveBeenCalledTimes(1);
    });
  });

  describe('useClientsPaginated', () => {
    it('fetches paginated clients', async () => {
      mockGetPage.mockResolvedValue({ data: [], total: 0, total_pages: 0 });
      const { result } = renderHook(
        () => useClientsPaginated({ page: 1, limit: 10, sort: 'name', order: 'asc' }),
        { wrapper: createWrapper() },
      );
      await waitFor(() => expect(result.current.isSuccess).toBe(true));
    });
  });

  describe('useClient', () => {
    it('does not fetch when id is undefined', () => {
      const { result } = renderHook(() => useClient(undefined), { wrapper: createWrapper() });
      expect(result.current.fetchStatus).toBe('idle');
    });

    it('fetches client by id', async () => {
      mockGetById.mockResolvedValue({ id: 'cl1', name: 'Ana' });
      const { result } = renderHook(() => useClient('cl1'), { wrapper: createWrapper() });
      await waitFor(() => expect(result.current.isSuccess).toBe(true));
    });
  });

  describe('useCreateClient', () => {
    it('creates a client', async () => {
      mockCreate.mockResolvedValue({ id: 'new-cl' });
      const { result } = renderHook(() => useCreateClient(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ name: 'New Client' } as any);
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockCreate).toHaveBeenCalled();
    });
  });

  describe('useUpdateClient', () => {
    it('updates a client', async () => {
      mockUpdate.mockResolvedValue({});
      const { result } = renderHook(() => useUpdateClient(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ id: 'cl1', data: { name: 'Updated' } as any });
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockUpdate).toHaveBeenCalledWith('cl1', { name: 'Updated' });
    });
  });

  describe('useDeleteClient', () => {
    it('deletes a client', async () => {
      mockDelete.mockResolvedValue(undefined);
      const { result } = renderHook(() => useDeleteClient(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate('cl1');
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockDelete).toHaveBeenCalledWith('cl1');
    });
  });

  describe('useUploadClientPhoto', () => {
    it('uploads a photo', async () => {
      mockUploadPhoto.mockResolvedValue({ url: 'https://example.com/photo.png' });
      const { result } = renderHook(() => useUploadClientPhoto(), { wrapper: createWrapper() });

      const file = new File([''], 'photo.png', { type: 'image/png' });
      await act(async () => {
        result.current.mutate(file);
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockUploadPhoto).toHaveBeenCalledWith(file);
    });
  });
});
