import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import {
  Users,
  Calendar,
  ShoppingBag,
  UserPlus,
  CreditCard,
  TrendingUp,
  RefreshCw,
  Shield,
  ArrowRight,
  Crown,
  Star,
} from 'lucide-react';
import { adminService, PlatformStats, SubscriptionOverview } from '@/services/adminService';
import { logError } from '@/lib/errorHandler';
import clsx from 'clsx';
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
} from 'recharts';

export const AdminDashboard: React.FC = () => {
  const [stats, setStats] = useState<PlatformStats | null>(null);
  const [subs, setSubs] = useState<SubscriptionOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const [statsData, subsData] = await Promise.all([
        adminService.getStats(),
        adminService.getSubscriptions(),
      ]);
      setStats(statsData);
      setSubs(subsData);
    } catch (err) {
      logError('Admin: failed to load stats', err);
      setError('Error al cargar las estadísticas. Intenta recargar.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const planDistribution = stats
    ? [
        { name: 'Basic', value: stats.basic_users, color: '#9CA3AF' },
        { name: 'Pro', value: stats.pro_users, color: '#F97316' },
        { name: 'Premium', value: stats.premium_users, color: '#8B5CF6' },
      ].filter((d) => d.value > 0)
    : [];

  const signupData = stats
    ? [
        { name: 'Hoy', value: stats.new_users_today, color: '#10B981' },
        { name: 'Semana', value: stats.new_users_week, color: '#3B82F6' },
        { name: 'Mes', value: stats.new_users_month, color: '#F97316' },
      ]
    : [];



  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 bg-linear-to-br from-red-500 to-orange-500 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-red-500/20">
            <Shield className="h-5 w-5" aria-hidden="true" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-text">Panel de Administración</h1>
            <p className="text-sm text-text-secondary">
              Vista general de la plataforma
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <Link
            to="/admin/users"
            className="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium text-white bg-primary hover:bg-primary-dark transition-colors shadow-sm"
          >
            Gestionar Usuarios <ArrowRight className="h-4 w-4 ml-1" />
          </Link>
          <button
            type="button"
            onClick={loadData}
            className="p-2 text-text-secondary hover:text-primary transition-colors"
            aria-label="Recargar estadísticas"
          >
            <RefreshCw className={clsx("h-5 w-5", loading && "animate-spin")} aria-hidden="true" />
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 dark:bg-red-900/20 border-l-4 border-red-400 p-4 rounded-r-xl" role="alert">
          <p className="text-sm text-error">{error}</p>
        </div>
      )}

      {/* KPI Cards */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {/* Total Users */}
        <div className="bg-card shadow-sm hover:shadow-md border border-border rounded-3xl transition-all duration-300 flex flex-col group hover:-translate-y-0.5 overflow-hidden">
          <div className="p-5 flex-1">
            <div className="flex items-center">
              <div className="shrink-0">
                <div className="h-10 w-10 bg-blue-500/10 rounded-full flex items-center justify-center text-blue-500">
                  <Users className="h-6 w-6" aria-hidden="true" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-xs font-medium text-text-secondary uppercase tracking-wider">Total Usuarios</dt>
                  <dd>
                    <div className="text-2xl font-bold text-text mt-1">
                      {loading ? '...' : stats?.total_users ?? 0}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-surface-alt px-5 py-3 border-t border-border">
            <div className="text-xs text-text-secondary">
              <UserPlus className="inline h-3 w-3 mr-1" />
              Hoy: <span className="font-semibold text-text">{loading ? '...' : stats?.new_users_today ?? 0}</span>
            </div>
          </div>
        </div>

        {/* Pro Users */}
        <div className="bg-card shadow-sm hover:shadow-md border border-border rounded-3xl transition-all duration-300 flex flex-col group hover:-translate-y-0.5 overflow-hidden">
          <div className="p-5 flex-1">
            <div className="flex items-center">
              <div className="shrink-0">
                <div className="h-10 w-10 bg-primary/10 rounded-full flex items-center justify-center text-primary">
                  <Crown className="h-6 w-6" aria-hidden="true" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-xs font-medium text-text-secondary uppercase tracking-wider">Usuarios Pro</dt>
                  <dd>
                    <div className="text-2xl font-bold text-text mt-1">
                      {loading ? '...' : (stats?.pro_users ?? 0) + (stats?.premium_users ?? 0)}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-surface-alt px-5 py-3 border-t border-border">
            <div className="text-xs text-text-secondary">
              <Star className="inline h-3 w-3 mr-1" />
              Suscripciones activas: <span className="font-semibold text-text">{loading ? '...' : stats?.active_subscriptions ?? 0}</span>
            </div>
          </div>
        </div>

        {/* Total Events */}
        <div className="bg-card shadow-sm hover:shadow-md border border-border rounded-3xl transition-all duration-300 flex flex-col group hover:-translate-y-0.5 overflow-hidden">
          <div className="p-5 flex-1">
            <div className="flex items-center">
              <div className="shrink-0">
                <div className="h-10 w-10 bg-success/10 rounded-full flex items-center justify-center text-success">
                  <Calendar className="h-6 w-6" aria-hidden="true" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-xs font-medium text-text-secondary uppercase tracking-wider">Total Eventos</dt>
                  <dd>
                    <div className="text-2xl font-bold text-text mt-1">
                      {loading ? '...' : stats?.total_events ?? 0}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-surface-alt px-5 py-3 border-t border-border">
            <div className="text-xs text-text-secondary">
              Creados por todos los usuarios
            </div>
          </div>
        </div>

        {/* Total Clients */}
        <div className="bg-card shadow-sm hover:shadow-md border border-border rounded-3xl transition-all duration-300 flex flex-col group hover:-translate-y-0.5 overflow-hidden">
          <div className="p-5 flex-1">
            <div className="flex items-center">
              <div className="shrink-0">
                <div className="h-10 w-10 bg-purple-500/10 rounded-full flex items-center justify-center text-purple-500">
                  <ShoppingBag className="h-6 w-6" aria-hidden="true" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-xs font-medium text-text-secondary uppercase tracking-wider">Clientes / Productos</dt>
                  <dd>
                    <div className="text-2xl font-bold text-text mt-1">
                      {loading ? '...' : `${stats?.total_clients ?? 0} / ${stats?.total_products ?? 0}`}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-surface-alt px-5 py-3 border-t border-border">
            <div className="text-xs text-text-secondary">
              Registrados en la plataforma
            </div>
          </div>
        </div>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Plan Distribution Pie */}
        <div className="bg-card shadow-sm border border-border rounded-3xl p-6 transition-colors">
          <h3 className="text-lg font-semibold text-text mb-4">Distribución de Planes</h3>
          <div className="h-64">
            {loading ? (
              <div className="h-full flex items-center justify-center">
                <RefreshCw className="h-8 w-8 animate-spin text-gray-300" />
              </div>
            ) : planDistribution.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={planDistribution}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={90}
                    paddingAngle={4}
                    dataKey="value"
                    label={({ name, value }) => `${name}: ${value}`}
                  >
                    {planDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-text-secondary text-sm">
                Sin datos disponibles
              </div>
            )}
          </div>
          {/* Legend */}
          <div className="flex justify-center gap-4 mt-2">
            {planDistribution.map((entry) => (
              <div key={entry.name} className="flex items-center gap-1.5 text-xs text-text-secondary">
                <div className="w-3 h-3 rounded-full" style={{ backgroundColor: entry.color }} />
                {entry.name}: <span className="font-semibold text-text">{entry.value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Signups Bar Chart */}
        <div className="bg-card shadow-sm border border-border rounded-3xl p-6 transition-colors">
          <h3 className="text-lg font-semibold text-text mb-4">Nuevos Registros</h3>
          <div className="h-64">
            {loading ? (
              <div className="h-full flex items-center justify-center">
                <RefreshCw className="h-8 w-8 animate-spin text-gray-300" />
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={signupData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--color-border)" opacity={0.5} />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#6B7280', fontSize: 12 }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: '#6B7280', fontSize: 12 }} allowDecimals={false} />
                  <Tooltip
                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
                  />
                  <Bar dataKey="value" radius={[8, 8, 0, 0]} barSize={48}>
                    {signupData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

        {/* Subscription Status */}
        <div className="bg-card shadow-sm border border-border rounded-3xl p-6 transition-colors">
          <h3 className="text-lg font-semibold text-text mb-4 flex items-center gap-2">
            <CreditCard className="h-5 w-5 text-primary" aria-hidden="true" />
            Suscripciones
          </h3>
          {loading ? (
            <div className="h-64 flex items-center justify-center">
              <RefreshCw className="h-8 w-8 animate-spin text-gray-300" />
            </div>
          ) : subs ? (
            <div className="space-y-4">
              {/* Status badges */}
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-success/5 border border-success/20 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-success">{subs.total_active}</div>
                  <div className="text-xs text-text-secondary mt-1">Activas</div>
                </div>
                <div className="bg-error/5 border border-error/20 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-error">{subs.total_canceled}</div>
                  <div className="text-xs text-text-secondary mt-1">Canceladas</div>
                </div>
                <div className="bg-blue-500/5 border border-blue-500/20 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-blue-500">{subs.total_trialing}</div>
                  <div className="text-xs text-text-secondary mt-1">Trial</div>
                </div>
                <div className="bg-yellow-500/5 border border-yellow-500/20 rounded-2xl p-4 text-center">
                  <div className="text-2xl font-bold text-yellow-500">{subs.total_past_due}</div>
                  <div className="text-xs text-text-secondary mt-1">Vencidas</div>
                </div>
              </div>

              {/* Provider breakdown */}
              <div className="pt-3 border-t border-border">
                <h4 className="text-xs font-medium text-text-secondary uppercase tracking-wider mb-3">Por Proveedor</h4>
                <div className="space-y-2">
                  {[
                    { name: 'Stripe', count: subs.stripe_count, color: 'bg-purple-500' },
                    { name: 'Apple', count: subs.apple_count, color: 'bg-gray-800' },
                    { name: 'Google', count: subs.google_count, color: 'bg-green-500' },
                  ].map((p) => (
                    <div key={p.name} className="flex items-center justify-between text-sm">
                      <div className="flex items-center gap-2">
                        <div className={`w-2 h-2 rounded-full ${p.color}`} />
                        <span className="text-text-secondary">{p.name}</span>
                      </div>
                      <span className="font-semibold text-text">{p.count}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div className="h-64 flex items-center justify-center text-text-secondary text-sm">
              Sin datos de suscripciones
            </div>
          )}
        </div>
      </div>

      {/* Signup Trends (larger) */}
      <div className="bg-card shadow-sm border border-border rounded-3xl p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-text flex items-center gap-2">
            <TrendingUp className="h-5 w-5 text-success" aria-hidden="true" />
            Resumen de Crecimiento
          </h3>
          <Link
            to="/admin/users"
            className="text-sm font-medium text-primary hover:text-primary-dark flex items-center transition-colors"
          >
            Ver todos los usuarios <ArrowRight className="h-4 w-4 ml-1" />
          </Link>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
          <div className="text-center p-6 bg-surface-alt rounded-2xl border border-border">
            <div className="text-3xl font-bold text-success">{loading ? '...' : stats?.new_users_today ?? 0}</div>
            <div className="text-sm text-text-secondary mt-2">Nuevos hoy</div>
          </div>
          <div className="text-center p-6 bg-surface-alt rounded-2xl border border-border">
            <div className="text-3xl font-bold text-blue-500">{loading ? '...' : stats?.new_users_week ?? 0}</div>
            <div className="text-sm text-text-secondary mt-2">Últimos 7 días</div>
          </div>
          <div className="text-center p-6 bg-surface-alt rounded-2xl border border-border">
            <div className="text-3xl font-bold text-primary">{loading ? '...' : stats?.new_users_month ?? 0}</div>
            <div className="text-sm text-text-secondary mt-2">Últimos 30 días</div>
          </div>
        </div>
      </div>
    </div>
  );
};
