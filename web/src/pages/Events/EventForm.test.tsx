import React, { useEffect } from 'react';
import { act } from '@testing-library/react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { EventForm } from './EventForm';
import { eventService } from '../../services/eventService';
import { clientService } from '../../services/clientService';
import { productService } from '../../services/productService';
import { logError } from '../../lib/errorHandler';

let triggerFetchCosts = () => {};

const mockNavigate = vi.fn();
let mockParams: { id?: string } = {};
const mockTrigger = vi.fn().mockResolvedValue(true);
let setValueMock = vi.fn();
let productsBehavior: 'passive' | 'invoke' = 'passive';
let extrasBehavior: 'passive' | 'invoke' = 'passive';
let mockSearchParams = new URLSearchParams();
let productsInvoked = false;
let watchValues: Record<string, any> = {
  discount: 0,
  client_id: '',
  location: '',
  city: '',
  requires_invoice: false,
  tax_rate: 16,
};

const mockFormData = {
  client_id: 'client-1',
  event_date: '2024-01-02',
  start_time: '',
  end_time: '',
  service_type: 'Boda',
  num_people: 100,
  status: 'quoted',
  discount: 0,
  requires_invoice: false,
  tax_rate: 16,
  tax_amount: 0,
  total_amount: 100,
  location: '',
  city: '',
  deposit_percent: 50,
  cancellation_days: 15,
  refund_percent: 0,
  notes: '',
};

const resetMock = vi.fn();
const watchMock = vi.fn();

const controlMock = {};
const handleSubmitMock = (fn: any) => () => fn(mockFormData);
const setValueMockFn = (name: string, value: any) => {
  setValueMock(name, value);
  watchValues[name] = value;
};

vi.mock('react-hook-form', async () => {
  const actual = await vi.importActual<any>('react-hook-form');
  return {
    ...actual,
    useForm: () => ({
      handleSubmit: handleSubmitMock,
      reset: resetMock,
      setValue: setValueMockFn,
      control: controlMock,
      watch: watchMock,
      trigger: mockTrigger,
      formState: { errors: {}, isValid: true, isSubmitted: false },
    }),
    useWatch: ({ name }: any) => watchValues[name] ?? 0,
  };
});

const mockUser = { id: 'user-1' };
const mockProfile = { default_deposit_percent: 50, default_cancellation_days: 15, default_refund_percent: 0 };

vi.mock('../../contexts/AuthContext', () => ({
  useAuth: () => ({
    user: mockUser,
    profile: mockProfile,
  }),
}));

vi.mock('./components/EventGeneralInfo', () => ({
  EventGeneralInfo: () => <div>EVENT_GENERAL</div>,
}));

vi.mock('./components/EventProducts', () => ({
  EventProducts: (props: any) => {
    triggerFetchCosts = () => {
      if (props.selectedProducts.length === 0) {
        props.onAddProduct();
        return;
      }
      props.onProductChange(0, 'product_id', 'p1');
      props.onProductChange(0, 'quantity', 2);
      props.onProductChange(0, 'discount', 5);
    };
    useEffect(() => {
      if (productsBehavior !== 'invoke') return;
      if (productsInvoked) return;
      if (props.selectedProducts.length === 0) {
        props.onAddProduct();
        return;
      }
      props.onProductChange(0, 'product_id', 'p1');
      props.onProductChange(0, 'quantity', 2);
      props.onProductChange(0, 'discount', 5);
      productsInvoked = true;
    }, [props.selectedProducts.length]);

    return <div>EVENT_PRODUCTS</div>;
  },
}));

vi.mock('./components/EventExtras', () => ({
  EventExtras: (props: any) => {
    useEffect(() => {
      if (extrasBehavior !== 'invoke') return;
      if (props.extras?.length === 0) {
        props.onAddExtra();
        return;
      }
      props.onExtraChange(0, 'description', 'Transporte');
      props.onExtraChange(0, 'exclude_utility', true);
      props.onExtraChange(0, 'cost', 50);
    }, [props.extras?.length]);

    return <div>EVENT_EXTRAS</div>;
  },
}));

vi.mock('./components/EventFinancials', () => ({
  EventFinancials: () => <div>EVENT_FINANCIALS</div>,
}));

