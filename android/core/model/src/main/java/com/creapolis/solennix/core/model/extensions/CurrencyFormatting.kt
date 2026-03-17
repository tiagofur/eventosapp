package com.creapolis.solennix.core.model.extensions

import java.text.NumberFormat
import java.util.Locale

fun Double.asMXN(): String {
    val formatter = NumberFormat.getCurrencyInstance(Locale("es", "MX"))
    return formatter.format(this)
}
