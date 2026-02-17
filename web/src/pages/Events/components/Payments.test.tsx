import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { Payments } from './Payments';
import { paymentService } from '../../../services/paymentService';
import { logError } from '../../../lib/errorHandler';

vi.mock('../../../services/paymentService', () => ({
  paymentService: {
    getByEventId: vi.fn(),
    create: vi.fn(),
    delete: vi.fn(),
  },
}));

vi.mock('../../../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

describe('Payments', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders payments and creates a new payment', async () => {
    (paymentService.getByEventId as any).mockResolvedValue([
      { id: 'pay-1', amount: 100, payment_date: '2024-01-02', payment_method: 'cash', notes: '' },
    ]);
    (paymentService.create as any).mockResolvedValue({});

    render(<Payments eventId="event-1" totalAmount={500} userId="user-1" />);

    await waitFor(() => {
      expect(screen.getAllByText('$100.00')).toHaveLength(2);
    });

    fireEvent.click(screen.getByRole('button', { name: /Registrar Nuevo Pago/i }));
    fireEvent.change(screen.getByPlaceholderText('0.00'), { target: { value: '200' } });
    fireEvent.click(screen.getByRole('button', { name: /Guardar Pago/i }));

    await waitFor(() => {
      expect(paymentService.create).toHaveBeenCalledWith(
        expect.objectContaining({
          event_id: 'event-1',
          user_id: 'user-1',
          amount: 200,
        })
      );
    });
  });

  it('deletes a payment after confirmation', async () => {
    (paymentService.getByEventId as any).mockResolvedValue([
      { id: 'pay-1', amount: 100, payment_date: '2024-01-02', payment_method: 'cash', notes: '' },
    ]);
    (paymentService.delete as any).mockResolvedValue({});

    render(<Payments eventId="event-1" totalAmount={500} userId="user-1" />);

    await waitFor(() => {
      expect(screen.getAllByText('$100.00')).toHaveLength(2);
    });

    const amountCells = screen.getAllByText('$100.00');
    const row = amountCells[1].closest('tr');
    expect(row).toBeTruthy();
    fireEvent.click(within(row as HTMLElement).getByRole('button'));
    const dialog = screen.getByRole('dialog', { name: 'Eliminar Pago' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(paymentService.delete).toHaveBeenCalledWith('pay-1');
    });
  });

  it('shows empty state and handles cancel add', async () => {
    (paymentService.getByEventId as any).mockResolvedValue([]);

    render(<Payments eventId="event-1" totalAmount={500} userId="user-1" />);

    await waitFor(() => {
      expect(screen.getByText(/No hay pagos registrados/i)).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Registrar Nuevo Pago/i }));
    fireEvent.click(screen.getByRole('button', { name: /Cancelar/i }));

    expect(screen.getByRole('button', { name: /Registrar Nuevo Pago/i })).toBeInTheDocument();
  });

  it('validates required amount and logs create error', async () => {
    (paymentService.getByEventId as any).mockResolvedValue([]);
    (paymentService.create as any).mockRejectedValue(new Error('fail'));

    render(<Payments eventId="event-1" totalAmount={100} userId="user-1" />);

    await waitFor(() => {
      expect(screen.getByText(/No hay pagos registrados/i)).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Registrar Nuevo Pago/i }));
    fireEvent.change(screen.getByPlaceholderText('0.00'), { target: { value: '20' } });
    fireEvent.click(screen.getByRole('button', { name: /Guardar Pago/i }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error creating payment', expect.any(Error));
    });
  });
});
