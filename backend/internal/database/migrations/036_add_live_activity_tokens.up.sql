CREATE TABLE IF NOT EXISTS live_activity_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    push_token TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    UNIQUE (event_id, push_token)
);

CREATE INDEX IF NOT EXISTS idx_live_activity_tokens_event ON live_activity_tokens(event_id);
CREATE INDEX IF NOT EXISTS idx_live_activity_tokens_user ON live_activity_tokens(user_id);
