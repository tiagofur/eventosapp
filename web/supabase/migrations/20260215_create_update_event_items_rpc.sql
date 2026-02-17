-- Create update_event_items RPC function for transactional updates
-- Date: 2026-02-15

-- Drop existing function first to allow parameter name change
DROP FUNCTION IF EXISTS public.update_event_items(uuid, jsonb, jsonb);

CREATE OR REPLACE FUNCTION public.update_event_items(
  p_event_id uuid,
  products_json jsonb,
  extras_json jsonb
)
RETURNS void AS $$
DECLARE
  products_payload jsonb := COALESCE(products_json, '[]'::jsonb);
  extras_payload jsonb := COALESCE(extras_json, '[]'::jsonb);
BEGIN
  DELETE FROM public.event_products WHERE event_id = p_event_id;
  DELETE FROM public.event_extras WHERE event_id = p_event_id;

  IF jsonb_array_length(products_payload) > 0 THEN
    INSERT INTO public.event_products (event_id, product_id, quantity, unit_price, discount)
    SELECT
      p_event_id,
      (p->>'productId')::uuid,
      COALESCE((p->>'quantity')::numeric, 0),
      COALESCE((p->>'unitPrice')::numeric, 0),
      COALESCE((p->>'discount')::numeric, 0)
    FROM jsonb_array_elements(products_payload) AS p;
  END IF;

  IF jsonb_array_length(extras_payload) > 0 THEN
    INSERT INTO public.event_extras (event_id, description, cost, price, exclude_utility)
    SELECT
      p_event_id,
      p->>'description',
      COALESCE((p->>'cost')::numeric, 0),
      COALESCE((p->>'price')::numeric, 0),
      COALESCE((p->>'exclude_utility')::boolean, false)
    FROM jsonb_array_elements(extras_payload) AS p;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.update_event_items(uuid, jsonb, jsonb) TO authenticated;
