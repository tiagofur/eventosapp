-- Migration: Remove per-product discount column
-- Date: 2026-02-15
-- Description: Simplify discount strategy to only service-level percentage

-- Drop the computed total_price column first
ALTER TABLE public.event_products DROP COLUMN IF EXISTS total_price;

-- Remove the discount column
ALTER TABLE public.event_products DROP COLUMN IF EXISTS discount;

-- Recreate total_price without discount
ALTER TABLE public.event_products ADD COLUMN total_price numeric GENERATED ALWAYS AS (quantity * unit_price) STORED;

-- Update the RPC function (already done in consolidated schema)
-- This migration is for existing databases that need the change applied
