package com.creapolis.solennix.feature.products.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

data class DemandDataPoint(
    val eventId: String,
    val eventDate: String, // YYYY-MM-DD
    val clientName: String,
    val quantity: Int,
    val numPeople: Int
)

@Composable
fun DemandForecastChart(
    dataPoints: List<DemandDataPoint>,
    productName: String,
    modifier: Modifier = Modifier
) {
    val colors = SolennixTheme.colors

    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = colors.card),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Header
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.BarChart,
                    contentDescription = null,
                    tint = colors.primary,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Demanda Proyectada",
                    style = MaterialTheme.typography.titleMedium,
                    color = colors.primaryText
                )
            }

            if (dataPoints.isNotEmpty()) {
                DemandBarChart(
                    dataPoints = dataPoints,
                    barColor = colors.primary,
                    labelColor = colors.secondaryText,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp)
                )

                // Summary stats
                val totalQuantity = dataPoints.sumOf { it.quantity }
                val totalPeople = dataPoints.sumOf { it.numPeople }

                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text(
                        text = "Próximos ${dataPoints.size} eventos",
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Medium,
                        color = colors.primaryText
                    )
                    Text(
                        text = "Total: $totalQuantity unidades para $totalPeople personas",
                        style = MaterialTheme.typography.bodySmall,
                        color = colors.secondaryText
                    )
                }

                HorizontalDivider(color = colors.divider)

                // Event list (max 5)
                dataPoints.take(5).forEach { point ->
                    DemandEventRow(point = point, colors = colors)
                }
            } else {
                DemandEmptyState(colors = colors)
            }
        }
    }
}

@Composable
private fun DemandBarChart(
    dataPoints: List<DemandDataPoint>,
    barColor: Color,
    labelColor: Color,
    modifier: Modifier = Modifier
) {
    val maxQuantity = dataPoints.maxOf { it.quantity }.coerceAtLeast(1)
    val dateFormatter = DateTimeFormatter.ofPattern("d MMM", Locale("es"))

    val textMeasurer = rememberTextMeasurer()
    val labelStyle = TextStyle(
        fontSize = 10.sp,
        color = labelColor
    )
    val valueStyle = TextStyle(
        fontSize = 10.sp,
        color = barColor,
        fontWeight = FontWeight.Bold
    )

    Canvas(modifier = modifier) {
        val barCount = dataPoints.size
        val bottomLabelHeight = 36f
        val topPadding = 20f
        val chartHeight = size.height - bottomLabelHeight - topPadding
        val barSpacing = 12f
        val totalSpacing = barSpacing * (barCount + 1)
        val barWidth = ((size.width - totalSpacing) / barCount).coerceAtMost(48f)
        val totalBarsWidth = barWidth * barCount + barSpacing * (barCount + 1)
        val startX = (size.width - totalBarsWidth) / 2f

        dataPoints.forEachIndexed { index, point ->
            val barHeight = (point.quantity.toFloat() / maxQuantity) * chartHeight
            val x = startX + barSpacing + index * (barWidth + barSpacing)
            val y = topPadding + chartHeight - barHeight

            // Bar
            drawRoundRect(
                color = barColor,
                topLeft = Offset(x, y),
                size = Size(barWidth, barHeight),
                cornerRadius = CornerRadius(4f, 4f)
            )

            // Value label above bar
            val valueText = "${point.quantity}"
            val valueLayout = textMeasurer.measure(valueText, valueStyle)
            drawText(
                textLayoutResult = valueLayout,
                topLeft = Offset(
                    x + (barWidth - valueLayout.size.width) / 2f,
                    y - valueLayout.size.height - 2f
                )
            )

            // Date label below bar
            val dateLabel = try {
                LocalDate.parse(point.eventDate).format(dateFormatter)
            } catch (_: Exception) {
                point.eventDate.takeLast(5)
            }
            val dateLabelLayout = textMeasurer.measure(dateLabel, labelStyle)
            drawText(
                textLayoutResult = dateLabelLayout,
                topLeft = Offset(
                    x + (barWidth - dateLabelLayout.size.width) / 2f,
                    topPadding + chartHeight + 8f
                )
            )
        }
    }
}

@Composable
private fun DemandEventRow(
    point: DemandDataPoint,
    colors: com.creapolis.solennix.core.designsystem.theme.SolennixColorScheme
) {
    val dateFormatter = DateTimeFormatter.ofPattern("d 'de' MMMM", Locale("es"))
    val formattedDate = try {
        LocalDate.parse(point.eventDate).format(dateFormatter)
    } catch (_: Exception) {
        point.eventDate
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = point.clientName,
                style = MaterialTheme.typography.bodyMedium,
                color = colors.primaryText
            )
            Text(
                text = formattedDate,
                style = MaterialTheme.typography.bodySmall,
                color = colors.tertiaryText
            )
        }
        Column(horizontalAlignment = Alignment.End) {
            Text(
                text = "${point.quantity} uds",
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = colors.primary
            )
            Text(
                text = "${point.numPeople} personas",
                style = MaterialTheme.typography.bodySmall,
                color = colors.tertiaryText
            )
        }
    }
}

@Composable
private fun DemandEmptyState(
    colors: com.creapolis.solennix.core.designsystem.theme.SolennixColorScheme
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Icon(
            imageVector = Icons.Default.CalendarMonth,
            contentDescription = null,
            modifier = Modifier.size(32.dp),
            tint = colors.tertiaryText
        )
        Text(
            text = "Sin eventos próximos",
            style = MaterialTheme.typography.bodyMedium,
            color = colors.secondaryText
        )
        Text(
            text = "Este producto no está incluido en ningún evento próximo",
            style = MaterialTheme.typography.bodySmall,
            color = colors.tertiaryText
        )
    }
}
