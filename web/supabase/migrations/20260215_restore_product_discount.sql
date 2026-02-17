-- Restore discount column to event_products for hybrid discount strategy
-- Date: 2026-02-15

-- Drop computed total_price column first
ALTER TABLE public.event_products DROP COLUMN IF EXISTS total_price;

-- Add discount column back
ALTER TABLE public.event_products ADD COLUMN IF NOT EXISTS discount numeric DEFAULT 0;

-- Recreate total_price with discount
ALTER TABLE public.event_products ADD COLUMN total_price numeric GENERATED ALWAYS AS (quantity * (unit_price - COALESCE(discount, 0))) STORED;
