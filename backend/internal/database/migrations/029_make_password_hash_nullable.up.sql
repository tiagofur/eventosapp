-- 029 Make password_hash nullable for OAuth users (Google, Apple sign-in)
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
