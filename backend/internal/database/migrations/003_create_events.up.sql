-- 003 Create Events Table
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    service_type VARCHAR(100) NOT NULL,
    num_people INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'quoted' CHECK (status IN ('quoted', 'confirmed', 'completed', 'cancelled')),
    discount NUMERIC(5,2) DEFAULT 0,
    requires_invoice BOOLEAN DEFAULT FALSE,
    tax_rate NUMERIC(5,2) DEFAULT 16,
    tax_amount NUMERIC(10,2) DEFAULT 0,
    total_amount NUMERIC(10,2) NOT NULL,
    location TEXT,
    city TEXT,
    deposit_percent NUMERIC,
    cancellation_days NUMERIC,
    refund_percent NUMERIC,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_user_id ON events(user_id);
CREATE INDEX IF NOT EXISTS idx_events_client_id ON events(client_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
