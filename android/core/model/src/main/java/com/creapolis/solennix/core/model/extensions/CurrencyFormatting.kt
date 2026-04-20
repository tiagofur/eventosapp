package com.creapolis.solennix.core.model.extensions

import java.text.NumberFormat
import java.util.Locale

/**
 * Standard MXN formatting with 2 decimals — `$8,515.40`.
 * Use everywhere cents matter (event detail, payments, PDFs, reconciliation).
 */
fun Double.asMXN(): String {
    val formatter = NumberFormat.getCurrencyInstance(Locale("es", "MX"))
    return formatter.format(this)
}

/**
 * Compact MXN formatting with zero decimals — `$8,515`.
 *
 * For KPI cards on the dashboard where the 2-column mobile grid is tight
 * and cents add noise without adding insight. Matches iOS (`.asMXN`
 * already uses `maximumFractionDigits = 0`) and the web dashboard's
 * `fmt()` with `minimumFractionDigits: 0`. Do NOT use this for invoice-
 * level screens — reconciliation users need the centavos.
 */
fun Double.asMXNCompact(): String {
    val formatter = NumberFormat.getCurrencyInstance(Locale("es", "MX"))
    formatter.maximumFractionDigits = 0
    formatter.minimumFractionDigits = 0
    return formatter.format(this)
}
