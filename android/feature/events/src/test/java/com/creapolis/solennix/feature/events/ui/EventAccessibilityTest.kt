package com.creapolis.solennix.feature.events.ui

import android.content.Context
import com.creapolis.solennix.core.model.DiscountType
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.model.EventStatus
import com.creapolis.solennix.feature.events.R
import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class EventAccessibilityTest {

    private val context = mockk<Context>(relaxed = true)

    private fun extractVarargs(args: List<Any?>): List<String> {
        val payload = args.getOrNull(1)
        return when (payload) {
            is Array<*> -> payload.map { it.toString() }
            else -> args.drop(1).map { it.toString() }
        }
    }

    init {
        every { context.getString(R.string.events_list_status_quoted) } returns "Cotizado"
        every { context.getString(R.string.events_list_status_confirmed) } returns "Confirmado"
        every { context.getString(R.string.events_list_status_completed) } returns "Completado"
        every { context.getString(R.string.events_list_status_cancelled) } returns "Cancelado"
        every { context.getString(R.string.events_list_a11y_summary, *anyVararg()) } answers {
            val values = extractVarargs(args)
            "${values.getOrNull(0).orEmpty()}, estado ${values.getOrNull(1).orEmpty()}, fecha ${values.getOrNull(2).orEmpty()}, hora ${values.getOrNull(3).orEmpty()}, cliente ${values.getOrNull(4).orEmpty()}, ubicación ${values.getOrNull(5).orEmpty()}, ${values.getOrNull(6).orEmpty()} personas, total ${values.getOrNull(7).orEmpty()}"
        }
    }

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
            context = context,
            event = event,
            clientName = "Maria Lopez",
            formattedDate = "20 abr 2026",
            timeLabel = "18:00",
            locationLabel = "Salon Central"
        )

        assertTrue(label.contains("Boda"))
        assertTrue(label.contains("estado"))
        assertTrue(label.contains("fecha 20 abr 2026"))
        assertTrue(label.contains("hora 18:00"))
        assertTrue(label.contains("cliente Maria Lopez"))
        assertTrue(label.contains("ubicación Salon Central"))
        assertTrue(label.contains("120 personas"))
    }
}
