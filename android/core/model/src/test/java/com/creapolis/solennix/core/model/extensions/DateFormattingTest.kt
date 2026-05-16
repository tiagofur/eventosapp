package com.creapolis.solennix.core.model.extensions

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import java.time.LocalDate

class DateFormattingTest {

    @Test
    fun `parseFlexibleDate parses ISO local date`() {
        val result = parseFlexibleDate("2026-03-22")

        assertEquals(LocalDate.of(2026, 3, 22), result)
    }

    @Test
    fun `parseFlexibleDate parses zoned datetime`() {
        val result = parseFlexibleDate("2026-03-22T00:00:00Z")

        assertEquals(LocalDate.of(2026, 3, 22), result)
    }

    @Test
    fun `parseFlexibleDate parses local datetime`() {
        val result = parseFlexibleDate("2026-03-22T10:30:00")

        assertEquals(LocalDate.of(2026, 3, 22), result)
    }

    @Test
    fun `parseFlexibleDate returns null for invalid date`() {
        val result = parseFlexibleDate("not-a-date")

        assertNull(result)
    }

    @Test
    fun `toFormattedDate returns original value when parsing fails`() {
        val input = "no-date"

        assertEquals(input, input.toFormattedDate())
    }

    @Test
    fun `toFormattedDate returns Spanish long date`() {
        val result = "2026-03-22".toFormattedDate()

        assertNotNull(result)
        assertEquals("22 de marzo de 2026", result)
    }
}