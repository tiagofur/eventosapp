import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { SearchPage } from './Search';
import { searchService } from '../services/searchService';
import { logError } from '../lib/errorHandler';

let mockSearchParams = new URLSearchParams();

vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual<any>('react-router-dom');
  return {
    ...actual,
    useSearchParams: () => [mockSearchParams],
  };
});

vi.mock('../services/searchService', () => ({
  searchService: {
    searchAll: vi.fn(),
  },
}));

vi.mock('../lib/errorHandler', () => ({
  logError: vi.fn(),
}));

describe('SearchPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockSearchParams = new URLSearchParams();
  });

  it('renders empty state when no query provided', () => {
    render(
      <MemoryRouter>
        <SearchPage />
      </MemoryRouter>
    );
    expect(screen.getByText(/Busca en toda tu operacion/i)).toBeInTheDocument();
  });

  it('renders results when search returns data', async () => {
    mockSearchParams = new URLSearchParams('?q=evento');
    (searchService.searchAll as any).mockResolvedValue({
      clients: [{ id: '1', title: 'Ana', href: '/clients/1' }],
      events: [{ id: '2', title: 'Boda', href: '/events/2', meta: '2024-01-02', status: 'confirmed' }],
      products: [{ id: '3', title: 'Menu', href: '/products/3', meta: '10 items' }],
      inventory: [{ id: '4', title: 'Sillas', href: '/inventory/4' }],
    });

    render(
      <MemoryRouter>
        <SearchPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText('Resultados')).toBeInTheDocument();
    });
    expect(screen.getByText('Clientes')).toBeInTheDocument();
    expect(screen.getByText('Ana')).toBeInTheDocument();
    expect(screen.getByText('Eventos')).toBeInTheDocument();
    expect(screen.getByText('Boda')).toBeInTheDocument();
    expect(screen.getByText('Productos')).toBeInTheDocument();
    expect(screen.getByText('Menu')).toBeInTheDocument();
    expect(screen.getByText('Inventario')).toBeInTheDocument();
    expect(screen.getByText('Sillas')).toBeInTheDocument();
  });

  it('renders error state when search fails', async () => {
    mockSearchParams = new URLSearchParams('?q=evento');
    (searchService.searchAll as any).mockRejectedValue(new Error('fail'));

    render(
      <MemoryRouter>
        <SearchPage />
      </MemoryRouter>
    );

    await waitFor(() => {
      expect(screen.getByText(/No pudimos completar la busqueda/i)).toBeInTheDocument();
    });
    expect(logError).toHaveBeenCalled();
  });
});
