import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@tests/customRender';
import { MemoryRouter } from 'react-router-dom';

import { UnavailableDatesModal } from './UnavailableDatesModal';

const mockAddDates = vi.fn();
const mockRemoveDate = vi.fn();
const mockGetDates = vi.fn();

vi.mock('../../../services/unavailableDatesService', () => ({
  unavailableDatesService: {
    getDates: (...a: any[]) => mockGetDates(...a),
    addDates: (...a: any[]) => mockAddDates(...a),
    removeDate: (...a: any[]) => mockRemoveDate(...a),
  },
}));

vi.mock('../../../hooks/useToast', () => ({
  useToast: () => ({ addToast: vi.fn() }),
}));

vi.mock('../../../lib/errorHandler', () => ({ logError: vi.fn() }));

const defaultProps = {
  isOpen: true,
  onClose: vi.fn(),
  onSave: vi.fn(),
  onDelete: vi.fn(),
};

describe('UnavailableDatesModal', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockGetDates.mockResolvedValue([]);
  });

  it('does not render when closed', () => {
    render(<UnavailableDatesModal {...defaultProps} isOpen={false} />);
    expect(screen.queryByText('Fechas Bloqueadas')).not.toBeInTheDocument();
  });

  it('renders modal title when open', () => {
    render(<UnavailableDatesModal {...defaultProps} />);
    expect(screen.getByText('Fechas Bloqueadas')).toBeInTheDocument();
  });

  it('calls onClose when close button clicked', () => {
    const onClose = vi.fn();
    render(<UnavailableDatesModal {...defaultProps} onClose={onClose} />);
    fireEvent.click(screen.getByLabelText('Cerrar'));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  it('shows empty state when no blocks', async () => {
    render(<UnavailableDatesModal {...defaultProps} />);
    await waitFor(() => {
      expect(screen.getByText('No hay fechas bloqueadas.')).toBeInTheDocument();
    });
  });

  it('shows add block button', async () => {
    render(<UnavailableDatesModal {...defaultProps} />);
    await waitFor(() => {
      expect(screen.getByText('Agregar Bloqueo')).toBeInTheDocument();
    });
  });

  it('shows form when add block button clicked', async () => {
    render(<UnavailableDatesModal {...defaultProps} />);
    await waitFor(() => {
      expect(screen.getByText('Agregar Bloqueo')).toBeInTheDocument();
    });
    fireEvent.click(screen.getByText('Agregar Bloqueo'));
    expect(screen.getByText('Agregar Bloqueo')).toBeInTheDocument();
    expect(screen.getByText('Bloquear')).toBeInTheDocument();
  });

  it('renders existing blocks', async () => {
    mockGetDates.mockResolvedValue([
      { id: 'b1', start_date: '2025-06-15', end_date: '2025-06-15', reason: 'Vacaciones' },
    ]);
    render(<UnavailableDatesModal {...defaultProps} />);
    await waitFor(() => {
      expect(screen.getByText('Vacaciones')).toBeInTheDocument();
    });
  });
});
