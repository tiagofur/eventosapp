package com.creapolis.solennix.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Status of an [EventPublicLink] as returned by the backend.
 * Matches `events.event_public_links.status` in the API contract
 * (PRD/12 feature A — Portal del cliente).
 */
@Serializable
enum class EventPublicLinkStatus {
    @SerialName("active") ACTIVE,
    @SerialName("revoked") REVOKED,
    @SerialName("expired") EXPIRED
}

/**
 * Private share link that an organizer generates so their client can
 * consult the event details (schedule, payment status, notes) via a
 * token-based public page. Only one link per event is active at a
 * time; creating a new one revokes the previous one server-side.
 */
@Serializable
data class EventPublicLink(
    val id: String,
    @SerialName("event_id") val eventId: String,
    @SerialName("user_id") val userId: String,
    val token: String,
    val status: EventPublicLinkStatus,
    /** ISO 8601 UTC. `null` when the link never expires — the organizer can still revoke it manually. */
    @SerialName("expires_at") val expiresAt: String? = null,
    /** ISO 8601 UTC. Set once the link is revoked; `null` while active. */
    @SerialName("revoked_at") val revokedAt: String? = null,
    @SerialName("created_at") val createdAt: String,
    @SerialName("updated_at") val updatedAt: String,
    /** Absolute URL the organizer shares with the client — server-computed. */
    val url: String
)
