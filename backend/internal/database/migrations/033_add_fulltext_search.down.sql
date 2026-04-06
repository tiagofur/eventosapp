DROP INDEX IF EXISTS idx_clients_search;
DROP INDEX IF EXISTS idx_events_search;
DROP INDEX IF EXISTS idx_products_search;
DROP INDEX IF EXISTS idx_inventory_search;
-- Don't drop pg_trgm extension as other things might use it
