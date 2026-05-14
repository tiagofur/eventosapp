import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React from 'react';

const mockGetDates = vi.fn();
const mockAddDates = vi.fn();
const mockRemoveDate = vi.fn();

vi.mock('../../services/unavailableDatesService', () => ({
  unavailableDatesService: {
    getDates: (...args: any[]) => mockGetDates(...args),
    addDates: (...args: any[]) => mockAddDates(...args),
    removeDate: (...args: any[]) => mockRemoveDate(...args),
  },
}));

import {
  useUnavailableDatesByRange,
  useCreateUnavailableDates,
  useDeleteUnavailableDate,
} from './useUnavailableDatesQueries';
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

describe('useUnavailableDatesQueries', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('does not fetch when range is incomplete', () => {
    const { wrapper } = createWrapper();
    const { result } = renderHook(() => useUnavailableDatesByRange('', '2026-12-01'), { wrapper });

    expect(result.current.fetchStatus).toBe('idle');
    expect(mockGetDates).not.toHaveBeenCalled();
  });

  it('fetches unavailable dates by range', async () => {
    mockGetDates.mockResolvedValue([{ id: 'u1', start_date: '2026-08-01', end_date: '2026-08-03' }]);
    const { wrapper } = createWrapper();

    const { result } = renderHook(() => useUnavailableDatesByRange('2026-08-01', '2026-08-31'), { wrapper });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(mockGetDates).toHaveBeenCalledWith('2026-08-01', '2026-08-31');
    expect(result.current.data).toEqual([{ id: 'u1', start_date: '2026-08-01', end_date: '2026-08-03' }]);
  });

  it('invalidates unavailable dates list after create mutation', async () => {
    mockAddDates.mockResolvedValue({ id: 'created' });
    const { wrapper, queryClient } = createWrapper();
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

    const { result } = renderHook(() => useCreateUnavailableDates(), { wrapper });

    await act(async () => {
      await result.current.mutateAsync({ start_date: '2026-09-01', end_date: '2026-09-02', reason: 'holiday' });
    });

    expect(mockAddDates).toHaveBeenCalledWith({
      start_date: '2026-09-01',
      end_date: '2026-09-02',
      reason: 'holiday',
    });
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: queryKeys.unavailableDates.all });
  });

  it('invalidates unavailable dates list after delete mutation', async () => {
    mockRemoveDate.mockResolvedValue(undefined);
    const { wrapper, queryClient } = createWrapper();
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries');

    const { result } = renderHook(() => useDeleteUnavailableDate(), { wrapper });

    await act(async () => {
      await result.current.mutateAsync('block-1');
    });

    expect(mockRemoveDate).toHaveBeenCalledWith('block-1');
    expect(invalidateSpy).toHaveBeenCalledWith({ queryKey: queryKeys.unavailableDates.all });
  });
});