-- Add invoice and contract columns to events table
-- Date: 2026-02-15

ALTER TABLE public.events 
ADD COLUMN IF NOT EXISTS requires_invoice boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS tax_rate numeric(5,2) DEFAULT 16,
ADD COLUMN IF NOT EXISTS tax_amount numeric(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS location text,
ADD COLUMN IF NOT EXISTS city text,
ADD COLUMN IF NOT EXISTS deposit_percent numeric,
ADD COLUMN IF NOT EXISTS cancellation_days numeric,
ADD COLUMN IF NOT EXISTS refund_percent numeric;
