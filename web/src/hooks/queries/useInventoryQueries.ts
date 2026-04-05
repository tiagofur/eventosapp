import { useQuery } from '@tanstack/react-query';
import { inventoryService } from '@/services/inventoryService';
import { queryKeys } from './queryKeys';

// Skeleton — full hooks will be added when Inventory module is migrated.
// For now, only what other domains need (ProductForm dropdown).

export function useInventoryItems() {
  return useQuery({
    queryKey: queryKeys.inventory.all,
    queryFn: () => inventoryService.getAll(),
  });
}
