import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ClientDetails } from './ClientDetails';
import { clientService } from '../../services/clientService';
import { eventService } from '../../services/eventService';

let mockParams: { id?: string } = { id: 'client-1' };

vi.mock('../../services/clientService', () => ({
  clientService: {
    getById: vi.fn(),
  },
}));

vi.mock('../../services/eventService', () => ({
  eventService: {
    getByClientId: vi.fn(),
  },
}));

vi.mock('../../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return {
    ...actual,
    useParams: () => mockParams,
    useNavigate: () => vi.fn(),
  };
});

const renderDetails = () =>
  render(
    <MemoryRouter>
      <ClientDetails />
    </MemoryRouter>
  );

describe('ClientDetails', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockParams = { id: 'client-1' };
  });

  it('renders client details and events', async () => {
    (clientService.getById as any).mockResolvedValue({
      id: 'client-1',
      name: 'Ana Perez',
      phone: '5551112222',
      email: 'ana@example.com',
      address: 'Calle 1',
      total_spent: 1200,
      notes: 'VIP',
    });
    (eventService.getByClientId as any).mockResolvedValue([
      {
        id: 'event-1',
        service_type: 'Boda',
        status: 'confirmed',
        event_date: '2024-01-02',
        num_people: 100,
        total_amount: 3000,
      },
    ]);

    renderDetails();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });
    expect(screen.getByText('Información del Cliente')).toBeInTheDocument();
    expect(screen.getByText('Boda')).toBeInTheDocument();
    expect(screen.getByText('Confirmado')).toBeInTheDocument();
  });

  it('shows empty events state', async () => {
    (clientService.getById as any).mockResolvedValue({
      id: 'client-1',
      name: 'Ana Perez',
      phone: '5551112222',
      email: null,
      address: null,
      total_spent: 0,
      notes: null,
    });
    (eventService.getByClientId as any).mockResolvedValue([]);

    renderDetails();

    await waitFor(() => {
      expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    });
    expect(screen.getByText(/No hay eventos registrados/i)).toBeInTheDocument();
  });

  it('renders not found message when client is missing', async () => {
    (clientService.getById as any).mockResolvedValue(null);
    (eventService.getByClientId as any).mockResolvedValue([]);

    renderDetails();

    await waitFor(() => {
      expect(screen.getByText('Cliente no encontrado')).toBeInTheDocument();
    });
  });
});
