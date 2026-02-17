import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { InventoryList } from './InventoryList';
import { inventoryService } from '../../services/inventoryService';
import { logError } from '../../lib/errorHandler';

vi.mock('../../services/inventoryService', () => ({
  inventoryService: {
    getAll: vi.fn(),
    delete: vi.fn(),
  },
}));

vi.mock('../../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

const renderList = () =>
  render(
    <MemoryRouter>
      <InventoryList />
    </MemoryRouter>
  );

describe('InventoryList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders items and low stock warning', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Harina',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 2,
        minimum_stock: 5,
        unit_cost: 10,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Harina')).toBeInTheDocument();
    });
    expect(screen.getByText(/Stock bajo/i)).toBeInTheDocument();
  });

  it('filters items by search term', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Harina',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 10,
        minimum_stock: 1,
        unit_cost: 10,
      },
      {
        id: '2',
        ingredient_name: 'Azucar',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 10,
        minimum_stock: 1,
        unit_cost: 10,
      },
    ]);

    renderList();
    await waitFor(() => {
      expect(screen.getByText('Azucar')).toBeInTheDocument();
    });

    fireEvent.change(screen.getByPlaceholderText('Buscar ingrediente...'), {
      target: { value: 'Harina' },
    });

    expect(screen.getByText('Harina')).toBeInTheDocument();
    expect(screen.queryByText('Azucar')).not.toBeInTheDocument();
  });

  it('deletes an item after confirmation', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Harina',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 10,
        minimum_stock: 1,
        unit_cost: 10,
      },
    ]);
    (inventoryService.delete as any).mockResolvedValue({});

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Harina')).toBeInTheDocument();
    });

    fireEvent.click(screen.getAllByRole('button')[0]);
    const dialog = screen.getByRole('dialog', { name: 'Eliminar ingrediente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(inventoryService.delete).toHaveBeenCalledWith('1');
      expect(screen.queryByText('Harina')).not.toBeInTheDocument();
    });
  });

  it('logs fetch errors and shows empty state', async () => {
    (inventoryService.getAll as any).mockRejectedValueOnce(new Error('fail'));

    renderList();

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error fetching inventory', expect.any(Error));
    });
    expect(screen.getByText(/No se encontraron ingredientes/i)).toBeInTheDocument();
  });

  it('shows equipment badge and delete error handling', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Horno',
        unit: 'pieza',
        type: 'equipment',
        current_stock: 1,
        minimum_stock: 1,
        unit_cost: null,
      },
    ]);
    (inventoryService.delete as any).mockRejectedValueOnce(new Error('fail'));

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Horno')).toBeInTheDocument();
    });

    expect(screen.getByText('Equipo')).toBeInTheDocument();
    expect(screen.getByText('$0.00')).toBeInTheDocument();

    fireEvent.click(screen.getAllByRole('button')[0]);
    const dialog = screen.getByRole('dialog', { name: 'Eliminar ingrediente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error deleting item', expect.any(Error));
    });
    expect(screen.getByText('Horno')).toBeInTheDocument();
  });

  it('closes confirm dialog on cancel', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Harina',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 10,
        minimum_stock: 1,
        unit_cost: 10,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Harina')).toBeInTheDocument();
    });

    fireEvent.click(screen.getAllByRole('button')[0]);
    const dialog = screen.getByRole('dialog', { name: 'Eliminar ingrediente' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Cancelar' }));

    expect(screen.queryByRole('dialog', { name: 'Eliminar ingrediente' })).not.toBeInTheDocument();
  });

  it('renders ingredient badge and unit label', async () => {
    (inventoryService.getAll as any).mockResolvedValue([
      {
        id: '1',
        ingredient_name: 'Harina',
        unit: 'kg',
        type: 'ingredient',
        current_stock: 10,
        minimum_stock: 1,
        unit_cost: 10,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Harina')).toBeInTheDocument();
    });

    expect(screen.getByText('Ingrediente')).toBeInTheDocument();
    expect(screen.getByText(/Unidad: kg/i)).toBeInTheDocument();
  });
});
