import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Register } from './Register';
import { api } from '../lib/api';

const mockCheckAuth = vi.fn();
const mockNavigate = vi.fn();

vi.mock('../contexts/AuthContext', () => ({
  useAuth: () => ({ checkAuth: mockCheckAuth }),
}));

vi.mock('../hooks/useTheme', () => ({
  useTheme: () => ({ theme: 'light', toggleTheme: vi.fn() }),
}));

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return { ...actual, useNavigate: () => mockNavigate };
});

vi.mock('../lib/api', () => ({
  api: {
    post: vi.fn(),
  },
}));

describe('Register', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders registration form', () => {
    render(
      <MemoryRouter>
        <Register />
      </MemoryRouter>
    );
    expect(screen.getByText('Crear Cuenta')).toBeInTheDocument();
    expect(screen.getByLabelText(/nombre completo/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/^email$/i)).toBeInTheDocument();
  });

  it('shows validation errors', async () => {
    render(
      <MemoryRouter>
        <Register />
      </MemoryRouter>
    );
    fireEvent.click(screen.getByRole('button', { name: /registrarse/i }));
    await waitFor(() => {
      expect(screen.getByText(/El nombre debe tener al menos 2 caracteres/i)).toBeInTheDocument();
      expect(screen.getByText(/Email inválido/i)).toBeInTheDocument();
    });
  });

  it('submits registration and navigates', async () => {
    (api.post as any).mockResolvedValue({ tokens: { access_token: 'token' } });
    render(
      <MemoryRouter>
        <Register />
      </MemoryRouter>
    );

    fireEvent.change(screen.getByLabelText(/nombre completo/i), {
      target: { value: 'Ana Perez' },
    });
    fireEvent.change(screen.getByLabelText(/^email$/i), {
      target: { value: 'ana@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/^contraseña$/i), {
      target: { value: 'password' },
    });
    fireEvent.change(screen.getByLabelText(/confirmar contraseña/i), {
      target: { value: 'password' },
    });
    fireEvent.click(screen.getByRole('button', { name: /registrarse/i }));

    await waitFor(() => {
      expect(api.post).toHaveBeenCalledWith('/auth/register', {
        name: 'Ana Perez',
        email: 'ana@example.com',
        password: 'password',
      });
    });
    expect(window.localStorage.setItem).toHaveBeenCalledWith('auth_token', 'token');
    expect(mockCheckAuth).toHaveBeenCalled();
    expect(mockNavigate).toHaveBeenCalledWith('/dashboard');
  });

  it('shows error on failed registration', async () => {
    (api.post as any).mockRejectedValue(new Error('Fallo'));
    render(
      <MemoryRouter>
        <Register />
      </MemoryRouter>
    );

    fireEvent.change(screen.getByLabelText(/nombre completo/i), {
      target: { value: 'Ana Perez' },
    });
    fireEvent.change(screen.getByLabelText(/^email$/i), {
      target: { value: 'ana@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/^contraseña$/i), {
      target: { value: 'password' },
    });
    fireEvent.change(screen.getByLabelText(/confirmar contraseña/i), {
      target: { value: 'password' },
    });
    fireEvent.click(screen.getByRole('button', { name: /registrarse/i }));

    await waitFor(() => {
      expect(screen.getByText('Fallo')).toBeInTheDocument();
    });
  });
});
