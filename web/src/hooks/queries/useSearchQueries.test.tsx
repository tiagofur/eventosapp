import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

const mockSearchAll = vi.fn();
vi.mock('@/services/searchService', () => ({
  searchService: {
    searchAll: (...args: any[]) => mockSearchAll(...args),
  },
}));

import { useSearch } from './useSearchQueries';

const createWrapper = () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
};

describe('useSearchQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('useSearch', () => {
    it('does not fetch when query is empty', () => {
      const { result } = renderHook(() => useSearch(''), {
        wrapper: createWrapper(),
      });

      expect(result.current.fetchStatus).toBe('idle');
      expect(mockSearchAll).not.toHaveBeenCalled();
    });

    it('does not fetch when query is whitespace only', () => {
      const { result } = renderHook(() => useSearch('   '), {
        wrapper: createWrapper(),
      });

      expect(result.current.fetchStatus).toBe('idle');
      expect(mockSearchAll).not.toHaveBeenCalled();
    });

    it('fetches when query has content', async () => {
      mockSearchAll.mockResolvedValue({ events: [], clients: [] });
      const { result } = renderHook(() => useSearch('boda'), {
        wrapper: createWrapper(),
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockSearchAll).toHaveBeenCalledWith('boda');
      expect(result.current.data).toEqual({ events: [], clients: [] });
    });

    it('returns error when service fails', async () => {
      mockSearchAll.mockRejectedValue(new Error('Search failed'));
      const { result } = renderHook(() => useSearch('test'), {
        wrapper: createWrapper(),
      });

      await waitFor(() => expect(result.current.isError).toBe(true));
    });
  });
});
