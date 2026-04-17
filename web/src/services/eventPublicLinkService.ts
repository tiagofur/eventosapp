import { api } from "../lib/api";

export interface EventPublicLink {
  id: string;
  event_id: string;
  user_id: string;
  token: string;
  status: "active" | "revoked" | "expired";
  expires_at?: string | null;
  revoked_at?: string | null;
  created_at: string;
  updated_at: string;
  /** Absolute URL the organizer shares with the client — server-computed. */
  url: string;
}

/**
 * Wraps the three organizer-facing endpoints for the client-portal share
 * link of a single event (PRD/12 feature A). Public read endpoint lives
 * at /client/:token and is called directly from ClientPortalPage.
 */
export const eventPublicLinkService = {
  /**
   * Returns the currently active link for the event. Throws if none
   * exists (backend returns 404) — caller should treat "no link yet"
   * as a normal state, not an error.
   */
  getActive: async (eventId: string): Promise<EventPublicLink> => {
    return api.get<EventPublicLink>(`/events/${eventId}/public-link`);
  },

  /**
   * Creates a new active link, revoking any previous one. Use this for
   * both first-time creation and rotation — same endpoint either way.
   * Omit `ttlDays` to create a link that never expires (the organizer
   * can still revoke it manually).
   */
  createOrRotate: async (
    eventId: string,
    ttlDays?: number,
  ): Promise<EventPublicLink> => {
    const body = ttlDays !== undefined ? { ttl_days: ttlDays } : {};
    return api.post<EventPublicLink>(`/events/${eventId}/public-link`, body);
  },

  /**
   * Revokes the current active link. Backend returns 204.
   */
  revoke: async (eventId: string): Promise<void> => {
    await api.delete<void>(`/events/${eventId}/public-link`);
  },
};
