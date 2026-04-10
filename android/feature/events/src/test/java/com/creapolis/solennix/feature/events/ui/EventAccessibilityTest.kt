package com.creapolis.solennix.feature.events.ui

import com.creapolis.solennix.core.model.DiscountType
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.model.EventStatus
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class EventAccessibilityTest {

    @Test
    fun `eventCardTalkBackLabel includes key event fields`() {
        val event = Event(
            id = "event-1",
            userId = "user-1",
            clientId = "client-1",
            eventDate = "2026-04-20",
            startTime = "18:00",
            serviceType = "Boda",
            numPeople = 120,
            status = EventStatus.CONFIRMED,
            discount = 0.0,
            discountType = DiscountType.PERCENT,
            totalAmount = 12345.0,
            location = "Salon Central",
            createdAt = "2026-01-01T00:00:00Z",
            updatedAt = "2026-01-01T00:00:00Z"
        )

        val label = eventCardTalkBackLabel(
            event = event,
            clientName = "Maria Lopez",
            formattedDate = "20 abr 2026"
        )

        assertTrue(label.contains("Boda"))
        assertTrue(label.contains("estado confirmed"))
        assertTrue(label.contains("fecha 20 abr 2026"))
        assertTrue(label.contains("hora 18:00"))
        assertTrue(label.contains("cliente Maria Lopez"))
        assertTrue(label.contains("ubicación Salon Central"))
        assertTrue(label.contains("120 personas"))
    }
}
