-- Add plan_expires_at column to support time-limited gifted plans.
-- When set (non-NULL) and in the past, a background job resets the plan to 'basic'.
-- Only applies to manually-gifted plans; paid subscriptions are never touched.
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS plan_expires_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_users_plan_expires_at
    ON users (plan_expires_at)
    WHERE plan_expires_at IS NOT NULL;
