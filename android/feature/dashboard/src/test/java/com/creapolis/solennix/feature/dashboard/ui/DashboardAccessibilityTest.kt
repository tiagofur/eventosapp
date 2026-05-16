package com.creapolis.solennix.feature.dashboard.ui

import android.content.Context
import com.creapolis.solennix.core.model.DiscountType
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.model.EventStatus
import com.creapolis.solennix.core.model.InventoryItem
import com.creapolis.solennix.core.model.InventoryType
import com.creapolis.solennix.feature.dashboard.R
import com.creapolis.solennix.feature.dashboard.viewmodel.PendingEvent
import com.creapolis.solennix.feature.dashboard.viewmodel.PendingEventReason
import io.mockk.every
import io.mockk.mockk
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test

class DashboardAccessibilityTest {

    private val context = mockk<Context>(relaxed = true)

    private fun extractVarargs(args: List<Any?>): List<String> {
        val payload = args.getOrNull(1)
        return when (payload) {
            is Array<*> -> payload.map { it.toString() }
            else -> args.drop(1).map { it.toString() }
        }
    }

    init {
        every { context.getString(R.string.dashboard_status_quoted) } returns "Cotizado"
        every { context.getString(R.string.dashboard_status_confirmed) } returns "Confirmado"
        every { context.getString(R.string.dashboard_status_completed) } returns "Completado"
        every { context.getString(R.string.dashboard_status_cancelled) } returns "Cancelado"
        every {
            context.getString(R.string.dashboard_a11y_pending_event, *anyVararg())
        } answers {
            val values = extractVarargs(args)
            "Evento pendiente: ${values.getOrNull(1).orEmpty()}, fecha ${values.getOrNull(2).orEmpty()}, motivo ${values.getOrNull(3).orEmpty()}"
        }
        every {
            context.getString(R.string.dashboard_a11y_event_with_client, *anyVararg())
        } answers {
            val values = extractVarargs(args)
            "${values.getOrNull(0).orEmpty()}, ${values.getOrNull(1).orEmpty()}, fecha ${values.getOrNull(2).orEmpty()}, estado ${values.getOrNull(3).orEmpty()}"
        }
        every {
            context.getString(R.string.dashboard_a11y_inventory_alert, *anyVararg())
        } answers {
            val values = extractVarargs(args)
            "Stock bajo: ${values.getOrNull(0).orEmpty()}, actual ${values.getOrNull(1).orEmpty()} ${values.getOrNull(2).orEmpty()}"
        }
    }

    @Test
    fun `pendingEventTalkBackLabel includes service date and reason`() {
        val event = Event(
            id = "event-1",
            userId = "user-1",
            clientId = "client-1",
            eventDate = "2026-05-12",
            serviceType = "XV",
            numPeople = 100,
            status = EventStatus.QUOTED,
            discount = 0.0,
            discountType = DiscountType.PERCENT,
            totalAmount = 5000.0,
            createdAt = "2026-01-01T00:00:00Z",
            updatedAt = "2026-01-01T00:00:00Z"
        )

        val label = pendingEventTalkBackLabel(
            PendingEvent(
                event = event,
                reason = PendingEventReason.PAYMENT_DUE,
                reasonLabel = "Falta anticipo",
                pendingAmount = 100.0
            ),
            context
        )

        assertTrue(label.contains("XV"))
        assertTrue(label.contains("2026-05-12"))
        assertTrue(label.contains("Falta anticipo"))
    }

    @Test
    fun `dashboardEventTalkBackLabel includes client when provided`() {
        val event = Event(
            id = "event-2",
            userId = "user-1",
            clientId = "client-2",
            eventDate = "2026-06-01",
            serviceType = "Boda",
            numPeople = 180,
            status = EventStatus.CONFIRMED,
            discount = 0.0,
            discountType = DiscountType.PERCENT,
            totalAmount = 9500.0,
            createdAt = "2026-01-01T00:00:00Z",
            updatedAt = "2026-01-01T00:00:00Z"
        )

        val label = dashboardEventTalkBackLabel(event, "Ana Perez", context)

        assertTrue(label.contains("Ana Perez"))
        assertTrue(label.contains("Boda"))
        assertTrue(label.contains("estado"))
    }

    @Test
    fun `inventoryAlertTalkBackLabel describes current stock`() {
        val inventoryItem = InventoryItem(
            id = "inv-1",
            ingredientName = "Sillas",
            currentStock = 3.0,
            minimumStock = 10.0,
            unit = "pzs",
            type = InventoryType.EQUIPMENT
        )

        val label = inventoryAlertTalkBackLabel(inventoryItem, context)

        assertTrue(label.contains("Sillas"))
        assertTrue(label.contains("3.0"))
        assertTrue(label.contains("pzs"))
    }
}
