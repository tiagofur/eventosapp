package com.creapolis.solennix.core.model.extensions

import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

fun String.toFormattedDate(): String {
    return try {
        val date = ZonedDateTime.parse(this)
        val formatter = DateTimeFormatter.ofPattern("d 'de' MMMM 'de' yyyy", Locale("es", "MX"))
        date.format(formatter)
    } catch (e: Exception) {
        this
    }
}
