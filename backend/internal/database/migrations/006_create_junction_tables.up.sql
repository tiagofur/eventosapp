-- 006 Create Event Products Table
CREATE TABLE IF NOT EXISTS event_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity NUMERIC NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    discount NUMERIC DEFAULT 0,
    total_price NUMERIC GENERATED ALWAYS AS (quantity * (unit_price - COALESCE(discount, 0))) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_event_products_event_id ON event_products(event_id);
CREATE INDEX IF NOT EXISTS idx_event_products_product_id ON event_products(product_id);

-- 007 Create Event Extras Table
CREATE TABLE IF NOT EXISTS event_extras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    cost NUMERIC(10,2) NOT NULL DEFAULT 0,
    price NUMERIC(10,2) NOT NULL DEFAULT 0,
    exclude_utility BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_event_extras_event_id ON event_extras(event_id);

-- 008 Create Product Ingredients Table
CREATE TABLE IF NOT EXISTS product_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
    quantity_required NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_product_ingredients_product_id ON product_ingredients(product_id);
CREATE INDEX IF NOT EXISTS idx_product_ingredients_inventory_id ON product_ingredients(inventory_id);
