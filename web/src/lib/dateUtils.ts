/**
 * Parse a YYYY-MM-DD date string into a Date object that represents
 * the correct calendar day regardless of the user's timezone.
 *
 * Why T12:00:00? A date-only string like "2026-04-22" is parsed as UTC
 * midnight by the JS Date constructor. In timezones behind UTC (e.g.
 * UTC-6 Mexico), that becomes April 21 at 18:00 local — one day off.
 * Anchoring to noon gives ±12h of buffer so the day is always correct.
 */
export function parseEventDate(dateStr: string): Date {
  return new Date(`${dateStr}T12:00:00`);
}
