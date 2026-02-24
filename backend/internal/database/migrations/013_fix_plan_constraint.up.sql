-- 013 Fix plan constraint to accept 'pro' in addition to 'basic' and 'premium'
-- The backend's Stripe/RevenueCat webhooks set plan = 'pro', but the constraint
-- only allowed 'basic' | 'premium'. This aligns the DB with the backend logic.

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_plan_check;

ALTER TABLE users
    ADD CONSTRAINT users_plan_check CHECK (plan IN ('basic', 'pro', 'premium'));
