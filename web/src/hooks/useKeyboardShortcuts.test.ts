import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, act, fireEvent } from '@testing-library/react';

const mockNavigate = vi.fn();
let mockPathname = '/dashboard';

vi.mock('react-router-dom', () => ({
  useNavigate: () => mockNavigate,
  useLocation: () => ({ pathname: mockPathname }),
}));

import { useKeyboardShortcuts } from './useKeyboardShortcuts';

describe('useKeyboardShortcuts', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockPathname = '/dashboard';
  });

  it('detects current section from pathname', () => {
    mockPathname = '/events/evt-1';
    const { result } = renderHook(() => useKeyboardShortcuts());
    expect(result.current.currentSection).toBe('events');
  });

  it('runs contextual "new" shortcut for current section', () => {
    mockPathname = '/clients';
    renderHook(() => useKeyboardShortcuts());

    act(() => {
      fireEvent.keyDown(document, { key: 'n' });
    });

    expect(mockNavigate).toHaveBeenCalledWith('/clients/new');
  });

  it('falls back to events new shortcut outside mapped sections', () => {
    mockPathname = '/calendar';
    renderHook(() => useKeyboardShortcuts());

    act(() => {
      fireEvent.keyDown(document, { key: 'n' });
    });

    expect(mockNavigate).toHaveBeenCalledWith('/events/new');
  });

  it('handles two-key navigation sequence', () => {
    renderHook(() => useKeyboardShortcuts());

    act(() => {
      fireEvent.keyDown(document, { key: 'g' });
      fireEvent.keyDown(document, { key: 'e' });
    });

    expect(mockNavigate).toHaveBeenCalledWith('/events');
  });

  it('ignores shortcuts while typing in input elements', () => {
    renderHook(() => useKeyboardShortcuts());
    const input = document.createElement('input');
    document.body.appendChild(input);

    act(() => {
      fireEvent.keyDown(input, { key: 'n' });
    });

    expect(mockNavigate).not.toHaveBeenCalled();
    document.body.removeChild(input);
  });

  it('ignores shortcuts when modifier keys are pressed', () => {
    renderHook(() => useKeyboardShortcuts());

    act(() => {
      fireEvent.keyDown(document, { key: 'n', ctrlKey: true });
    });

    expect(mockNavigate).not.toHaveBeenCalled();
  });

  it('toggles help open state with question-mark shortcut', () => {
    const { result } = renderHook(() => useKeyboardShortcuts());
    expect(result.current.helpOpen).toBe(false);

    act(() => {
      fireEvent.keyDown(document, { key: '?' });
    });
    expect(result.current.helpOpen).toBe(true);

    act(() => {
      fireEvent.keyDown(document, { key: '?' });
    });
    expect(result.current.helpOpen).toBe(false);
  });
});