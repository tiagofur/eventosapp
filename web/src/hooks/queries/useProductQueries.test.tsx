import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor, act } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

const mockGetAll = vi.fn();
const mockGetPage = vi.fn();
const mockGetById = vi.fn();
const mockGetIngredients = vi.fn();
const mockCreate = vi.fn();
const mockUpdate = vi.fn();
const mockUpdateIngredients = vi.fn();
const mockDelete = vi.fn();
const mockUploadImage = vi.fn();

vi.mock('@/services/productService', () => ({
  productService: {
    getAll: (...args: any[]) => mockGetAll(...args),
    getPage: (...args: any[]) => mockGetPage(...args),
    getById: (...args: any[]) => mockGetById(...args),
    getIngredients: (...args: any[]) => mockGetIngredients(...args),
    create: (...args: any[]) => mockCreate(...args),
    update: (...args: any[]) => mockUpdate(...args),
    updateIngredients: (...args: any[]) => mockUpdateIngredients(...args),
    delete: (...args: any[]) => mockDelete(...args),
    uploadImage: (...args: any[]) => mockUploadImage(...args),
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
  useProducts,
  useProduct,
  useProductsPaginated,
  useProductIngredients,
  useCreateProduct,
  useUpdateProduct,
  useDeleteProduct,
  useUploadProductImage,
} from './useProductQueries';

const createWrapper = () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
};

describe('useProductQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  // ── Queries ──

  describe('useProducts', () => {
    it('fetches all products', async () => {
      mockGetAll.mockResolvedValue([{ id: '1', name: 'Producto A' }]);
      const { result } = renderHook(() => useProducts(), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetAll).toHaveBeenCalledTimes(1);
      expect(result.current.data).toHaveLength(1);
    });
  });

  describe('useProductsPaginated', () => {
    it('fetches paginated products', async () => {
      mockGetPage.mockResolvedValue({ data: [{ id: '1' }], total: 1, total_pages: 1 });
      const { result } = renderHook(
        () => useProductsPaginated({ page: 1, limit: 10, sort: 'name', order: 'asc' }),
        { wrapper: createWrapper() },
      );

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetPage).toHaveBeenCalledWith({ page: 1, limit: 10, sort: 'name', order: 'asc' });
    });
  });

  describe('useProduct', () => {
    it('does not fetch when id is undefined', () => {
      const { result } = renderHook(() => useProduct(undefined), { wrapper: createWrapper() });
      expect(result.current.fetchStatus).toBe('idle');
    });

    it('fetches product by id', async () => {
      mockGetById.mockResolvedValue({ id: 'p1', name: 'Producto' });
      const { result } = renderHook(() => useProduct('p1'), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetById).toHaveBeenCalledWith('p1');
    });
  });

  describe('useProductIngredients', () => {
    it('does not fetch when productId is undefined', () => {
      const { result } = renderHook(() => useProductIngredients(undefined), { wrapper: createWrapper() });
      expect(result.current.fetchStatus).toBe('idle');
    });

    it('fetches ingredients for a product', async () => {
      mockGetIngredients.mockResolvedValue([{ id: 'i1', name: 'Harina' }]);
      const { result } = renderHook(() => useProductIngredients('p1'), { wrapper: createWrapper() });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetIngredients).toHaveBeenCalledWith('p1');
    });
  });

  // ── Mutations ──

  describe('useCreateProduct', () => {
    it('creates a product without ingredients', async () => {
      mockCreate.mockResolvedValue({ id: 'new-1', name: 'New Product' });
      const { result } = renderHook(() => useCreateProduct(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ product: { name: 'New Product' } as any, ingredients: [] });
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockCreate).toHaveBeenCalledWith({ name: 'New Product' });
      expect(mockUpdateIngredients).not.toHaveBeenCalled();
    });

    it('creates a product and updates ingredients', async () => {
      mockCreate.mockResolvedValue({ id: 'new-1' });
      const ingredients = [{ inventoryId: 'inv1', quantityRequired: 5 }];
      const { result } = renderHook(() => useCreateProduct(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate({ product: {} as any, ingredients });
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockCreate).toHaveBeenCalledTimes(1);
      expect(mockUpdateIngredients).toHaveBeenCalledWith('new-1', ingredients);
    });
  });

  describe('useUpdateProduct', () => {
    it('updates a product and its ingredients', async () => {
      mockUpdate.mockResolvedValue({});
      const { result } = renderHook(() => useUpdateProduct(), { wrapper: createWrapper() });

      const ingredients = [{ inventoryId: 'inv1', quantityRequired: 3 }];
      await act(async () => {
        result.current.mutate({ id: 'p1', product: { name: 'Updated' } as any, ingredients });
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockUpdate).toHaveBeenCalledWith('p1', { name: 'Updated' });
      expect(mockUpdateIngredients).toHaveBeenCalledWith('p1', ingredients);
    });
  });

  describe('useDeleteProduct', () => {
    it('deletes a product', async () => {
      mockDelete.mockResolvedValue(undefined);
      const { result } = renderHook(() => useDeleteProduct(), { wrapper: createWrapper() });

      await act(async () => {
        result.current.mutate('p1');
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockDelete).toHaveBeenCalledWith('p1');
    });
  });

  describe('useUploadProductImage', () => {
    it('uploads an image', async () => {
      mockUploadImage.mockResolvedValue({ url: 'https://example.com/img.png' });
      const { result } = renderHook(() => useUploadProductImage(), { wrapper: createWrapper() });

      const file = new File([''], 'test.png', { type: 'image/png' });
      await act(async () => {
        result.current.mutate(file);
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockUploadImage).toHaveBeenCalledWith(file);
    });
  });
});
