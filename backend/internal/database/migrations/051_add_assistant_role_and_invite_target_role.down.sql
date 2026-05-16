ALTER TABLE staff_invites
    DROP CONSTRAINT IF EXISTS staff_invites_target_role_check;

ALTER TABLE staff_invites
    DROP COLUMN IF EXISTS target_role;

UPDATE users SET role = 'team_member' WHERE role = 'assistant';

ALTER TABLE users
    DROP CONSTRAINT IF EXISTS users_role_check;

ALTER TABLE users
    ADD CONSTRAINT users_role_check CHECK (role IN ('user', 'admin', 'team_member'));
