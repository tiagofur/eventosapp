CREATE TABLE event_equipment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_event_equipment_event_id ON event_equipment(event_id);
CREATE INDEX idx_event_equipment_inventory_id ON event_equipment(inventory_id);
CREATE UNIQUE INDEX idx_event_equipment_unique ON event_equipment(event_id, inventory_id);
CREATE INDEX idx_events_date_status ON events(event_date, status) WHERE status != 'cancelled';
