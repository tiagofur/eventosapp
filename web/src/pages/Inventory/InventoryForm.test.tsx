import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { InventoryForm } from './InventoryForm';
import { logError } from '../../lib/errorHandler';
import { inventoryService } from '../../services/inventoryService';

const mockNavigate = vi.fn();
let mockParams: { id?: string } = {};

vi.mock('../../services/inventoryService', () => ({
  inventoryService: {
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
      <InventoryForm />
    </MemoryRouter>
  );

describe('InventoryForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockParams = {};
  });

  it('shows validation errors', async () => {
    renderForm();
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(screen.getByText(/El nombre debe tener al menos 2 caracteres/i)).toBeInTheDocument();
      expect(screen.getByText(/La unidad es requerida/i)).toBeInTheDocument();
    });
  });

  it('creates inventory item', async () => {
    (inventoryService.create as any).mockResolvedValue({});
    const { container } = renderForm();

    fireEvent.change(container.querySelector('input[name="ingredient_name"]')!, {
      target: { value: 'Harina' },
    });
    fireEvent.change(container.querySelector('input[name="unit"]')!, {
      target: { value: 'kg' },
    });
    fireEvent.change(container.querySelector('input[name="current_stock"]')!, {
      target: { value: '5' },
    });
    fireEvent.change(container.querySelector('input[name="minimum_stock"]')!, {
      target: { value: '2' },
    });
    fireEvent.change(container.querySelector('input[name="unit_cost"]')!, {
      target: { value: '10' },
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(inventoryService.create).toHaveBeenCalledWith({
        ingredient_name: 'Harina',
        type: 'ingredient',
        current_stock: 5,
        minimum_stock: 2,
        unit: 'kg',
        unit_cost: 10,
        user_id: 'user-1',
      });
    });
    expect(mockNavigate).toHaveBeenCalledWith('/inventory');
  });

  it('loads and updates inventory item', async () => {
    mockParams = { id: 'inv-1' };
    (inventoryService.getById as any).mockResolvedValue({
      id: 'inv-1',
      ingredient_name: 'Harina',
      type: 'ingredient',
      current_stock: 5,
      minimum_stock: 2,
      unit: 'kg',
      unit_cost: 10,
    });
    (inventoryService.update as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect((container.querySelector('input[name="ingredient_name"]') as HTMLInputElement).value).toBe('Harina');
    });

    fireEvent.change(container.querySelector('input[name="current_stock"]')!, {
      target: { value: '7' },
    });
    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(inventoryService.update).toHaveBeenCalledWith('inv-1', {
        ingredient_name: 'Harina',
        type: 'ingredient',
        current_stock: 7,
        minimum_stock: 2,
        unit: 'kg',
        unit_cost: 10,
      });
    });
  });

  it('updates inventory item with null cost', async () => {
    mockParams = { id: 'inv-1' };
    (inventoryService.getById as any).mockResolvedValue({
      id: 'inv-1',
      ingredient_name: 'Horno',
      type: 'equipment',
      current_stock: 1,
      minimum_stock: 0,
      unit: 'pieza',
      unit_cost: 0,
    });
    (inventoryService.update as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect((container.querySelector('input[name="ingredient_name"]') as HTMLInputElement).value).toBe('Horno');
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(inventoryService.update).toHaveBeenCalledWith('inv-1', {
        ingredient_name: 'Horno',
        type: 'equipment',
        current_stock: 1,
        minimum_stock: 0,
        unit: 'pieza',
        unit_cost: null,
      });
    });
  });

  it('shows error when load fails', async () => {
    mockParams = { id: 'inv-1' };
    (inventoryService.getById as any).mockResolvedValue(null);

    renderForm();

    await waitFor(() => {
      expect(screen.getByText(/Error al cargar el ingrediente/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error loading item', expect.any(Error));
  });

  it('shows error when save fails', async () => {
    (inventoryService.create as any).mockRejectedValueOnce(new Error('fail'));

    const { container } = renderForm();

    fireEvent.change(container.querySelector('input[name="ingredient_name"]')!, {
      target: { value: 'Harina' },
    });
    fireEvent.change(container.querySelector('input[name="unit"]')!, {
      target: { value: 'kg' },
    });

    fireEvent.click(screen.getByRole('button', { name: /guardar/i }));

    await waitFor(() => {
      expect(screen.getByText(/fail/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error saving item', expect.any(Error));
  });
});
