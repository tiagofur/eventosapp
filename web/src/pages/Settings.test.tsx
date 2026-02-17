import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { Settings } from './Settings';
import { logError } from '../lib/errorHandler';

const mockUpdateProfile = vi.fn();
let mockUser = {
  id: '1',
  name: 'Ana Perez',
  email: 'ana@example.com',
  plan: 'basic',
  business_name: 'Eventos Ana',
  default_deposit_percent: 40,
  default_cancellation_days: 10,
  default_refund_percent: 5,
};

vi.mock('../contexts/AuthContext', () => ({
  useAuth: () => ({ user: mockUser, updateProfile: mockUpdateProfile }),
}));

vi.mock('../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

describe('Settings', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUser = {
      id: '1',
      name: 'Ana Perez',
      email: 'ana@example.com',
      plan: 'basic',
      business_name: 'Eventos Ana',
      default_deposit_percent: 40,
      default_cancellation_days: 10,
      default_refund_percent: 5,
    };
  });

  it('renders profile details', () => {
    render(<Settings />);
    expect(screen.getByText('Configuración')).toBeInTheDocument();
    expect(screen.getByText('Ana Perez')).toBeInTheDocument();
    expect(screen.getByText('ana@example.com')).toBeInTheDocument();
    expect(screen.getByText('Básico')).toBeInTheDocument();
  });

  it('shows fallback business name when missing', () => {
    mockUser = {
      ...mockUser,
      business_name: '',
    };

    render(<Settings />);
    expect(screen.getByText(/No configurado/i)).toBeInTheDocument();
  });

  it('renders premium plan label without basic hint', () => {
    mockUser = {
      ...mockUser,
      plan: 'premium',
    };

    render(<Settings />);
    expect(screen.getByText('Premium')).toBeInTheDocument();
    expect(screen.queryByText(/plan básico/i)).not.toBeInTheDocument();
  });

  it('resets business name when profile updates', async () => {
    const { rerender } = render(<Settings />);

    mockUser = {
      ...mockUser,
      business_name: 'Eventos Actualizados',
    };

    rerender(<Settings />);

    await waitFor(() => {
      expect(screen.getByText('Eventos Actualizados')).toBeInTheDocument();
    });
  });

  it('updates business name', async () => {
    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[0]);

    const input = screen.getByPlaceholderText(/Eventos Fantásticos/i);
    fireEvent.change(input, { target: { value: 'Eventos Nuevo' } });
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(mockUpdateProfile).toHaveBeenCalledWith({ business_name: 'Eventos Nuevo' });
    });
  });

  it('cancels business name edit', () => {
    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[0]);

    fireEvent.change(screen.getByPlaceholderText(/Eventos Fantásticos/i), {
      target: { value: 'Cambio' },
    });
    fireEvent.click(screen.getByRole('button', { name: /cancelar/i }));

    expect(screen.queryByPlaceholderText(/Eventos Fantásticos/i)).not.toBeInTheDocument();
  });

  it('logs error when updating business name fails', async () => {
    mockUpdateProfile.mockRejectedValueOnce(new Error('fail'));

    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[0]);
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error updating business name', expect.any(Error));
    });
  });

  it('updates contract settings', async () => {
    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[1]);

    fireEvent.change(screen.getByDisplayValue('40'), { target: { value: '55' } });
    fireEvent.change(screen.getByDisplayValue('10'), {
      target: { value: '20' },
    });
    fireEvent.change(screen.getByDisplayValue('5'), {
      target: { value: '15' },
    });
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(mockUpdateProfile).toHaveBeenCalledWith({
        default_deposit_percent: 55,
        default_cancellation_days: 20,
        default_refund_percent: 15,
      });
    });
  });

  it('cancels contract settings edit', () => {
    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[1]);

    fireEvent.change(screen.getByDisplayValue('40'), { target: { value: '99' } });
    fireEvent.click(screen.getByRole('button', { name: /cancelar/i }));

    expect(screen.getByText(/40%/i)).toBeInTheDocument();
  });

  it('logs error when updating contract settings fails', async () => {
    mockUpdateProfile.mockRejectedValueOnce(new Error('fail'));

    render(<Settings />);
    const editButtons = screen.getAllByRole('button', { name: /editar/i });
    fireEvent.click(editButtons[1]);
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error updating contract settings', expect.any(Error));
    });
  });
});
