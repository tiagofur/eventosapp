import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Users,
  Search,
  ArrowLeft,
  ArrowUpCircle,
  Shield,
  Crown,
  RefreshCw,
  AlertTriangle,
  CheckCircle,
  Filter,
} from 'lucide-react';
import { adminService, AdminUser } from '@/services/adminService';
import { logError } from '@/lib/errorHandler';
import { useToast } from '@/hooks/useToast';
import clsx from 'clsx';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';

type PlanFilter = 'all' | 'basic' | 'pro' | 'premium';

export const AdminUsers: React.FC = () => {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [planFilter, setPlanFilter] = useState<PlanFilter>('all');
  const [upgrading, setUpgrading] = useState<string | null>(null);
  const { addToast } = useToast();

  const loadUsers = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await adminService.getUsers();
      setUsers(data || []);
    } catch (err) {
      logError('Admin: failed to load users', err);
      setError('Error al cargar usuarios.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);



  const handleUpgrade = async (user: AdminUser) => {
    if (user.has_paid_subscription) {
      addToast('No se puede modificar un usuario con suscripción activa pagada.', 'error');
      return;
    }

    const confirmMsg = `¿Estás seguro de que deseas dar plan Pro a ${user.name} (${user.email})?`;
    if (!window.confirm(confirmMsg)) return;

    setUpgrading(user.id);
    try {
      const updated = await adminService.upgradeUser(user.id, 'pro');
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, plan: updated.plan || 'pro' } : u))
      );
      addToast(`${user.name} ahora tiene plan Pro ✓`, 'success');
    } catch (err: unknown) {
      logError('Admin: failed to upgrade user', err);
      const errorMessage = err instanceof Error ? err.message : 'Error al actualizar el plan.';
      addToast(errorMessage, 'error');
    } finally {
      setUpgrading(null);
    }
  };

  const handleDowngrade = async (user: AdminUser) => {
    if (user.has_paid_subscription) {
      addToast('No se puede rebajar a un usuario que tiene suscripción activa pagada. Debe cancelar su suscripción primero.', 'error');
      return;
    }

    const confirmMsg = `¿Estás seguro de que deseas rebajar a ${user.name} (${user.email}) al plan Basic?`;
    if (!window.confirm(confirmMsg)) return;

    setUpgrading(user.id);
    try {
      const updated = await adminService.upgradeUser(user.id, 'basic');
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, plan: updated.plan || 'basic' } : u))
      );
      addToast(`${user.name} ahora tiene plan Basic ✓`, 'success');
    } catch (err: unknown) {
      logError('Admin: failed to downgrade user', err);
      const errorMessage = err instanceof Error ? err.message : 'Error al actualizar el plan.';
      addToast(errorMessage, 'error');
    } finally {
      setUpgrading(null);
    }
  };

  // Filter and search
  const filteredUsers = users.filter((user) => {
    const matchesSearch =
      searchQuery === '' ||
      user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      user.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (user.business_name && user.business_name.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesPlan = planFilter === 'all' || user.plan === planFilter;

    return matchesSearch && matchesPlan;
  });

  const planCounts = {
    all: users.length,
    basic: users.filter((u) => u.plan === 'basic').length,
    pro: users.filter((u) => u.plan === 'pro').length,
    premium: users.filter((u) => u.plan === 'premium').length,
  };

  const getPlanBadge = (plan: string) => {
    const styles: Record<string, string> = {
      basic: 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300',
      pro: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400',
      premium: 'bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400',
    };
    return (
      <span className={clsx(
        "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold",
        styles[plan] || styles.basic
      )}>
        {plan === 'pro' || plan === 'premium' ? <Crown className="h-3 w-3" /> : null}
        {plan.charAt(0).toUpperCase() + plan.slice(1)}
      </span>
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div className="flex items-center gap-3">
          <Link
            to="/admin"
            className="p-2 text-text-secondary hover:text-text hover:bg-surface-alt rounded-xl transition-colors"
            aria-label="Volver al panel de admin"
          >
            <ArrowLeft className="h-5 w-5" />
          </Link>
          <div className="h-10 w-10 bg-linear-to-br from-blue-500 to-blue-600 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-blue-500/20">
            <Users className="h-5 w-5" aria-hidden="true" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-text">Gestión de Usuarios</h1>
            <p className="text-sm text-text-secondary">
              {users.length} usuario{users.length !== 1 ? 's' : ''} registrado{users.length !== 1 ? 's' : ''}
            </p>
          </div>
        </div>
        <button
          type="button"
          onClick={loadUsers}
          className="p-2 text-text-secondary hover:text-primary transition-colors"
          aria-label="Recargar usuarios"
        >
          <RefreshCw className={clsx("h-5 w-5", loading && "animate-spin")} aria-hidden="true" />
        </button>
      </div>



      {error && (
        <div className="bg-red-50 dark:bg-red-900/20 border-l-4 border-red-400 p-4 rounded-r-xl" role="alert">
          <p className="text-sm text-error flex items-center gap-2">
            <AlertTriangle className="h-4 w-4" /> {error}
          </p>
        </div>
      )}

      {/* Filters */}
      <div className="bg-card shadow-sm border border-border rounded-3xl p-5">
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search */}
          <div className="relative flex-1">
            <Search className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" aria-hidden="true" />
            <input
              type="search"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Buscar por nombre, email o negocio..."
              className="w-full rounded-2xl border-0 bg-surface-alt py-3 pl-12 pr-4 text-sm text-text placeholder-text-tertiary focus:ring-2 focus:ring-primary focus:bg-surface transition-all"
              aria-label="Buscar usuarios"
            />
          </div>

          {/* Plan filter pills */}
          <div className="flex items-center gap-1 bg-surface-alt rounded-2xl p-1">
            <Filter className="h-4 w-4 text-text-secondary ml-2 mr-1" aria-hidden="true" />
            {(['all', 'basic', 'pro', 'premium'] as PlanFilter[]).map((filter) => (
              <button
                key={filter}
                type="button"
                onClick={() => setPlanFilter(filter)}
                className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all ${
                  planFilter === filter
                    ? 'bg-primary text-white shadow-sm'
                    : 'text-text-secondary hover:text-text hover:bg-surface'
                }`}
              >
                {filter === 'all' ? 'Todos' : filter.charAt(0).toUpperCase() + filter.slice(1)}{' '}
                <span className="opacity-70">({planCounts[filter]})</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div className="bg-card shadow-sm border border-border rounded-3xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-border" aria-label="Tabla de usuarios">
            <thead className="bg-surface-alt">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-medium text-text-secondary uppercase tracking-wider">
                  Usuario
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-text-secondary uppercase tracking-wider">
                  Plan
                </th>
                <th className="px-6 py-4 text-center text-xs font-medium text-text-secondary uppercase tracking-wider hidden md:table-cell">
                  Eventos
                </th>
                <th className="px-6 py-4 text-center text-xs font-medium text-text-secondary uppercase tracking-wider hidden md:table-cell">
                  Clientes
                </th>
                <th className="px-6 py-4 text-center text-xs font-medium text-text-secondary uppercase tracking-wider hidden lg:table-cell">
                  Productos
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-text-secondary uppercase tracking-wider hidden lg:table-cell">
                  Registro
                </th>
                <th className="px-6 py-4 text-right text-xs font-medium text-text-secondary uppercase tracking-wider">
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody className="bg-card divide-y divide-border">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center">
                    <RefreshCw className="h-8 w-8 animate-spin text-gray-300 mx-auto" />
                    <p className="text-sm text-text-secondary mt-2">Cargando usuarios...</p>
                  </td>
                </tr>
              ) : filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center">
                    <Users className="h-12 w-12 text-gray-300 mx-auto mb-3" />
                    <p className="text-sm text-text-secondary">
                      {searchQuery || planFilter !== 'all'
                        ? 'No se encontraron usuarios con esos filtros.'
                        : 'No hay usuarios registrados aún.'}
                    </p>
                  </td>
                </tr>
              ) : (
                filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-surface-alt/50 transition-colors">
                    {/* User info */}
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="h-9 w-9 rounded-xl bg-linear-to-br from-primary to-orange-400 flex items-center justify-center text-white font-bold text-sm shadow-sm shrink-0">
                          {user.name.charAt(0).toUpperCase()}
                        </div>
                        <div className="min-w-0">
                          <div className="text-sm font-semibold text-text truncate flex items-center gap-1.5">
                            {user.name}
                            {user.role === 'admin' && (
                              <Shield className="h-3.5 w-3.5 text-red-500" aria-label="Admin" />
                            )}
                          </div>
                          <div className="text-xs text-text-secondary truncate">{user.email}</div>
                          {user.business_name && (
                            <div className="text-xs text-text-tertiary truncate">{user.business_name}</div>
                          )}
                        </div>
                      </div>
                    </td>

                    {/* Plan */}
                    <td className="px-6 py-4">
                      <div className="flex flex-col items-start gap-1">
                        {getPlanBadge(user.plan)}
                        {user.has_paid_subscription && (
                          <span className="text-xs text-success flex items-center gap-1">
                            <CheckCircle className="h-3 w-3" /> Pagado
                          </span>
                        )}
                      </div>
                    </td>

                    {/* Events count */}
                    <td className="px-6 py-4 text-center text-sm font-medium text-text hidden md:table-cell">
                      {user.events_count}
                    </td>

                    {/* Clients count */}
                    <td className="px-6 py-4 text-center text-sm font-medium text-text hidden md:table-cell">
                      {user.clients_count}
                    </td>

                    {/* Products count */}
                    <td className="px-6 py-4 text-center text-sm font-medium text-text hidden lg:table-cell">
                      {user.products_count}
                    </td>

                    {/* Created at */}
                    <td className="px-6 py-4 text-sm text-text-secondary hidden lg:table-cell whitespace-nowrap">
                      {format(parseISO(user.created_at), "d MMM ''yy", { locale: es })}
                    </td>

                    {/* Actions */}
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        {user.plan === 'basic' && (
                          <button
                            type="button"
                            onClick={() => handleUpgrade(user)}
                            disabled={upgrading === user.id}
                            className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-semibold bg-primary/10 text-primary hover:bg-primary hover:text-white transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                            title={user.has_paid_subscription ? 'No se puede modificar: tiene suscripción pagada' : 'Dar plan Pro'}
                          >
                            {upgrading === user.id ? (
                              <RefreshCw className="h-3 w-3 animate-spin" />
                            ) : (
                              <ArrowUpCircle className="h-3 w-3" />
                            )}
                            Dar Pro
                          </button>
                        )}
                        {(user.plan === 'pro' || user.plan === 'premium') && !user.has_paid_subscription && (
                          <button
                            type="button"
                            onClick={() => handleDowngrade(user)}
                            disabled={upgrading === user.id}
                            className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-semibold bg-gray-100 text-gray-600 hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                            title="Rebajar a plan Basic"
                          >
                            {upgrading === user.id ? (
                              <RefreshCw className="h-3 w-3 animate-spin" />
                            ) : null}
                            Rebajar
                          </button>
                        )}
                        {(user.plan === 'pro' || user.plan === 'premium') && user.has_paid_subscription && (
                          <span className="text-xs text-text-tertiary italic" title="No se puede modificar: suscripción pagada activa">
                            Suscripción activa
                          </span>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Footer with count */}
        {!loading && filteredUsers.length > 0 && (
          <div className="px-6 py-3 bg-surface-alt border-t border-border text-xs text-text-secondary">
            Mostrando {filteredUsers.length} de {users.length} usuario{users.length !== 1 ? 's' : ''}
          </div>
        )}
      </div>
    </div>
  );
};
