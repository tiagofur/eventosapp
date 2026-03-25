-- 029 Revert: make password_hash NOT NULL again
-- Set empty hash for OAuth-only users before re-adding constraint
UPDATE users SET password_hash = '' WHERE password_hash IS NULL;
ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL;
