import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

// Mock the service
const mockGetStatus = vi.fn();
vi.mock('@/services/subscriptionService', () => ({
  subscriptionService: {
    getStatus: (...args: any[]) => mockGetStatus(...args),
  },
}));

import { useSubscriptionStatus } from './useSubscriptionQueries';

const createWrapper = () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={qc}>{children}</QueryClientProvider>
  );
};

describe('useSubscriptionQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('useSubscriptionStatus', () => {
    it('calls subscriptionService.getStatus', async () => {
      mockGetStatus.mockResolvedValue({ plan: 'free' });
      const { result } = renderHook(() => useSubscriptionStatus(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => expect(result.current.isSuccess).toBe(true));
      expect(mockGetStatus).toHaveBeenCalledTimes(1);
      expect(result.current.data).toEqual({ plan: 'free' });
    });

    it('returns error when service fails', async () => {
      mockGetStatus.mockRejectedValue(new Error('Network error'));
      const { result } = renderHook(() => useSubscriptionStatus(), {
        wrapper: createWrapper(),
      });

      await waitFor(() => expect(result.current.isError).toBe(true));
      expect(result.current.error).toBeDefined();
    });
  });
});
