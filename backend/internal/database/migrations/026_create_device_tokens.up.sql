-- Create device_tokens table for push notification registration
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);

-- Index for fast lookup by user_id
CREATE INDEX idx_device_tokens_user_id ON device_tokens(user_id);

-- Index for fast lookup by token (for unregister)
CREATE INDEX idx_device_tokens_token ON device_tokens(token);
