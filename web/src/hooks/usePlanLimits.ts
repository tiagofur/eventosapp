import { useMemo } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { startOfMonth, endOfMonth, format } from 'date-fns';
import { useEventsByDateRange } from './queries/useEventQueries';
import { useClients } from './queries/useClientQueries';
import { useProducts } from './queries/useProductQueries';
import { useInventoryItems } from './queries/useInventoryQueries';

const FREE_PLAN_LIMIT = 3;
const CLIENT_LIMIT = 50;
const CATALOG_LIMIT = 20;

export function usePlanLimits() {
  const { user } = useAuth();
  const isBasicPlan = user?.plan === 'basic' || !user?.plan;

  const now = useMemo(() => new Date(), []);
  const start = useMemo(() => format(startOfMonth(now), 'yyyy-MM-dd'), [now]);
  const end = useMemo(() => format(endOfMonth(now), 'yyyy-MM-dd'), [now]);

  // NOTE: ?? [] instead of = [] — destructuring defaults only catch undefined, not null
  const { data: _monthEvents, isLoading: eventsLoading } = useEventsByDateRange(start, end);
  const { data: _clients, isLoading: clientsLoading } = useClients();
  const { data: _products, isLoading: productsLoading } = useProducts();
  const { data: _inventory, isLoading: inventoryLoading } = useInventoryItems();

  const monthEvents = _monthEvents ?? [];
  const clientList = _clients ?? [];
  const productList = _products ?? [];
  const inventoryList = _inventory ?? [];

  const eventsThisMonth = monthEvents.length;
  const clientsCount = clientList.length;
  const catalogCount = productList.length + inventoryList.length;

  const loading = eventsLoading || (isBasicPlan && (clientsLoading || productsLoading || inventoryLoading));

  const canCreateEvent = !isBasicPlan || eventsThisMonth < FREE_PLAN_LIMIT;
  const canCreateClient = !isBasicPlan || clientsCount < CLIENT_LIMIT;
  const canCreateCatalogItem = !isBasicPlan || catalogCount < CATALOG_LIMIT;

  return {
    isBasicPlan,
    eventsThisMonth,
    limit: FREE_PLAN_LIMIT,
    clientsCount,
    clientLimit: CLIENT_LIMIT,
    catalogCount,
    catalogLimit: CATALOG_LIMIT,
    canCreateEvent,
    canCreateClient,
    canCreateCatalogItem,
    loading,
  };
}
