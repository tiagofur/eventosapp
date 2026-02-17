import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ProductForm } from './ProductForm';
import { productService } from '../../services/productService';
import { inventoryService } from '../../services/inventoryService';
import { logError } from '../../lib/errorHandler';

const mockNavigate = vi.fn();
let mockParams: { id?: string } = {};

vi.mock('../../services/productService', () => ({
  productService: {
    getById: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    getIngredients: vi.fn(),
    updateIngredients: vi.fn(),
  },
}));

vi.mock('../../services/inventoryService', () => ({
  inventoryService: {
    getAll: vi.fn(),
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
      <ProductForm />
    </MemoryRouter>
  );

describe('ProductForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockParams = {};
    (inventoryService.getAll as any).mockResolvedValue([
      { id: 'inv-1', ingredient_name: 'Harina', unit: 'kg', unit_cost: 2.5 },
    ]);
  });

  it('adds ingredient and calculates total', async () => {
    const { container } = renderForm();

    await waitFor(() => {
      expect(inventoryService.getAll).toHaveBeenCalled();
    });

    fireEvent.click(screen.getByRole('button', { name: /Agregar Ingrediente/i }));

    const select = container.querySelector('select') as HTMLSelectElement;
    fireEvent.change(select, { target: { value: 'inv-1' } });

    const quantityInput = container.querySelector('input[step="0.001"]') as HTMLInputElement;
    fireEvent.change(quantityInput, { target: { value: '3' } });

    await waitFor(() => {
      expect(screen.getAllByText('$7.50').length).toBeGreaterThan(0);
    });
  });

  it('creates product and saves ingredients', async () => {
    (productService.create as any).mockResolvedValue({ id: 'prod-1' });
    (productService.updateIngredients as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect(inventoryService.getAll).toHaveBeenCalled();
    });

    fireEvent.change(container.querySelector('input[name="name"]')!, {
      target: { value: 'Churros' },
    });
    fireEvent.change(container.querySelector('input[name="category"]')!, {
      target: { value: 'Postres' },
    });
    fireEvent.change(container.querySelector('input[name="base_price"]')!, {
      target: { value: '50' },
    });

    fireEvent.click(screen.getByRole('button', { name: /Agregar Ingrediente/i }));
    const select = container.querySelector('select') as HTMLSelectElement;
    fireEvent.change(select, { target: { value: 'inv-1' } });
    const quantityInput = container.querySelector('input[step="0.001"]') as HTMLInputElement;
    fireEvent.change(quantityInput, { target: { value: '2' } });

    fireEvent.click(screen.getByRole('button', { name: /Guardar Producto/i }));

    await waitFor(() => {
      expect(productService.create).toHaveBeenCalledWith({
        name: 'Churros',
        category: 'Postres',
        base_price: 50,
        user_id: 'user-1',
      });
      expect(productService.updateIngredients).toHaveBeenCalledWith('prod-1', [
        { inventoryId: 'inv-1', quantityRequired: 2 },
      ]);
    });
    expect(mockNavigate).toHaveBeenCalledWith('/products');
  });

  it('loads product and updates', async () => {
    mockParams = { id: 'prod-1' };
    (productService.getById as any).mockResolvedValue({
      id: 'prod-1',
      name: 'Churros',
      category: 'Postres',
      base_price: 50,
    });
    (productService.getIngredients as any).mockResolvedValue([
      {
        inventory_id: 'inv-1',
        quantity_required: 1,
        inventory: { unit_cost: 2.5, unit: 'kg' },
      },
    ]);
    (productService.update as any).mockResolvedValue({});
    (productService.updateIngredients as any).mockResolvedValue({});

    const { container } = renderForm();

    await waitFor(() => {
      expect((container.querySelector('input[name="name"]') as HTMLInputElement).value).toBe('Churros');
    });

    fireEvent.change(container.querySelector('input[name="base_price"]')!, {
      target: { value: '60' },
    });
    fireEvent.click(screen.getByRole('button', { name: /Guardar Producto/i }));

    await waitFor(() => {
      expect(productService.update).toHaveBeenCalledWith('prod-1', {
        name: 'Churros',
        category: 'Postres',
        base_price: 60,
      });
    });
  });

  it('handles missing product on load', async () => {
    mockParams = { id: 'prod-1' };
    (productService.getById as any).mockResolvedValueOnce(null);

    renderForm();

    await waitFor(() => {
      expect(screen.getByText(/Error al cargar el producto/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error loading product', expect.any(Error));
  });

  it('shows error when saving fails', async () => {
    (productService.create as any).mockRejectedValueOnce(new Error('fail'));

    const { container } = renderForm();

    fireEvent.change(container.querySelector('input[name="name"]')!, {
      target: { value: 'Churros' },
    });
    fireEvent.change(container.querySelector('input[name="category"]')!, {
      target: { value: 'Postres' },
    });
    fireEvent.change(container.querySelector('input[name="base_price"]')!, {
      target: { value: '50' },
    });

    fireEvent.click(screen.getByRole('button', { name: /Guardar Producto/i }));

    await waitFor(() => {
      expect(screen.getByText(/fail/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalledWith('Error saving product', expect.any(Error));
  });

  it('logs error when inventory dependencies fail', async () => {
    (inventoryService.getAll as any).mockRejectedValueOnce(new Error('fail'));

    renderForm();

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error loading inventory', expect.any(Error));
    });
  });
});
