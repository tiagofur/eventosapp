-- Consolidated schema for EventosApp (2026-02-15)

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- USERS
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email varchar(255) UNIQUE NOT NULL,
  name varchar(100) NOT NULL,
  business_name varchar(255),
  default_deposit_percent numeric,
  default_cancellation_days numeric,
  default_refund_percent numeric,
  plan varchar(20) DEFAULT 'basic' CHECK (plan IN ('basic', 'premium')),
  stripe_customer_id varchar(255),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_plan ON public.users(plan);

-- CLIENTS
CREATE TABLE IF NOT EXISTS public.clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name varchar(100) NOT NULL,
  phone varchar(20) NOT NULL,
  email varchar(255),
  address text,
  city text,
  notes text,
  total_events integer DEFAULT 0,
  total_spent numeric(10,2) DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_clients_user_id ON public.clients(user_id);
CREATE INDEX IF NOT EXISTS idx_clients_name ON public.clients(name);

-- EVENTS
CREATE TABLE IF NOT EXISTS public.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  client_id uuid NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  event_date date NOT NULL,
  start_time time,
  end_time time,
  service_type varchar(100) NOT NULL,
  num_people integer NOT NULL,
  status varchar(20) DEFAULT 'quoted' CHECK (status IN ('quoted', 'confirmed', 'completed', 'cancelled')),
  discount numeric(5,2) DEFAULT 0,
  requires_invoice boolean DEFAULT false,
  tax_rate numeric(5,2) DEFAULT 16,
  tax_amount numeric(10,2) DEFAULT 0,
  total_amount numeric(10,2) NOT NULL,
  location text,
  city text,
  deposit_percent numeric,
  cancellation_days numeric,
  refund_percent numeric,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_user_id ON public.events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_client_id ON public.events(client_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON public.events(status);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name varchar(100) NOT NULL,
  category varchar(50) NOT NULL,
  base_price numeric(10,2) NOT NULL,
  recipe jsonb,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_user_id ON public.products(user_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);

-- INVENTORY
CREATE TABLE IF NOT EXISTS public.inventory (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  ingredient_name varchar(150) NOT NULL,
  current_stock numeric(10,2) NOT NULL DEFAULT 0,
  minimum_stock numeric(10,2) NOT NULL DEFAULT 0,
  unit varchar(20) NOT NULL,
  unit_cost numeric(10,2),
  type text NOT NULL DEFAULT 'ingredient' CHECK (type IN ('ingredient', 'equipment')),
  last_updated timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_inventory_user_id ON public.inventory(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_ingredient ON public.inventory(ingredient_name);

-- EVENT_PRODUCTS
CREATE TABLE IF NOT EXISTS public.event_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity numeric NOT NULL DEFAULT 1,
  unit_price numeric(10,2) NOT NULL,
  discount numeric DEFAULT 0,
  total_price numeric GENERATED ALWAYS AS (quantity * (unit_price - COALESCE(discount, 0))) STORED,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_products_event_id ON public.event_products(event_id);
CREATE INDEX IF NOT EXISTS idx_event_products_product_id ON public.event_products(product_id);

-- EVENT_EXTRAS
CREATE TABLE IF NOT EXISTS public.event_extras (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  description text NOT NULL,
  cost numeric(10,2) NOT NULL DEFAULT 0,
  price numeric(10,2) NOT NULL DEFAULT 0,
  exclude_utility boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_extras_event_id ON public.event_extras(event_id);

-- PRODUCT_INGREDIENTS
CREATE TABLE IF NOT EXISTS public.product_ingredients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  inventory_id uuid NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
  quantity_required numeric NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_ingredients_product_id ON public.product_ingredients(product_id);
CREATE INDEX IF NOT EXISTS idx_product_ingredients_inventory_id ON public.product_ingredients(inventory_id);

-- SUBSCRIPTIONS (reserved for future use)
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  stripe_subscription_id varchar(255) UNIQUE NOT NULL,
  status varchar(50) NOT NULL,
  current_period_start timestamptz,
  current_period_end timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_extras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can view own clients" ON public.clients;
DROP POLICY IF EXISTS "Users can insert own clients" ON public.clients;
DROP POLICY IF EXISTS "Users can update own clients" ON public.clients;
DROP POLICY IF EXISTS "Users can delete own clients" ON public.clients;
CREATE POLICY "Users can view own clients" ON public.clients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own clients" ON public.clients FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own clients" ON public.clients FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own clients" ON public.clients FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own events" ON public.events;
DROP POLICY IF EXISTS "Users can insert own events" ON public.events;
DROP POLICY IF EXISTS "Users can update own events" ON public.events;
DROP POLICY IF EXISTS "Users can delete own events" ON public.events;
CREATE POLICY "Users can view own events" ON public.events FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own events" ON public.events FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own events" ON public.events FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own events" ON public.events FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own products" ON public.products;
DROP POLICY IF EXISTS "Users can insert own products" ON public.products;
DROP POLICY IF EXISTS "Users can update own products" ON public.products;
DROP POLICY IF EXISTS "Users can delete own products" ON public.products;
CREATE POLICY "Users can view own products" ON public.products FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own products" ON public.products FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own products" ON public.products FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own products" ON public.products FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own inventory" ON public.inventory;
DROP POLICY IF EXISTS "Users can insert own inventory" ON public.inventory;
DROP POLICY IF EXISTS "Users can update own inventory" ON public.inventory;
DROP POLICY IF EXISTS "Users can delete own inventory" ON public.inventory;
CREATE POLICY "Users can view own inventory" ON public.inventory FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own inventory" ON public.inventory FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own inventory" ON public.inventory FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own inventory" ON public.inventory FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage event products" ON public.event_products;
CREATE POLICY "Users can manage event products" ON public.event_products FOR ALL USING (
  EXISTS (SELECT 1 FROM public.events WHERE public.events.id = public.event_products.event_id AND public.events.user_id = auth.uid())
) WITH CHECK (
  EXISTS (SELECT 1 FROM public.events WHERE public.events.id = public.event_products.event_id AND public.events.user_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can manage event extras" ON public.event_extras;
CREATE POLICY "Users can manage event extras" ON public.event_extras FOR ALL USING (
  EXISTS (SELECT 1 FROM public.events WHERE public.events.id = public.event_extras.event_id AND public.events.user_id = auth.uid())
) WITH CHECK (
  EXISTS (SELECT 1 FROM public.events WHERE public.events.id = public.event_extras.event_id AND public.events.user_id = auth.uid())
);

DROP POLICY IF EXISTS "Users can manage product ingredients" ON public.product_ingredients;
CREATE POLICY "Users can manage product ingredients" ON public.product_ingredients FOR ALL USING (
  EXISTS (SELECT 1 FROM public.products WHERE public.products.id = public.product_ingredients.product_id AND public.products.user_id = auth.uid())
) WITH CHECK (
  EXISTS (SELECT 1 FROM public.products WHERE public.products.id = public.product_ingredients.product_id AND public.products.user_id = auth.uid())
);

-- Auth user sync
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, plan)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', 'Usuario'),
    'basic'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Client stats trigger
CREATE OR REPLACE FUNCTION update_client_stats()
RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
    UPDATE public.clients
    SET 
      total_events = (SELECT count(*) FROM public.events WHERE client_id = NEW.client_id AND status = 'completed'),
      total_spent = (SELECT COALESCE(sum(total_amount), 0) FROM public.events WHERE client_id = NEW.client_id AND status = 'completed')
    WHERE id = NEW.client_id;
    
    IF (TG_OP = 'UPDATE' AND OLD.client_id <> NEW.client_id) THEN
      UPDATE public.clients
      SET 
        total_events = (SELECT count(*) FROM public.events WHERE client_id = OLD.client_id AND status = 'completed'),
        total_spent = (SELECT COALESCE(sum(total_amount), 0) FROM public.events WHERE client_id = OLD.client_id AND status = 'completed')
      WHERE id = OLD.client_id;
    END IF;
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    UPDATE public.clients
    SET 
      total_events = (SELECT count(*) FROM public.events WHERE client_id = OLD.client_id AND status = 'completed'),
      total_spent = (SELECT COALESCE(sum(total_amount), 0) FROM public.events WHERE client_id = OLD.client_id AND status = 'completed')
    WHERE id = OLD.client_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_event_change ON public.events;
CREATE TRIGGER on_event_change
AFTER INSERT OR UPDATE OR DELETE ON public.events
FOR EACH ROW EXECUTE PROCEDURE update_client_stats();

-- Transactional update for event items
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
$$ LANGUAGE plpgsql;

-- Permissions
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL ROUTINES IN SCHEMA public FROM anon;
GRANT USAGE ON SCHEMA public TO anon;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA public TO authenticated;
