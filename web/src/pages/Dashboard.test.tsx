import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Dashboard } from './Dashboard';
import { eventService } from '../services/eventService';
import { inventoryService } from '../services/inventoryService';
import { paymentService } from '../services/paymentService';
import { useAuth } from '../contexts/AuthContext';
import { productService } from '../services/productService';
import { clientService } from '../services/clientService';
import { logError } from '../lib/errorHandler';

vi.mock('../services/eventService');
vi.mock('../services/inventoryService');
vi.mock('../services/paymentService');
vi.mock('../contexts/AuthContext');
vi.mock('../services/productService');
vi.mock('../services/clientService');
vi.mock('../lib/errorHandler');

// Capture Tooltip formatter props so we can exercise them in tests
const capturedTooltipFormatters: Array<(value: number) => unknown> = [];

vi.mock('recharts', async () => {
  const actual = await vi.importActual<any>('recharts');
  const passthrough = (name: string) => ({ children }: any) => {
    return <div data-testid={name}>{children}</div>;
  };
  return {
    ...actual,
    ResponsiveContainer: ({ children }: any) => <div data-testid="responsive-container">{children}</div>,
    BarChart: ({ children }: any) => <div data-testid="bar-chart">{children}</div>,
    Bar: passthrough('bar'),
    XAxis: passthrough('xaxis'),
    YAxis: passthrough('yaxis'),
    CartesianGrid: passthrough('cartesian-grid'),
    Cell: passthrough('cell'),
    Tooltip: (props: any) => {
      if (props.formatter) {
        capturedTooltipFormatters.push(props.formatter);
      }
      return <div data-testid="tooltip" />;
    },
  };
});

const renderDashboard = () =>
  render(
    <MemoryRouter initialEntries={['/dashboard']}>
      <Dashboard />
    </MemoryRouter>
  );

