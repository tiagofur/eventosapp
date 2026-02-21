import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Landing } from './Landing';

const mockToggleTheme = vi.fn();
let mockTheme = 'light';

vi.mock('../hooks/useTheme', () => ({
  useTheme: () => ({ theme: mockTheme, toggleTheme: mockToggleTheme }),
}));

describe('Landing', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders hero and navigation links', () => {
    render(
      <MemoryRouter>
        <Landing />
      </MemoryRouter>
    );
    expect(screen.getByText(/Gestiona tus eventos/i)).toBeInTheDocument();
    expect(screen.getAllByRole('link', { name: /iniciar sesión/i })[0]).toBeInTheDocument();
    expect(screen.getAllByRole('link', { name: /comenzar/i })[0]).toBeInTheDocument();
  });

  it('toggles theme', () => {
    mockTheme = 'light';
    render(
      <MemoryRouter>
        <Landing />
      </MemoryRouter>
    );
    fireEvent.click(screen.getByRole('button', { name: /toggle theme/i }));
    expect(mockToggleTheme).toHaveBeenCalled();
  });

  it('renders dark theme icon when active', () => {
    mockTheme = 'dark';
    render(
      <MemoryRouter>
        <Landing />
      </MemoryRouter>
    );
    expect(screen.getByRole('button', { name: /toggle theme/i })).toBeInTheDocument();
  });
});
