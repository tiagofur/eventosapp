package com.creapolis.solennix.feature.inventory.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.feature.inventory.viewmodel.InventoryDetailViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InventoryDetailScreen(
    viewModel: InventoryDetailViewModel,
    onNavigateBack: () -> Unit,
    onEditClick: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Detalle de Inventario") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    uiState.item?.let { item ->
                        IconButton(onClick = { onEditClick(item.id) }) {
                            Icon(Icons.Default.Edit, contentDescription = "Edit")
                        }
                    }
                }
            )
        }
    ) { padding ->
        if (uiState.isLoading) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        } else if (uiState.item != null) {
            val item = uiState.item!!
            val scrollState = rememberScrollState()
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(scrollState)
                    .padding(24.dp)
            ) {
                Text(
                    text = item.ingredientName,
                    style = MaterialTheme.typography.headlineMedium,
                    color = SolennixTheme.colors.primaryText
                )
                Spacer(modifier = Modifier.height(8.dp))
                
                Surface(
                    color = SolennixTheme.colors.surfaceAlt,
                    shape = MaterialTheme.shapes.small
                ) {
                    Text(
                        text = item.type.name.uppercase(),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = SolennixTheme.colors.secondaryText
                    )
                }
                
                Spacer(modifier = Modifier.height(24.dp))
                
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.weight(1f)) {
                        Text("Stock Actual", style = MaterialTheme.typography.labelMedium, color = SolennixTheme.colors.secondaryText)
                        val isLow = item.currentStock <= item.minimumStock
                        Text(
                            text = "${item.currentStock} ${item.unit}",
                            style = MaterialTheme.typography.titleLarge,
                            color = if (isLow) SolennixTheme.colors.error else SolennixTheme.colors.success,
                            fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                        )
                    }
                    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.weight(1f)) {
                        Text("Stock Mínimo", style = MaterialTheme.typography.labelMedium, color = SolennixTheme.colors.secondaryText)
                        Text(
                            text = "${item.minimumStock} ${item.unit}",
                            style = MaterialTheme.typography.titleLarge,
                            color = SolennixTheme.colors.primaryText,
                            fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                        )
                    }
                }
                
                if (item.unitCost != null) {
                    Spacer(modifier = Modifier.height(24.dp))
                    Text("Costo Unitario", style = MaterialTheme.typography.labelMedium, color = SolennixTheme.colors.secondaryText)
                    Text("$${item.unitCost}", style = MaterialTheme.typography.bodyLarge, color = SolennixTheme.colors.primaryText)
                }

                Spacer(modifier = Modifier.height(24.dp))
                Text("Última actualización: ${item.lastUpdated}", style = MaterialTheme.typography.bodySmall, color = SolennixTheme.colors.tertiaryText)
            }
        }
    }
}
