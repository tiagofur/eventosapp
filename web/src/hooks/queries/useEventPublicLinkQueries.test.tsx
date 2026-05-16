import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

const mockGetActiveOrNull = vi.fn();
const mockCreateOrRotate = vi.fn();
const mockRevoke = vi.fn();

vi.mock('@/services/eventPublicLinkService', () => ({
  eventPublicLinkService: {
    getActiveOrNull: (...args: any[]) => mockGetActiveOrNull(...args),
    createOrRotate: (...args: any[]) => mockCreateOrRotate(...args),
    revoke: (...args: any[]) => mockRevoke(...args),
  },
}));

import {
  useEventPublicLink,
  useCreateOrRotateEventPublicLink,
  useRevokeEventPublicLink,
} from './useEventPublicLinkQueries';
import { queryKeys } from './queryKeys';

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );

  return { wrapper, queryClient };
}

describe('useEventPublicLinkQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('does not fetch when eventId is empty', () => {
    const { wrapper } = createWrapper();
    const { result } = renderHook(() => useEventPublicLink(''), { wrapper });

    expect(result.current.fetchStatus).toBe('idle');
    expect(mockGetActiveOrNull).not.toHaveBeenCalled();
  });

  it('fetches active link when eventId exists', async () => {
    mockGetActiveOrNull.mockResolvedValue({ token: 'abc' });
    const { wrapper } = createWrapper();

    const { result } = renderHook(() => useEventPublicLink('event-1'), { wrapper });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockGetActiveOrNull).toHaveBeenCalledWith('event-1');
    expect(result.current.data).toEqual({ token: 'abc' });
  });

  it('invalidates link query after create/rotate mutation', async () => {
    mockCreateOrRotate.mockResolvedValue({ token: 'new-token' });
    const { wrapper, queryClient } = createWrapper();
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

    const { result } = renderHook(() => useCreateOrRotateEventPublicLink('event-2'), { wrapper });

    await act(async () => {
      await result.current.mutateAsync({ ttlDays: 7 });
    });

    expect(mockCreateOrRotate).toHaveBeenCalledWith('event-2', 7);
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: queryKeys.eventPublicLinks.byEvent('event-2') });
  });

  it('revokes link and clears cached query value', async () => {
    mockRevoke.mockResolvedValue(undefined);
    const { wrapper, queryClient } = createWrapper();
    const key = queryKeys.eventPublicLinks.byEvent('event-3');
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

    queryClient.setQueryData(key, { token: 'to-delete' });

    const { result } = renderHook(() => useRevokeEventPublicLink('event-3'), { wrapper });

    await act(async () => {
      await result.current.mutateAsync(undefined);
    });

    expect(mockRevoke).toHaveBeenCalledWith('event-3');
    expect(queryClient.getQueryData(key)).toBeNull();
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: key });
  });
});