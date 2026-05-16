import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@tests/customRender';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { StaffDetails } from './StaffDetails';
import { staffService } from '@/services/staffService';
import { logError } from '@/lib/errorHandler';

const mockUseStaffMember = vi.fn();
const mockUseDeleteStaff = vi.fn();
const mockUseStaffAvailabilityRange = vi.fn();
const mockAddToast = vi.fn();
const mockMutateAsync = vi.fn();

vi.mock('@/hooks/queries/useStaffQueries', () => ({
  useStaffMember: (...args: unknown[]) => mockUseStaffMember(...args),
  useDeleteStaff: (...args: unknown[]) => mockUseDeleteStaff(...args),
  useStaffAvailabilityRange: (...args: unknown[]) => mockUseStaffAvailabilityRange(...args),
}));

vi.mock('@/services/staffService', () => ({
  staffService: {
    inviteUser: vi.fn(),
  },
}));

vi.mock('@/hooks/useToast', () => ({
  useToast: () => ({ addToast: mockAddToast }),
}));

vi.mock('@/lib/errorHandler', () => ({
  logError: vi.fn(),
  getErrorMessage: (_error: unknown, fallback: string) => fallback,
}));

vi.mock('react-i18next', () => ({
  useTranslation: () => ({ t: (key: string, options?: { defaultValue?: string }) => options?.defaultValue ?? key, i18n: { language: 'es' } }),
}));

