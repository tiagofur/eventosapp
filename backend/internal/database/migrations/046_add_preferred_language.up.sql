-- Add preferred_language column to users table for i18n support.
-- Used by email_service to send emails in the user's chosen language.
-- Default is 'es' (Spanish LATAM) since the app started in Mexico.
ALTER TABLE users ADD COLUMN preferred_language VARCHAR(5) NOT NULL DEFAULT 'es';
