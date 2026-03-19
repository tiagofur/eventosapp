package com.creapolis.solennix.core.model.extensions

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

/**
 * Parses a date string flexibly, supporting:
 * - "2026-03-22" (LocalDate — API format)
 * - "2026-03-22T00:00:00Z" (ZonedDateTime)
 * - "2026-03-22T00:00:00" (LocalDateTime)
 */
fun parseFlexibleDate(dateStr: String): LocalDate? {
    return try {
        LocalDate.parse(dateStr)
    } catch (_: Exception) {
        try {
            ZonedDateTime.parse(dateStr).toLocalDate()
        } catch (_: Exception) {
            try {
                LocalDateTime.parse(dateStr).toLocalDate()
            } catch (_: Exception) {
                null
            }
        }
    }
}

fun String.toFormattedDate(): String {
    val date = parseFlexibleDate(this) ?: return this
    val formatter = DateTimeFormatter.ofPattern("d 'de' MMMM 'de' yyyy", Locale("es", "MX"))
    return date.format(formatter)
}
