import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ClientList } from './ClientList';
import { clientService } from '../../services/clientService';
import { logError } from '../../lib/errorHandler';

const mockNavigate = vi.fn();

vi.mock('../../services/clientService', () => ({
  clientService: {
    getAll: vi.fn(),
    delete: vi.fn(),
  },
}));

vi.mock('../../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return { ...actual, useNavigate: () => mockNavigate };
});

const renderList = () =>
  render(
    <MemoryRouter>
      <ClientList />
    </MemoryRouter>
  );

describe('ClientList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders clients after loading', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });
    expect(screen.getByText('ana@example.com')).toBeInTheDocument();
    expect(screen.getByText('2 eventos')).toBeInTheDocument();
  });

  it('filters clients by search term', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
      {
        id: '2',
        name: 'Juan Lopez',
        phone: '5553334444',
        email: 'juan@example.com',
        address: 'Calle 2',
        total_events: 1,
        total_spent: 800,
      },
    ]);

    renderList();
    await waitFor(() => {
      expect(screen.getByText('Juan Lopez')).toBeInTheDocument();
    });

    fireEvent.change(screen.getByPlaceholderText('Buscar clientes...'), {
      target: { value: 'Ana' },
    });

    expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    expect(screen.queryByText('Juan Lopez')).not.toBeInTheDocument();
  });

  it('navigates to detail on row click', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('Ana Perez'));
    expect(mockNavigate).toHaveBeenCalledWith('/clients/1');
  });

  it('deletes a client after confirmation', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);
    (clientService.delete as any).mockResolvedValue({});

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTitle('Eliminar'));
    const dialog = screen.getByRole('dialog', { name: 'Eliminar cliente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(clientService.delete).toHaveBeenCalledWith('1');
      expect(screen.queryByText('Ana Perez')).not.toBeInTheDocument();
    });
  });

  it('shows empty state and logs fetch error', async () => {
    (clientService.getAll as any).mockRejectedValueOnce(new Error('fail'));

    renderList();

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error fetching clients', expect.any(Error));
    });
    expect(screen.getByText(/No se encontraron clientes/i)).toBeInTheDocument();
  });

  it('restores state when delete fails', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);
    (clientService.delete as any).mockRejectedValueOnce(new Error('fail'));

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTitle('Eliminar'));
    const dialog = screen.getByRole('dialog', { name: 'Eliminar cliente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error deleting client', expect.any(Error));
    });
    expect(screen.getByText('Ana Perez')).toBeInTheDocument();
  });

  it('clears delete state on cancel', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTitle('Eliminar'));
    const dialog = screen.getByRole('dialog', { name: 'Eliminar cliente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Cancelar' }));

    expect(screen.queryByRole('dialog', { name: 'Eliminar cliente' })).not.toBeInTheDocument();
  });

  it('stops propagation on edit link click', async () => {
    (clientService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Ana Perez',
        phone: '5551112222',
        email: 'ana@example.com',
        address: 'Calle 1',
        total_events: 2,
        total_spent: 1200,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByTitle('Editar'));
    expect(mockNavigate).not.toHaveBeenCalledWith('/clients/1');
  });
});
