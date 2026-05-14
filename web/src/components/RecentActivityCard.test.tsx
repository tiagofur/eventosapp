import { beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen } from '@tests/customRender';
import { RecentActivityCard } from './RecentActivityCard';

const mockUseDashboardActivity = vi.fn();
const currentLanguage = { value: 'es-AR' };

vi.mock('@/hooks/queries/useActivityQueries', () => ({
  useDashboardActivity: (...args: unknown[]) => mockUseDashboardActivity(...args),
}));

vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    i18n: { language: currentLanguage.value },
    t: (key: string, options?: { defaultValue?: string }) => {
      const translations: Record<string, string> = {
        'activity.recent': 'Actividad reciente',
        'activity.event_list_label': 'Lista de actividad',
        'action.loading_activity': 'Cargando actividad',
        'action.activity_error': 'No pudimos cargar actividad',
        'action.no_activity': 'Sin actividad',
        'activity.actions.created': 'Creado',
        'activity.actions.updated': 'Actualizado',
        'activity.actions.login': 'Ingreso',
        'activity.resources.client': 'Cliente',
        'activity.resources.inventory': 'Inventario',
      };
      if (translations[key]) return translations[key];
      return options?.defaultValue ?? key;
    },
  }),
}));

describe('RecentActivityCard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    currentLanguage.value = 'es-AR';
    mockUseDashboardActivity.mockReturnValue({
      data: [],
      isLoading: false,
      isError: false,
    });
  });

  it('renders loading state', () => {
    mockUseDashboardActivity.mockReturnValue({
      data: undefined,
      isLoading: true,
      isError: false,
    });

    render(<RecentActivityCard limit={4} />);

    expect(mockUseDashboardActivity).toHaveBeenCalledWith(4);
    expect(screen.getByRole('status')).toBeInTheDocument();
    expect(screen.getByText('Cargando actividad')).toBeInTheDocument();
  });

  it('renders error state', () => {
    mockUseDashboardActivity.mockReturnValue({
      data: undefined,
      isLoading: false,
      isError: true,
    });

    render(<RecentActivityCard />);

    expect(screen.getByText('No pudimos cargar actividad')).toBeInTheDocument();
  });

  it('renders empty state', () => {
    render(<RecentActivityCard />);

    expect(screen.getByText('Sin actividad')).toBeInTheDocument();
  });

  it('renders activity entries and normalizes action/resource labels', () => {
    mockUseDashboardActivity.mockReturnValue({
      data: [
        {
          id: '1',
          action: 'CREATED',
          resource_type: 'clients',
          details: 'Registro actualizado',
          created_at: '2026-05-13T12:00:00.000Z',
        },
        {
          id: '2',
          action: 'UPDATED',
          resource_type: 'inventory_item',
          details: null,
          created_at: 'invalid-date',
        },
        {
          id: '3',
          action: 'LOGIN',
          resource_type: '',
          details: null,
          created_at: '2026-05-13T12:00:00.000Z',
        },
      ],
      isLoading: false,
      isError: false,
    });

    render(<RecentActivityCard />);

    expect(screen.getByLabelText('Lista de actividad')).toBeInTheDocument();
    expect(screen.getByText('Creado Cliente')).toBeInTheDocument();
    expect(screen.getByText('· Registro actualizado')).toBeInTheDocument();
    expect(screen.getByText('Actualizado Inventario')).toBeInTheDocument();
    expect(screen.getByText('Ingreso')).toBeInTheDocument();
  });

  it('switches locale branch for non-spanish language without crashing', () => {
    currentLanguage.value = 'en-US';
    mockUseDashboardActivity.mockReturnValue({
      data: [
        {
          id: '4',
          action: 'CREATED',
          resource_type: 'client',
          details: null,
          created_at: '2026-05-13T12:00:00.000Z',
        },
      ],
      isLoading: false,
      isError: false,
    });

    render(<RecentActivityCard />);

    expect(screen.getByText('Creado Cliente')).toBeInTheDocument();
  });
});
