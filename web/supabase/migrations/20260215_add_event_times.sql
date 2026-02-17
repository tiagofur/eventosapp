-- Add start_time and end_time columns to events table
-- Date: 2026-02-15

ALTER TABLE public.events 
ADD COLUMN IF NOT EXISTS start_time time,
ADD COLUMN IF NOT EXISTS end_time time;
