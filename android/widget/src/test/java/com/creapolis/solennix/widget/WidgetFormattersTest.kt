package com.creapolis.solennix.widget

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDate

class WidgetFormattersTest {

    @Test
    fun `format event date extracts day and month`() {
        val formatted = WidgetFormatters.formatEventDate("2026-03-20T15:30:00")

        assertEquals("20", formatted.day)
        assertEquals("MAR", formatted.month)
    }

    @Test
    fun `format event date falls back on invalid input`() {
        val formatted = WidgetFormatters.formatEventDate("invalid")

        assertEquals("--", formatted.day)
        assertEquals("---", formatted.month)
    }

    @Test
    fun `format currency uses compact notation for thousands`() {
        val formatted = WidgetFormatters.formatCurrency(15320.0)

        assertTrue(formatted.contains("k"))
        assertTrue(formatted.startsWith("$"))
    }

    @Test
    fun `format time extracts HH mm from iso string`() {
        assertEquals("15:30", WidgetFormatters.formatTime("2026-03-20T15:30:00"))
        assertEquals("", WidgetFormatters.formatTime("2026-03-20"))
    }

    @Test
    fun `format today date capitalizes first letter`() {
        val formatted = WidgetFormatters.formatTodayDate(LocalDate.of(2026, 5, 13))

        assertTrue(formatted.isNotBlank())
        assertTrue(formatted.first().isUpperCase())
        assertTrue(formatted.contains("13"))
    }
}
