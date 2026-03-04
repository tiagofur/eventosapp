-- 018 Add role column to users table for admin access
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user' NOT NULL;

ALTER TABLE users
    ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin'));

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
