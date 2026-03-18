-- Add OAuth provider user IDs for Google and Apple Sign-In
ALTER TABLE users ADD COLUMN google_user_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN apple_user_id VARCHAR(255) UNIQUE;

-- Create indexes for fast lookup
CREATE INDEX idx_users_google_user_id ON users(google_user_id) WHERE google_user_id IS NOT NULL;
CREATE INDEX idx_users_apple_user_id ON users(apple_user_id) WHERE apple_user_id IS NOT NULL;
