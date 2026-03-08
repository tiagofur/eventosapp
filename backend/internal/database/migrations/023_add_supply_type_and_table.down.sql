DROP TABLE IF EXISTS event_supplies;

ALTER TABLE inventory DROP CONSTRAINT IF EXISTS inventory_type_check;
ALTER TABLE inventory ADD CONSTRAINT inventory_type_check
    CHECK (type IN ('ingredient', 'equipment'));