vi.mock('../../services/eventService', () => ({
  eventService: {
    getById: vi.fn(),
    getProducts: vi.fn(),
    getExtras: vi.fn(),
    create: vi.fn(),
    update: vi.fn(),
    updateItems: vi.fn(),
  },
}));

vi.mock('../../services/clientService', () => ({
  clientService: { getAll: vi.fn() },
}));

vi.mock('../../services/productService', () => ({
  productService: { getAll: vi.fn(), getIngredients: vi.fn() },
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
    useSearchParams: () => [mockSearchParams],
  };
});

describe('EventForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockParams = {};
    productsBehavior = 'passive';
    extrasBehavior = 'passive';
    watchValues = {
      discount: 0,
      client_id: '',
      location: '',
      city: '',
      requires_invoice: false,
      tax_rate: 16,
    };
    mockSearchParams = new URLSearchParams();
    productsInvoked = false;
    triggerFetchCosts = () => {};
    setValueMock = vi.fn();
    (clientService.getAll as any).mockResolvedValue([]);
    (productService.getAll as any).mockResolvedValue([]);
  });

  it('advances steps and creates event', async () => {
    (eventService.create as any).mockResolvedValue({ id: 'event-1' });
    (eventService.updateItems as any).mockResolvedValue({});

    render(<EventForm />);

    expect(screen.getByText('Nuevo Evento')).toBeInTheDocument();
    expect(screen.getByText('EVENT_GENERAL')).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_PRODUCTS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_EXTRAS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_FINANCIALS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Guardar Evento/i }));

    await waitFor(() => {
      expect(eventService.create).toHaveBeenCalledWith({
        ...mockFormData,
        start_time: null,
        end_time: null,
        user_id: 'user-1',
      });
      expect(eventService.updateItems).toHaveBeenCalledWith('event-1', [], []);
    });
  });

  it('shows edit mode and summary button', async () => {
    mockParams = { id: 'event-1' };
    (eventService.getById as any).mockResolvedValue({ id: 'event-1' });
    (eventService.getProducts as any).mockResolvedValue([]);
    (eventService.getExtras as any).mockResolvedValue([]);

    render(<EventForm />);

    await waitFor(() => {
      expect(screen.getByText('Editar Evento')).toBeInTheDocument();
    });
    expect(screen.getByRole('button', { name: /Ver Resumen/i })).toBeInTheDocument();
  });

  it('does not advance when validation fails', async () => {
    mockTrigger.mockResolvedValueOnce(false);

    render(<EventForm />);

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));

    await waitFor(() => {
      expect(screen.getByText('EVENT_GENERAL')).toBeInTheDocument();
    });
    expect(screen.queryByText('EVENT_PRODUCTS')).not.toBeInTheDocument();
  });

  it('does not create event when submitting before final step', async () => {
    (eventService.create as any).mockResolvedValue({ id: 'event-1' });

    const { container } = render(<EventForm />);

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_PRODUCTS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_EXTRAS')).toBeInTheDocument();
    });

    fireEvent.submit(container.querySelector('form')!);

    await waitFor(() => {
      expect(screen.getByText('EVENT_FINANCIALS')).toBeInTheDocument();
    });
    expect(eventService.create).not.toHaveBeenCalled();
  });

  it('creates event and handles create failure', async () => {
    (eventService.create as any).mockResolvedValueOnce(null);
    (productService.getIngredients as any).mockResolvedValueOnce([
      { quantity_required: 2, inventory: { unit_cost: 10 } },
    ]);

    render(<EventForm />);

    (productService.getAll as any).mockResolvedValueOnce([
      { id: 'p1', base_price: 100 } as any,
    ]);

    await waitFor(() => {
      expect(productService.getAll).toHaveBeenCalled();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_PRODUCTS')).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_EXTRAS')).toBeInTheDocument();
    });
    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_FINANCIALS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Guardar Evento/i }));

    await waitFor(() => {
      expect(screen.getByText(/Error al crear el evento/i)).toBeInTheDocument();
    });
  });

  it('loads event and handles missing event', async () => {
    mockParams = { id: 'event-1' };
    (eventService.getById as any).mockResolvedValue(null);

    render(<EventForm />);

    await waitFor(() => {
      expect(screen.getByText(/Error al cargar el evento/i)).toBeInTheDocument();
    });
  });

  it('auto-fills location and city from client', async () => {
    watchValues.client_id = 'client-1';
    (clientService.getAll as any).mockResolvedValue([
      { id: 'client-1', address: 'Calle 1', city: 'CDMX' },
    ]);

    render(<EventForm />);

    await waitFor(() => {
      expect(setValueMock).toHaveBeenCalledWith('location', 'Calle 1');
      expect(setValueMock).toHaveBeenCalledWith('city', 'CDMX');
    });
  });

  it('sets client from query string', async () => {
    watchValues.client_id = '';
    (clientService.getAll as any).mockResolvedValue([
      { id: 'client-1', address: 'Calle 1', city: 'CDMX' },
    ]);
    mockSearchParams = new URLSearchParams('clientId=client-1');

    render(<EventForm />);

    await waitFor(() => {
      expect(setValueMock).toHaveBeenCalledWith('client_id', 'client-1');
    });
  });

  it('loads event data and formats defaults', async () => {
    mockParams = { id: 'event-1' };
    (eventService.getById as any).mockResolvedValue({
      id: 'event-1',
      client_id: 'client-1',
      event_date: '2024-01-02',
      service_type: 'Boda',
      num_people: 150,
      status: 'confirmed',
      discount: 5,
      requires_invoice: true,
      tax_rate: 16,
      tax_amount: 10,
      total_amount: 200,
      location: 'Salon',
      city: 'CDMX',
      deposit_percent: 40,
      cancellation_days: 20,
      refund_percent: 10,
      notes: 'Notas',
    });
    (productService.getIngredients as any).mockResolvedValue([]);
    (eventService.getProducts as any).mockResolvedValue([
      { product_id: 'p1', quantity: 1, unit_price: 100 },
    ]);
    (eventService.getExtras as any).mockResolvedValue([
      { description: 'Extra', cost: 10, price: 20, exclude_utility: true },
    ]);

    render(<EventForm />);

    await waitFor(() => {
      expect(eventService.getById).toHaveBeenCalledWith('event-1');
    });
  });

  it('logs dependency load failures', async () => {
    (clientService.getAll as any).mockRejectedValueOnce(new Error('fail'));

    render(<EventForm />);

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error loading dependencies', expect.any(Error));
    });
  });

  it('logs failures when fetching product costs', async () => {
    productsBehavior = 'passive';
    (clientService.getAll as any).mockResolvedValue([]);
    (productService.getAll as any).mockResolvedValue([{ id: 'p1', base_price: 100 }]);
    const error = new Error('fail');
    (productService.getIngredients as any).mockRejectedValue(error);

    render(<EventForm />);

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));

    await waitFor(() => {
      expect(screen.getByText('EVENT_PRODUCTS')).toBeInTheDocument();
    });

    await act(async () => {
      triggerFetchCosts();
    });

    await waitFor(() => {
      expect(productService.getIngredients).toHaveBeenCalledWith('p1');
    });

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error fetching ingredients for products', error);
    });
  });

  it('saves items with updated products and extras', async () => {
    productsBehavior = 'invoke';
    extrasBehavior = 'invoke';
    (eventService.create as any).mockResolvedValue({ id: 'event-1' });
    (eventService.updateItems as any).mockResolvedValue({});
    (productService.getAll as any).mockResolvedValue([{ id: 'p1', base_price: 100 }]);
    (productService.getIngredients as any).mockResolvedValue([
      { quantity_required: 2, inventory: { unit_cost: 10 } },
    ]);

    render(<EventForm />);

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_PRODUCTS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_EXTRAS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Siguiente/i }));
    await waitFor(() => {
      expect(screen.getByText('EVENT_FINANCIALS')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByRole('button', { name: /Guardar Evento/i }));

    await waitFor(() => {
      expect(eventService.updateItems).toHaveBeenCalledWith(
        'event-1',
        [
          expect.objectContaining({
            discount: 5,
          }),
        ],
        [
          expect.objectContaining({
            cost: 50,
          }),
        ]
      );
    });
  });
});
