package com.creapolis.solennix.feature.dashboard.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme

/**
 * Represents a step in the onboarding process.
 */
data class OnboardingStep(
    val id: String,
    val title: String,
    val description: String,
    val icon: ImageVector,
    val isCompleted: Boolean,
    val action: String
)

/**
 * A checklist card that guides new users through initial setup.
 */
@Composable
fun OnboardingChecklist(
    steps: List<OnboardingStep>,
    onStepClick: (OnboardingStep) -> Unit,
    onDismiss: () -> Unit,
    visible: Boolean = true,
    modifier: Modifier = Modifier
) {
    val completedCount = steps.count { it.isCompleted }
    val progress = if (steps.isNotEmpty()) completedCount.toFloat() / steps.size else 0f
    val animatedProgress by animateFloatAsState(targetValue = progress, label = "progress")

    AnimatedVisibility(
        visible = visible && completedCount < steps.size,
        enter = expandVertically(),
        exit = shrinkVertically()
    ) {
        Card(
            modifier = modifier
                .fillMaxWidth()
                .padding(16.dp),
            colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
            shape = RoundedCornerShape(16.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.Rocket,
                            contentDescription = null,
                            tint = SolennixTheme.colors.primary,
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Primeros pasos",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = SolennixTheme.colors.primaryText
                        )
                    }
                    IconButton(onClick = onDismiss) {
                        Icon(
                            Icons.Default.Close,
                            contentDescription = "Cerrar",
                            tint = SolennixTheme.colors.secondaryText
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Progress
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    LinearProgressIndicator(
                        progress = { animatedProgress },
                        modifier = Modifier
                            .weight(1f)
                            .height(6.dp)
                            .clip(RoundedCornerShape(3.dp)),
                        color = SolennixTheme.colors.primary,
                        trackColor = SolennixTheme.colors.divider
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "$completedCount/${steps.size}",
                        style = MaterialTheme.typography.labelMedium,
                        color = SolennixTheme.colors.secondaryText
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Steps
                steps.forEach { step ->
                    OnboardingStepItem(
                        step = step,
                        onClick = { onStepClick(step) }
                    )
                }
            }
        }
    }
}

@Composable
private fun OnboardingStepItem(
    step: OnboardingStep,
    onClick: () -> Unit
) {
    val backgroundColor by animateColorAsState(
        targetValue = if (step.isCompleted)
            SolennixTheme.colors.success.copy(alpha = 0.1f)
        else
            Color.Transparent,
        label = "bgColor"
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .clip(RoundedCornerShape(8.dp))
            .background(backgroundColor)
            .clickable(enabled = !step.isCompleted) { onClick() }
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Icon/Checkbox
        Box(
            modifier = Modifier
                .size(32.dp)
                .clip(CircleShape)
                .background(
                    if (step.isCompleted)
                        SolennixTheme.colors.success
                    else
                        SolennixTheme.colors.primaryLight
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = if (step.isCompleted) Icons.Default.Check else step.icon,
                contentDescription = null,
                tint = if (step.isCompleted) Color.White else SolennixTheme.colors.primary,
                modifier = Modifier.size(16.dp)
            )
        }

        Spacer(modifier = Modifier.width(12.dp))

        // Content
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = step.title,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = if (step.isCompleted)
                    SolennixTheme.colors.success
                else
                    SolennixTheme.colors.primaryText
            )
            Text(
                text = step.description,
                style = MaterialTheme.typography.bodySmall,
                color = SolennixTheme.colors.secondaryText
            )
        }

        // Action indicator
        if (!step.isCompleted) {
            Icon(
                Icons.Default.ChevronRight,
                contentDescription = null,
                tint = SolennixTheme.colors.secondaryText,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

/**
 * Default onboarding steps for new users.
 */
object OnboardingSteps {
    fun getDefaultSteps(
        hasClients: Boolean,
        hasProducts: Boolean,
        hasEvents: Boolean
    ): List<OnboardingStep> = listOf(
        OnboardingStep(
            id = "create_client",
            title = "Crear tu primer cliente",
            description = "Registra los datos de tu primer cliente",
            icon = Icons.Default.PersonAdd,
            isCompleted = hasClients,
            action = "clients"
        ),
        OnboardingStep(
            id = "create_product",
            title = "Agregar un producto o servicio",
            description = "Define lo que ofreces a tus clientes",
            icon = Icons.Default.Category,
            isCompleted = hasProducts,
            action = "products"
        ),
        OnboardingStep(
            id = "create_event",
            title = "Crear tu primer evento",
            description = "Cotiza y organiza tu primer evento",
            icon = Icons.Default.Event,
            isCompleted = hasEvents,
            action = "events"
        )
    )
}
