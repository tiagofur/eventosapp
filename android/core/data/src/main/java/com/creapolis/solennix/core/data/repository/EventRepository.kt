package com.creapolis.solennix.core.data.repository

import com.creapolis.solennix.core.database.dao.EventDao
import com.creapolis.solennix.core.database.entity.asEntity
import com.creapolis.solennix.core.database.entity.asExternalModel
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.Endpoints
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

interface EventRepository {
    fun getEvents(): Flow<List<Event>>
    fun getUpcomingEvents(limit: Int = 5): Flow<List<Event>>
    suspend fun getEvent(id: String): Event?
    suspend fun syncEvents()
    suspend fun createEvent(event: Event): Event
    suspend fun updateEvent(event: Event): Event
    suspend fun deleteEvent(id: String)
}

@Singleton
class OfflineFirstEventRepository @Inject constructor(
    private val eventDao: EventDao,
    private val apiService: ApiService
) : EventRepository {

    override fun getEvents(): Flow<List<Event>> =
        eventDao.getEvents().map { it.map { entity -> entity.asExternalModel() } }

    override fun getUpcomingEvents(limit: Int): Flow<List<Event>> =
        eventDao.getUpcomingEvents(limit).map { it.map { entity -> entity.asExternalModel() } }

    override suspend fun getEvent(id: String): Event? =
        eventDao.getEvent(id)?.asExternalModel()

    override suspend fun syncEvents() {
        val networkEvents: List<Event> = apiService.get(Endpoints.EVENTS)
        eventDao.insertEvents(networkEvents.map { it.asEntity() })
    }

    override suspend fun createEvent(event: Event): Event {
        val networkEvent: Event = apiService.post(Endpoints.EVENTS, event)
        eventDao.insertEvents(listOf(networkEvent.asEntity()))
        return networkEvent
    }

    override suspend fun updateEvent(event: Event): Event {
        val networkEvent: Event = apiService.put(Endpoints.event(event.id), event)
        eventDao.insertEvents(listOf(networkEvent.asEntity()))
        return networkEvent
    }

    override suspend fun deleteEvent(id: String) {
        apiService.delete(Endpoints.event(id))
        val cached = eventDao.getEvent(id)
        if (cached != null) {
            eventDao.deleteEvent(cached)
        }
    }
}
