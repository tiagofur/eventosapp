package com.creapolis.solennix.core.database.entity

import androidx.room.Embedded
import androidx.room.Relation
import com.creapolis.solennix.core.model.Event

data class EventWithClient(
    @Embedded val event: CachedEvent,
    @Relation(
        parentColumn = "client_id",
        entityColumn = "id"
    )
    val client: CachedClient?
)

fun EventWithClient.asExternalModel(): Event {
    val model = event.asExternalModel()
    // We can't easily add clientName to Event model without changing it,
    // but we can use this class in the Dao to get everything together.
    return model
}
