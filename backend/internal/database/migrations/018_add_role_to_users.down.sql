-- 018 Rollback: Remove role column from users
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users DROP COLUMN IF EXISTS role;
DROP INDEX IF EXISTS idx_users_role;
