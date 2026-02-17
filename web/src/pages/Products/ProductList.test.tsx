import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ProductList } from './ProductList';
import { productService } from '../../services/productService';

vi.mock('../../services/productService', () => ({
  productService: {
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
      <ProductList />
    </MemoryRouter>
  );

describe('ProductList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders products after loading', async () => {
    (productService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Churros',
        category: 'Postres',
        base_price: 50,
      },
    ]);

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Churros')).toBeInTheDocument();
    });
    expect(screen.getByText('Postres')).toBeInTheDocument();
  });

  it('filters products by search term', async () => {
    (productService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Churros',
        category: 'Postres',
        base_price: 50,
      },
      {
        id: '2',
        name: 'Tacos',
        category: 'Comida',
        base_price: 80,
      },
    ]);

    renderList();
    await waitFor(() => {
      expect(screen.getByText('Tacos')).toBeInTheDocument();
    });

    fireEvent.change(screen.getByPlaceholderText('Buscar producto...'), {
      target: { value: 'Postres' },
    });

    expect(screen.getByText('Churros')).toBeInTheDocument();
    expect(screen.queryByText('Tacos')).not.toBeInTheDocument();
  });

  it('deletes a product after confirmation', async () => {
    (productService.getAll as any).mockResolvedValue([
      {
        id: '1',
        name: 'Churros',
        category: 'Postres',
        base_price: 50,
      },
    ]);
    (productService.delete as any).mockResolvedValue({});

    renderList();

    await waitFor(() => {
      expect(screen.getByText('Churros')).toBeInTheDocument();
    });

    fireEvent.click(screen.getAllByRole('button')[0]);
    const dialog = screen.getByRole('dialog', { name: 'Eliminar producto' });
    fireEvent.click(within(dialog).getByRole('button', { name: 'Eliminar' }));

    await waitFor(() => {
      expect(productService.delete).toHaveBeenCalledWith('1');
      expect(screen.queryByText('Churros')).not.toBeInTheDocument();
    });
  });
});
