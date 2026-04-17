package com.creapolis.solennix.core.data.repository

import com.creapolis.solennix.core.model.EventPublicLink
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.Endpoints
import com.creapolis.solennix.core.network.SolennixException
import com.creapolis.solennix.core.network.get
import com.creapolis.solennix.core.network.post
import kotlinx.serialization.Serializable
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository for the client-portal share link of a single event
 * (PRD/12 feature A — Portal del cliente).
 *
 * Session-scoped: links are NOT cached locally; every call hits the
 * network. The UI is simple enough (single screen, short interaction)
 * that adding Room offline-first support would be overkill.
 */
interface EventPublicLinkRepository {
    /**
     * Returns the currently active link for [eventId], or `null` if
     * none exists (backend returns 404 — treated as an empty state,
     * not an error).
     */
    suspend fun getActive(eventId: String): EventPublicLink?

    /**
     * Creates a new active link, revoking any previous one. Same
     * endpoint is used for first-time creation and rotation.
     *
     * @param ttlDays optional 1..730. `null` means the link never
     * expires (organizer can still revoke it manually).
     */
    suspend fun createOrRotate(eventId: String, ttlDays: Int? = null): EventPublicLink

    /** Revokes the current active link for [eventId]. Backend returns 204. */
    suspend fun revoke(eventId: String)
}

@Serializable
private data class CreatePublicLinkRequest(
    @kotlinx.serialization.SerialName("ttl_days") val ttlDays: Int? = null
)

@Singleton
class DefaultEventPublicLinkRepository @Inject constructor(
    private val apiService: ApiService
) : EventPublicLinkRepository {

    override suspend fun getActive(eventId: String): EventPublicLink? {
        return try {
            apiService.get<EventPublicLink>(Endpoints.eventPublicLink(eventId))
        } catch (e: SolennixException.Server) {
            // 404 == no active link yet. Anything else propagates.
            if (e.code == 404) null else throw e
        }
    }

    override suspend fun createOrRotate(eventId: String, ttlDays: Int?): EventPublicLink {
        val body = CreatePublicLinkRequest(ttlDays = ttlDays)
        return apiService.post<EventPublicLink>(Endpoints.eventPublicLink(eventId), body)
    }

    override suspend fun revoke(eventId: String) {
        apiService.delete(Endpoints.eventPublicLink(eventId))
    }
}
