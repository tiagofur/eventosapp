ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_role_check;

ALTER TABLE users
    ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'team_member', 'assistant'));

ALTER TABLE staff_invites
    ADD COLUMN IF NOT EXISTS target_role VARCHAR(20) NOT NULL DEFAULT 'team_member';

ALTER TABLE staff_invites
    DROP CONSTRAINT IF EXISTS staff_invites_target_role_check;

ALTER TABLE staff_invites
    ADD CONSTRAINT staff_invites_target_role_check CHECK (target_role IN ('team_member', 'assistant'));
