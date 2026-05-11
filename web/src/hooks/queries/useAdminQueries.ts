import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '@/services/adminService';
import { queryKeys } from './queryKeys';
import { useToast } from '@/hooks/useToast';
import { logError, getErrorMessage } from '@/lib/errorHandler';
import { useTranslation } from 'react-i18next';
export { useAdminAuditLogs } from './useActivityQueries';

// ── Queries ──

export function useAdminStats() {
  return useQuery({
    queryKey: queryKeys.admin.stats,
    queryFn: () => adminService.getStats(),
  });
}

export function useAdminUsers() {
  return useQuery({
    queryKey: queryKeys.admin.users,
    queryFn: () => adminService.getUsers(),
  });
}

export function useAdminSubscriptions() {
  return useQuery({
    queryKey: [...queryKeys.admin.stats, 'subscriptions'] as const,
    queryFn: () => adminService.getSubscriptions(),
  });
}

// ── Mutations ──

export function useUpgradeUser() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { t } = useTranslation('admin');

  return useMutation({
    mutationKey: ['admin', 'upgradeUser'],
    mutationFn: ({ id, plan, expiresAt }: { id: string; plan: string; expiresAt: string | null }) =>
      adminService.upgradeUser(id, plan, expiresAt),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.admin.users });
      queryClient.invalidateQueries({ queryKey: queryKeys.admin.stats });
      addToast(t('users.plan_updated'), 'success');
    },
    onError: (error) => {
      logError('Error upgrading user', error);
      addToast(getErrorMessage(error, t('users.error_update_plan')), 'error');
    },
  });
}
