import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ClientForm } from './ClientForm';
import { logError } from '../../lib/errorHandler';
import { clientService } from '../../services/clientService';

const mockNavigate = vi.fn();
let mockParams: { id?: string } = {};

vi.mock('../../services/clientService', () => ({
  clientService: {
    getById: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
  },
}));

vi.mock('../../contexts/AuthContext', () => ({
  useAuth: () => ({ user: { id: 'user-1' } }),
}));

vi.mock('../../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
    useParams: () => mockParams,
  };
});

const renderForm = () =>
  render(
    <MemoryRouter>
      <ClientForm />
    </MemoryRouter>
  );

describe('ClientForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockParams = {};
  });

  it('shows validation errors for required fields', async () => {
    renderForm();
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(screen.getByText(/El nombre debe tener al menos 2 caracteres/i)).toBeInTheDocument();
      expect(screen.getByText(/El teléfono debe tener al menos 10 dígitos/i)).toBeInTheDocument();
    });
  });

  it('creates a new client', async () => {
    (clientService.create as any).mockResolvedValue({});
    const { container } = renderForm();

    fireEvent.change(container.querySelector('input[name="name"]')!, {
      target: { value: 'Ana Perez' },
    });
    fireEvent.change(container.querySelector('input[name="phone"]')!, {
      target: { value: '5551112222' },
    });
    fireEvent.change(container.querySelector('input[name="email"]')!, {
      target: { value: 'ana@example.com' },
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(clientService.create).toHaveBeenCalledWith({
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: '',
        city: '',
        notes: '',
        user_id: 'user-1',
      });
    });
    expect(mockNavigate).toHaveBeenCalledWith('/clients');
  });

  it('loads and updates an existing client', async () => {
    mockParams = { id: 'client-1' };
    (clientService.getById as any).mockResolvedValue({
      id: 'client-1',
      name: 'Ana Perez',
      phone: '5551112222',
      email: 'ana@example.com',
      address: 'Calle 1',
      city: 'CDMX',
      notes: 'VIP',
    });
    (clientService.update as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect((container.querySelector('input[name="name"]') as HTMLInputElement).value).toBe('Ana Perez');
    });

    fireEvent.change(container.querySelector('input[name="phone"]')!, {
      target: { value: '5550000000' },
    });
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(clientService.update).toHaveBeenCalledWith('client-1', {
        name: 'Ana Perez',
        phone: '5550000000',
        email: 'ana@example.com',
        address: 'Calle 1',
        city: 'CDMX',
        notes: 'VIP',
      });
    });
    expect(mockNavigate).toHaveBeenCalledWith('/clients');
  });

  it('shows error when client load fails', async () => {
    mockParams = { id: 'client-1' };
    (clientService.getById as any).mockResolvedValue(null);

    renderForm();

    await waitFor(() => {
      expect(screen.getByText(/Error al cargar el cliente/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error loading client', expect.any(Error));
  });

  it('shows error when save fails', async () => {
    (clientService.create as any).mockRejectedValueOnce(new Error('fail'));

    const { container } = renderForm();

    fireEvent.change(container.querySelector('input[name="name"]')!, {
      target: { value: 'Ana Perez' },
    });
    fireEvent.change(container.querySelector('input[name="phone"]')!, {
      target: { value: '5551112222' },
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(screen.getByText(/fail/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error saving client', expect.any(Error));
  });

  it('normalizes empty email to null on update', async () => {
    mockParams = { id: 'client-1' };
    (clientService.getById as any).mockResolvedValue({
      id: 'client-1',
      name: 'Ana Perez',
      phone: '5551112222',
      email: '',
      address: '',
      city: '',
      notes: '',
    });
    (clientService.update as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect((container.querySelector('input[name="name"]') as HTMLInputElement).value).toBe('Ana Perez');
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(clientService.update).toHaveBeenCalledWith('client-1', {
        name: 'Ana Perez',
        phone: '5551112222',
        email: null,
        address: '',
        city: '',
        notes: '',
      });
    });
  });
});
