-- Remove OAuth provider user IDs
DROP INDEX IF EXISTS idx_users_google_user_id;
DROP INDEX IF EXISTS idx_users_apple_user_id;
ALTER TABLE users DROP COLUMN IF EXISTS google_user_id;
ALTER TABLE users DROP COLUMN IF EXISTS apple_user_id;
