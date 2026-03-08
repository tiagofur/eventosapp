-- Expand inventory.type CHECK constraint to include 'supply'
ALTER TABLE inventory DROP CONSTRAINT IF EXISTS inventory_type_check;
ALTER TABLE inventory ADD CONSTRAINT inventory_type_check
    CHECK (type IN ('ingredient', 'equipment', 'supply'));

-- Per-event supplies table: stores supply assignments for each event
CREATE TABLE event_supplies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
    quantity NUMERIC(10,3) NOT NULL DEFAULT 0,
    unit_cost NUMERIC(10,2) NOT NULL DEFAULT 0,
    source TEXT NOT NULL DEFAULT 'purchase' CHECK (source IN ('stock', 'purchase')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_event_supplies_event_id ON event_supplies(event_id);
CREATE UNIQUE INDEX idx_event_supplies_unique ON event_supplies(event_id, inventory_id);
