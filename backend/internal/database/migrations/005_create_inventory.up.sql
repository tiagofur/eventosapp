-- 005 Create Inventory Table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(150) NOT NULL,
    current_stock NUMERIC(10,2) NOT NULL DEFAULT 0,
    minimum_stock NUMERIC(10,2) NOT NULL DEFAULT 0,
    unit VARCHAR(20) NOT NULL,
    unit_cost NUMERIC(10,2),
    type TEXT NOT NULL DEFAULT 'ingredient' CHECK (type IN ('ingredient', 'equipment')),
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON inventory(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_ingredient ON inventory(ingredient_name);
