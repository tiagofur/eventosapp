import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Layout } from './Layout';
import { logError } from '../lib/errorHandler';

const mockSignOut = vi.fn();
const mockToggleTheme = vi.fn();
const mockNavigate = vi.fn();
let mockLocation = { pathname: '/dashboard', search: '' };
let mockTheme = 'light';

vi.mock('../contexts/AuthContext', () => ({
  useAuth: () => ({
    signOut: mockSignOut,
    profile: { name: 'Ana', email: 'ana@example.com' },
  }),
}));

vi.mock('../hooks/useTheme', () => ({
  useTheme: () => ({
    theme: mockTheme,
    toggleTheme: mockToggleTheme,
  }),
}));

vi.mock('../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
    useLocation: () => mockLocation,
  };
});

const renderLayout = () =>
  render(
    <MemoryRouter>
      <Layout />
    </MemoryRouter>
  );

describe('Layout', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockLocation = { pathname: '/dashboard', search: '' };
    mockTheme = 'light';
    Object.defineProperty(window, 'location', {
      value: { href: '' },
      writable: true,
    });
  });

  it('renders navigation and user profile', () => {
    renderLayout();
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Clientes')).toBeInTheDocument();
    expect(screen.getByText('Ana')).toBeInTheDocument();
    expect(screen.getByText('ana@example.com')).toBeInTheDocument();
  });

  it('toggles theme from sidebar control', () => {
    renderLayout();
    fireEvent.click(screen.getByRole('button', { name: /modo oscuro/i }));
    expect(mockToggleTheme).toHaveBeenCalled();
  });

  it('signs out from sidebar action', () => {
    renderLayout();
    fireEvent.click(screen.getByText('Cerrar Sesión'));
    expect(mockSignOut).toHaveBeenCalled();
  });

  it('shows dark theme label in sidebar', () => {
    mockTheme = 'dark';
    renderLayout();
    expect(screen.getByRole('button', { name: /modo claro/i })).toBeInTheDocument();
  });

  it('handles sign out failure and redirects', async () => {
    Object.defineProperty(localStorage, 'sb-test-auth-token', {
      value: 'token',
      configurable: true,
      enumerable: true,
      writable: true,
    });
    mockSignOut.mockRejectedValue(new Error('fail'));

    renderLayout();

    fireEvent.click(screen.getByText('Cerrar Sesión'));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error signing out', expect.any(Error));
    });
    expect(localStorage.removeItem).toHaveBeenCalledWith('sb-test-auth-token');
    expect(window.location.href).toBe('/login');
  });

  it('opens and closes the mobile sidebar', () => {
    const { container } = renderLayout();
    const menuButton = container.querySelector('header button');
    expect(menuButton).toBeTruthy();

    fireEvent.click(menuButton as Element);
    expect(container.querySelector('.fixed.inset-0')).toBeInTheDocument();

    fireEvent.click(container.querySelector('.fixed.inset-0') as Element);
    expect(container.querySelector('.fixed.inset-0')).not.toBeInTheDocument();
  });

  it('closes sidebar when a nav link is clicked', () => {
    const { container } = renderLayout();
    const menuButton = container.querySelector('header button');
    fireEvent.click(menuButton as Element);

    fireEvent.click(screen.getByText('Dashboard'));
    expect(container.querySelector('.fixed.inset-0')).not.toBeInTheDocument();
  });

  it('closes sidebar after search submit', () => {
    const { container } = renderLayout();
    const menuButton = container.querySelector('header button');
    fireEvent.click(menuButton as Element);

    fireEvent.change(screen.getByLabelText(/busqueda global/i), {
      target: { value: 'evento' },
    });
    fireEvent.submit(screen.getByLabelText(/busqueda global/i).closest('form')!);

    expect(container.querySelector('.fixed.inset-0')).not.toBeInTheDocument();
  });

  it('submits search and navigates', () => {
    renderLayout();
    fireEvent.change(screen.getByLabelText(/busqueda global/i), {
      target: { value: 'evento' },
    });
    fireEvent.submit(screen.getByLabelText(/busqueda global/i).closest('form')!);
    expect(mockNavigate).toHaveBeenCalledWith('/search?q=evento');
  });

  it('ignores empty search submissions', () => {
    renderLayout();
    fireEvent.change(screen.getByLabelText(/busqueda global/i), {
      target: { value: '   ' },
    });
    fireEvent.submit(screen.getByLabelText(/busqueda global/i).closest('form')!);
    expect(mockNavigate).not.toHaveBeenCalled();
  });

  it('hydrates search input from query params on search page', async () => {
    mockLocation = { pathname: '/search', search: '?q=clientes' };
    renderLayout();
    await waitFor(() => {
      expect(screen.getByLabelText(/busqueda global/i)).toHaveValue('clientes');
    });
  });
});