function renderPage(path = '/staff/staff-1') {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route path="/staff/:id" element={<StaffDetails />} />
        <Route path="/staff" element={<div>staff-list</div>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('StaffDetails invite access', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUseDeleteStaff.mockReturnValue({ mutateAsync: mockMutateAsync });
    mockUseStaffAvailabilityRange.mockReturnValue({ data: [] });
    vi.stubGlobal('navigator', {
      clipboard: {
        writeText: vi.fn().mockResolvedValue(undefined),
      },
    });
  });

  it('renders loading state', () => {
    mockUseStaffMember.mockReturnValue({ isLoading: true, data: null });

    renderPage();

    expect(screen.getByText('staff:details.loading')).toBeInTheDocument();
  });

  it('renders not-found state with return link', () => {
    mockUseStaffMember.mockReturnValue({ isLoading: false, data: null });

    renderPage();

    expect(screen.getByText((content) => content.includes('staff:details.not_found'))).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'staff:details.return_list' })).toHaveAttribute('href', '/staff');
  });

  it('shows invite button and reveals invite URL after success', async () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });

    (staffService.inviteUser as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({
      invite_id: 'inv-1',
      staff_id: 'staff-1',
      email: 'staff@example.com',
      status: 'pending',
      accept_url: 'https://app.solennix.com/team-invite?token=abc123',
      expires_at: '2026-05-20T00:00:00Z',
      created_at: '2026-05-10T00:00:00Z',
    });

    renderPage();

    fireEvent.click(screen.getByRole('button', { name: /invitar acceso/i }));

    await waitFor(() => {
      expect(staffService.inviteUser).toHaveBeenCalledWith('staff-1');
    });

    expect(screen.getByText('https://app.solennix.com/team-invite?token=abc123')).toBeInTheDocument();
    expect(mockAddToast).toHaveBeenCalled();
  });

  it('hides invite button when staff is already linked to invited user', () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: 'user-2',
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });

    renderPage();

    expect(screen.queryByRole('button', { name: /invitar acceso/i })).not.toBeInTheDocument();
  });

  it('shows error toast when invite request fails', async () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });

    (staffService.inviteUser as unknown as ReturnType<typeof vi.fn>).mockRejectedValue(new Error('boom'));

    renderPage();

    fireEvent.click(screen.getByRole('button', { name: /invitar acceso/i }));

    await waitFor(() => {
      expect(logError).toHaveBeenCalledWith('Error creating staff invite', expect.any(Error));
    });
    expect(mockAddToast).toHaveBeenCalledWith('No se pudo crear la invitación.', 'error');
  });

  it('copies invite link to clipboard and shows success toast', async () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });
    (staffService.inviteUser as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({
      invite_id: 'inv-1',
      staff_id: 'staff-1',
      email: 'staff@example.com',
      status: 'pending',
      accept_url: 'https://app.solennix.com/team-invite?token=copy-me',
      expires_at: '2026-05-20T00:00:00Z',
      created_at: '2026-05-10T00:00:00Z',
    });

    renderPage();

    fireEvent.click(screen.getByRole('button', { name: /invitar acceso/i }));
    await screen.findByText('https://app.solennix.com/team-invite?token=copy-me');

    fireEvent.click(screen.getByRole('button', { name: /copiar/i }));

    await waitFor(() => {
      expect(navigator.clipboard.writeText).toHaveBeenCalledWith('https://app.solennix.com/team-invite?token=copy-me');
    });
    expect(mockAddToast).toHaveBeenCalledWith('Link copiado al portapapeles.', 'success');
  });

  it('falls back to info toast when copying invite link fails', async () => {
    vi.stubGlobal('navigator', {
      clipboard: {
        writeText: vi.fn().mockRejectedValue(new Error('no clipboard')),
      },
    });

    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });
    (staffService.inviteUser as unknown as ReturnType<typeof vi.fn>).mockResolvedValue({
      invite_id: 'inv-1',
      staff_id: 'staff-1',
      email: 'staff@example.com',
      status: 'pending',
      accept_url: 'https://app.solennix.com/team-invite?token=show-me',
      expires_at: '2026-05-20T00:00:00Z',
      created_at: '2026-05-10T00:00:00Z',
    });

    renderPage();

    fireEvent.click(screen.getByRole('button', { name: /invitar acceso/i }));
    await screen.findByText('https://app.solennix.com/team-invite?token=show-me');

    fireEvent.click(screen.getByRole('button', { name: /copiar/i }));

    await waitFor(() => {
      expect(mockAddToast).toHaveBeenCalledWith('https://app.solennix.com/team-invite?token=show-me', 'info');
    });
  });

  it('deletes staff after confirmation and navigates to list', async () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });

    renderPage();

    fireEvent.click(screen.getByRole('button', { name: 'staff:details.actions.delete' }));
    fireEvent.click(screen.getByRole('button', { name: 'staff:details.delete_confirm.confirm' }));

    await waitFor(() => {
      expect(mockMutateAsync).toHaveBeenCalledWith('staff-1');
    });
    await waitFor(() => {
      expect(screen.getByText('staff-list')).toBeInTheDocument();
    });
  });

  it('renders and sorts upcoming assignments with shift labels', () => {
    mockUseStaffMember.mockReturnValue({
      isLoading: false,
      data: {
        id: 'staff-1',
        user_id: 'owner-1',
        name: 'Carlos',
        role_label: 'Fotografo',
        phone: null,
        email: 'staff@example.com',
        notes: null,
        notification_email_opt_in: false,
        invited_user_id: null,
        created_at: '2026-01-01T00:00:00Z',
        updated_at: '2026-01-01T00:00:00Z',
      },
    });
    mockUseStaffAvailabilityRange.mockReturnValue({
      data: [
        {
          staff_id: 'staff-1',
          staff_name: 'Carlos',
          assignments: [
            {
              event_id: 'ev-2',
              event_name: 'Evento B',
              event_date: '2026-06-15',
              shift_start: '2026-06-15T14:00:00.000Z',
              shift_end: null,
              status: 'pending',
            },
            {
              event_id: 'ev-1',
              event_name: 'Evento A',
              event_date: '2026-06-01',
              shift_start: null,
              shift_end: '2026-06-01T20:00:00.000Z',
              status: 'confirmed',
            },
          ],
        },
      ],
    });

    renderPage();

    const eventLinks = screen.getAllByRole('link', { name: /Evento/ });
    expect(eventLinks[0]).toHaveAttribute('href', '/events/ev-1/summary');
    expect(eventLinks[1]).toHaveAttribute('href', '/events/ev-2/summary');
    expect(screen.getByText('staff:details.status.pending')).toBeInTheDocument();
    expect(screen.getByText('staff:details.status.confirmed')).toBeInTheDocument();
    expect(screen.getByText(/staff:details.upcoming.shift_to/)).toBeInTheDocument();
    expect(screen.getByText(/staff:details.upcoming.shift_from/)).toBeInTheDocument();
  });
});