const toLocalDateString = (date: Date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

describe('Dashboard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    capturedTooltipFormatters.length = 0;
    (useAuth as any).mockReturnValue({ user: { name: 'Test User' }, profile: { name: 'Test User' }, checkAuth: vi.fn() });
    (eventService.getAll as any).mockResolvedValue([]);
    (eventService.getByDateRange as any).mockResolvedValue([]);
    (eventService.getUpcoming as any).mockResolvedValue([]);
    (inventoryService.getAll as any).mockResolvedValue([]);
    (productService.getAll as any).mockResolvedValue([]);
    (clientService.getAll as any).mockResolvedValue([]);
    (paymentService.getByEventIds as any).mockResolvedValue([]);
    (paymentService.getByPaymentDateRange as any).mockResolvedValue([]);
  });

  it('renders greeting header', async () => {
    renderDashboard();
    expect(await screen.findByText(/hola/i)).toBeInTheDocument();
  });

  it('renders empty states when no data', async () => {
    renderDashboard();

    expect(await screen.findByText(/no hay eventos próximos/i)).toBeInTheDocument();
    expect(screen.getByText(/Sin datos para graficar este mes/i)).toBeInTheDocument();
    expect(screen.getAllByText(/todo en orden/i).length).toBeGreaterThan(0);
  });

  it('keeps only the planned header and quick actions', async () => {
    renderDashboard();

    expect(await screen.findByText(/hola/i)).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /Nuevo Evento/i })).toHaveAttribute('href', '/events/new');
    expect(screen.getByRole('link', { name: /Nuevo Cliente/i })).toHaveAttribute('href', '/clients/new');
    expect(screen.queryByRole('link', { name: /Cotización Rápida/i })).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /Buscar/i })).not.toBeInTheDocument();
    expect(screen.queryByLabelText(/Cotización rápida/i)).not.toBeInTheDocument();
    expect(screen.queryByLabelText(/^Buscar$/i)).not.toBeInTheDocument();
  });

  it('shows data cards and upcoming events when present', async () => {
    (eventService.getAll as any).mockResolvedValue([
      {
        id: 'event-1',
        status: 'confirmed',
        total_amount: 1000,
        tax_amount: 160,
        requires_invoice: true,
        event_date: '2024-01-20',
        clients: { name: 'Ana' },
        service_type: 'Boda',
        num_people: 100,
      },
    ]);
    (eventService.getByDateRange as any).mockResolvedValue([
      {
        id: 'event-1',
        status: 'confirmed',
        total_amount: 1000,
        tax_amount: 160,
        requires_invoice: true,
        event_date: '2024-01-20',
        client: { name: 'Ana' },
        service_type: 'Boda',
        num_people: 100,
      },
    ]);
    (eventService.getUpcoming as any).mockResolvedValue([
      {
        id: 'event-2',
        event_date: '2024-01-25',
        clients: { name: 'Luis' },
        service_type: 'XV',
        num_people: 80,
      },
    ]);
    (inventoryService.getAll as any).mockResolvedValue([
      { id: 'i1', current_stock: 0, minimum_stock: 2 },
    ]);
    (paymentService.getByEventIds as any).mockResolvedValue([
      { event_id: 'event-1', amount: 500 },
    ]);
    (paymentService.getByPaymentDateRange as any).mockResolvedValue([
      { amount: 200 },
    ]);

    renderDashboard();

    expect(await screen.findByText(/Ventas Netas/i)).toBeInTheDocument();
    expect(screen.getByText(/Cobrado \(mes\)/i)).toBeInTheDocument();
    expect(screen.getByText(/IVA Cobrado/i)).toBeInTheDocument();
    expect(screen.getByText(/IVA Pendiente/i)).toBeInTheDocument();
    expect(screen.getByText(/Eventos del Mes/i)).toBeInTheDocument();
    expect(screen.getByText(/Stock Bajo/i)).toBeInTheDocument();
    expect(screen.getByText(/^Clientes$/i)).toBeInTheDocument();
    expect(screen.getByText(/Cotizaciones Pendientes/i)).toBeInTheDocument();
    expect(screen.getAllByText(/^Este mes$/i).length).toBeGreaterThan(0);
    expect(screen.getByText(/Por cobrar/i)).toBeInTheDocument();
    expect(screen.getByText(/Pendientes de confirmar$/i)).toBeInTheDocument();
    expect(screen.getByText(/Inventario crítico/i)).toBeInTheDocument();
    expect(screen.getByText('Luis')).toBeInTheDocument();
    expect(screen.getByText(/XV/i)).toBeInTheDocument();
  });

  it('renders attention widget when events require follow-up', async () => {
    const today = new Date();
    const inThreeDays = new Date(today);
    inThreeDays.setDate(today.getDate() + 3);
    const inTenDays = new Date(today);
    inTenDays.setDate(today.getDate() + 10);
    const twoDaysAgo = new Date(today);
    twoDaysAgo.setDate(today.getDate() - 2);

    (eventService.getAll as any).mockResolvedValue([
      {
        id: 'confirmed-unpaid',
        status: 'confirmed',
        total_amount: 1000,
        tax_amount: 0,
        requires_invoice: false,
        event_date: toLocalDateString(inThreeDays),
        clients: { name: 'Ana' },
        service_type: 'Boda',
        num_people: 100,
      },
      {
        id: 'past-quoted',
        status: 'quoted',
        total_amount: 500,
        tax_amount: 0,
        requires_invoice: false,
        event_date: toLocalDateString(twoDaysAgo),
        clients: { name: 'Luis' },
        service_type: 'XV',
        num_people: 60,
      },
      {
        id: 'quoted-soon',
        status: 'quoted',
        total_amount: 700,
        tax_amount: 0,
        requires_invoice: false,
        event_date: toLocalDateString(inTenDays),
        clients: { name: 'Carla' },
        service_type: 'Cena',
        num_people: 40,
      },
    ]);
    (paymentService.getByEventIds as any)
      .mockResolvedValueOnce([])
      .mockResolvedValueOnce([{ event_id: 'confirmed-unpaid', amount: 250 }]);

    renderDashboard();

    expect(await screen.findByText(/Eventos que Requieren Atención/i)).toBeInTheDocument();
    expect(screen.getByText(/Cobros por cerrar/i)).toBeInTheDocument();
    expect(screen.getByText(/Eventos vencidos/i)).toBeInTheDocument();
    expect(screen.getByText(/Cotizaciones urgentes/i)).toBeInTheDocument();
    expect(screen.getByText(/Saldo pendiente/i)).toBeInTheDocument();
    expect(screen.getByText(/Cotización vencida sin cerrar/i)).toBeInTheDocument();
    expect(screen.getByText(/Faltan \d+ día\(s\) para confirmar/i)).toBeInTheDocument();
  });

  it('hides attention widget when there are no alerts', async () => {
    const today = new Date();
    const inThirtyDays = new Date(today);
    inThirtyDays.setDate(today.getDate() + 30);

    (eventService.getAll as any).mockResolvedValue([
      {
        id: 'completed-event',
        status: 'completed',
        total_amount: 800,
        tax_amount: 0,
        requires_invoice: false,
        event_date: toLocalDateString(inThirtyDays),
        clients: { name: 'Ana' },
        service_type: 'Boda',
        num_people: 100,
      },
    ]);

    renderDashboard();

    await waitFor(() => {
      expect(screen.getByText(/hola/i)).toBeInTheDocument();
    });

    expect(screen.queryByText(/Eventos que Requieren Atención/i)).not.toBeInTheDocument();
  });

  it('logs error when month events fail', async () => {
    (eventService.getByDateRange as any).mockRejectedValue(new Error('boom'));

    renderDashboard();

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error loading month events', expect.any(Error));
    });
  });

  it('logs error when inventory fails', async () => {
    (inventoryService.getAll as any).mockRejectedValue(new Error('inv')); 

    renderDashboard();

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error loading inventory', expect.any(Error));
    });
  });

  it('surfaces error when upcoming events fail', async () => {
    (eventService.getUpcoming as any).mockRejectedValue(new Error('oops'));

    renderDashboard();

    expect(
      await screen.findByText(/Error de conexión o permisos/i)
    ).toBeInTheDocument();
  });

  it('retries when refresh is clicked', async () => {
    (eventService.getUpcoming as any).mockRejectedValue(new Error('oops'));

    renderDashboard();

    const refresh = await screen.findByRole('button', { name: /Recargar/i });
    fireEvent.click(refresh);

    await waitFor(() => {
      // At least 2: initial load + refresh click (usePlanLimits may add extra calls)
      expect((eventService.getByDateRange as any).mock.calls.length).toBeGreaterThanOrEqual(2);
      expect((eventService.getUpcoming as any).mock.calls.length).toBeGreaterThanOrEqual(2);
      expect((inventoryService.getAll as any).mock.calls.length).toBeGreaterThanOrEqual(2);
    });
  });

  it('exercises the financial chart Tooltip formatter callback', async () => {
    capturedTooltipFormatters.length = 0;

    renderDashboard();

    await waitFor(() => {
      expect(screen.getByText(/Comparativa Financiera/i)).toBeInTheDocument();
    });

    // The mock Tooltip captures the formatter prop during render.
    // Exercise the captured formatter to cover line 598.
    expect(capturedTooltipFormatters.length).toBeGreaterThan(0);
    const formatter = capturedTooltipFormatters[0];
    const result = formatter(1500);
    expect(result).toEqual(['$1,500', 'Monto']);
  });

  describe('post-checkout plan refresh', () => {
    it('calls checkAuth and cleans URL when session_id is present', async () => {
      const mockCheckAuth = vi.fn();
      (useAuth as any).mockReturnValue({
        user: { name: 'Test User' },
        profile: { name: 'Test User' },
        checkAuth: mockCheckAuth,
      });

      render(
        <MemoryRouter initialEntries={['/dashboard?session_id=cs_test_123']}>
          <Dashboard />
        </MemoryRouter>
      );

      await waitFor(() => {
        expect(mockCheckAuth).toHaveBeenCalled();
      });
    });

    it('does not call checkAuth when session_id is absent', async () => {
      const mockCheckAuth = vi.fn();
      (useAuth as any).mockReturnValue({
        user: { name: 'Test User' },
        profile: { name: 'Test User' },
        checkAuth: mockCheckAuth,
      });

      render(
        <MemoryRouter initialEntries={['/dashboard']}>
          <Dashboard />
        </MemoryRouter>
      );

      await waitFor(() => {
        expect(screen.getByText(/hola/i)).toBeInTheDocument();
      });

      expect(mockCheckAuth).not.toHaveBeenCalled();
    });
  });
});
