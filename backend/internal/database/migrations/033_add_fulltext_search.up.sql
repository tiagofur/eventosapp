-- Enable pg_trgm for fuzzy matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- GIN indexes for full-text search on each table
-- Clients: search by name, email, phone, city
CREATE INDEX IF NOT EXISTS idx_clients_search ON clients USING GIN (
    (COALESCE(name, '') || ' ' || COALESCE(email, '') || ' ' || COALESCE(phone, '') || ' ' || COALESCE(city, '')) gin_trgm_ops
);

-- Events: search by service_type, location
CREATE INDEX IF NOT EXISTS idx_events_search ON events USING GIN (
    (COALESCE(service_type, '') || ' ' || COALESCE(location, '')) gin_trgm_ops
);

-- Products: search by name, category
CREATE INDEX IF NOT EXISTS idx_products_search ON products USING GIN (
    (COALESCE(name, '') || ' ' || COALESCE(category, '')) gin_trgm_ops
);

-- Inventory: search by ingredient_name, type
CREATE INDEX IF NOT EXISTS idx_inventory_search ON inventory USING GIN (
    (COALESCE(ingredient_name, '') || ' ' || COALESCE(type, '')) gin_trgm_ops
);
