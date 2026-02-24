-- 013 Rollback: restore original plan constraint
ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_plan_check;

ALTER TABLE users
    ADD CONSTRAINT users_plan_check CHECK (plan IN ('basic', 'premium'));
