import { describe, it, expect, vi, beforeEach } from 'vitest';

const mockAddToast = vi.fn();
const mockLogError = vi.fn();

vi.mock('@/hooks/useToast', () => ({
  useToast: {
    getState: () => ({ addToast: mockAddToast }),
  },
}));

vi.mock('@/lib/errorHandler', () => ({
  logError: (...args: unknown[]) => mockLogError(...args),
}));

vi.mock('@/i18n/config', () => ({
  default: {
    t: vi.fn(() => 'Error al actualizar en segundo plano'),
  },
}));

import { queryClient } from './queryClient';

describe('queryClient', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('logs query errors and does not toast when query has no previous data', () => {
    const onError = (queryClient.getQueryCache() as any).config.onError;
    onError(new Error('fail'), {
      queryKey: ['clients'],
      state: { data: undefined },
    });

    expect(mockLogError).toHaveBeenCalledWith('Query error [clients]', expect.any(Error));
    expect(mockAddToast).not.toHaveBeenCalled();
  });

  it('toasts background refetch errors only once during cooldown window', () => {
    const onError = (queryClient.getQueryCache() as any).config.onError;
    const nowSpy = vi.spyOn(Date, 'now');
    nowSpy.mockReturnValueOnce(100_000).mockReturnValueOnce(102_000).mockReturnValueOnce(111_000);

    onError(new Error('first'), {
      queryKey: ['events'],
      state: { data: [{ id: '1' }] },
    });
    onError(new Error('second'), {
      queryKey: ['events'],
      state: { data: [{ id: '1' }] },
    });
    onError(new Error('third'), {
      queryKey: ['events'],
      state: { data: [{ id: '1' }] },
    });

    expect(mockAddToast).toHaveBeenCalledTimes(2);
    expect(mockAddToast).toHaveBeenCalledWith('Error al actualizar en segundo plano', 'error');
  });

  it('logs mutation errors with key fallback', () => {
    const onError = (queryClient.getMutationCache() as any).config.onError;
    onError(new Error('mutation fail'), undefined, undefined, {
      options: { mutationKey: ['update-client'] },
    });
    onError(new Error('mutation fail 2'), undefined, undefined, {
      options: {},
    });

    expect(mockLogError).toHaveBeenCalledWith('Mutation error [update-client]', expect.any(Error));
    expect(mockLogError).toHaveBeenCalledWith('Mutation error [unknown]', expect.any(Error));
  });

  it('uses configured default options', () => {
    const defaults = queryClient.getDefaultOptions();
    expect(defaults.queries?.staleTime).toBe(2 * 60 * 1000);
    expect(defaults.queries?.gcTime).toBe(10 * 60 * 1000);
    expect(defaults.queries?.retry).toBe(1);
    expect(defaults.queries?.refetchOnWindowFocus).toBe(true);
    expect(defaults.mutations?.retry).toBe(0);
  });
});