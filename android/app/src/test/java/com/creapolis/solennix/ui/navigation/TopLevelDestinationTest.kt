package com.creapolis.solennix.ui.navigation

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class TopLevelDestinationTest {

    @Test
    fun `top level destinations keep the expected route order`() {
        assertEquals(
            listOf("home", "calendar", "events", "clients", "more"),
            TopLevelDestination.entries.map { it.route }
        )
    }

    @Test
    fun `top level destinations keep the expected labels`() {
        assertEquals(
            listOf("Inicio", "Calendario", "Eventos", "Clientes", "Más"),
            TopLevelDestination.entries.map { it.label }
        )
    }
}
