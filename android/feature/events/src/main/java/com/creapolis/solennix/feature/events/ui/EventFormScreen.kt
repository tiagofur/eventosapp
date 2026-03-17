package com.creapolis.solennix.feature.events.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.creapolis.solennix.core.designsystem.component.PremiumButton
import com.creapolis.solennix.core.designsystem.component.SolennixTextField
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.feature.events.viewmodel.EventFormViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventFormScreen(
    viewModel: EventFormViewModel,
    onNavigateBack: () -> Unit
) {
    val pagerState = rememberPagerState(pageCount = { 5 })
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Nuevo Evento") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        bottomBar = {
            BottomStepNavigation(
                currentPage = pagerState.currentPage,
                onNext = {
                    if (pagerState.currentPage < 4) {
                        scope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) }
                    } else {
                        viewModel.saveEvent()
                    }
                },
                onBack = {
                    scope.launch { pagerState.animateScrollToPage(pagerState.currentPage - 1) }
                },
                isLoading = viewModel.isLoading
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            LinearProgressIndicator(
                progress = { (pagerState.currentPage + 1) / 5f },
                modifier = Modifier.fillMaxWidth(),
                color = SolennixTheme.colors.primary
            )
            
            HorizontalPager(
                state = pagerState,
                modifier = Modifier.fillMaxSize(),
                userScrollEnabled = false
            ) { page ->
                when (page) {
                    0 -> StepGeneralInfo(viewModel)
                    1 -> StepProducts(viewModel)
                    2 -> StepExtras(viewModel)
                    3 -> StepLocation(viewModel)
                    4 -> StepSummary(viewModel)
                }
            }
        }
    }

    if (viewModel.saveSuccess) {
        LaunchedEffect(Unit) { onNavigateBack() }
    }
}

@Composable
fun BottomStepNavigation(
    currentPage: Int,
    onNext: () -> Unit,
    onBack: () -> Unit,
    isLoading: Boolean
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        tonalElevation = 8.dp,
        shadowElevation = 16.dp
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp)
                .fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            if (currentPage > 0) {
                OutlinedButton(onClick = onBack, modifier = Modifier.weight(1f)) {
                    Text("Anterior")
                }
                Spacer(modifier = Modifier.width(16.dp))
            }
            
            PremiumButton(
                text = if (currentPage == 4) "Finalizar" else "Siguiente",
                onClick = onNext,
                modifier = Modifier.weight(1f),
                icon = if (currentPage == 4) Icons.Default.Check else Icons.AutoMirrored.Filled.ArrowForward,
                isLoading = isLoading
            )
        }
    }
}

@Composable
fun StepGeneralInfo(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Informacion General", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        
        SolennixTextField(
            value = viewModel.serviceType,
            onValueChange = { viewModel.serviceType = it },
            label = "Tipo de Evento",
            placeholder = "Boda, Graduacion, etc."
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        SolennixTextField(
            value = viewModel.numPeople,
            onValueChange = { viewModel.numPeople = it },
            label = "Numero de Personas",
            keyboardType = androidx.compose.ui.text.input.KeyboardType.Number
        )
        
        // Add Client Picker and Date Picker here
    }
}

@Composable
fun StepProducts(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Productos y Menu", style = MaterialTheme.typography.headlineSmall)
        // List of selected products and search for more
    }
}

@Composable
fun StepExtras(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Extras y Descuentos", style = MaterialTheme.typography.headlineSmall)
    }
}

@Composable
fun StepLocation(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Ubicacion y Detalles", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        SolennixTextField(
            value = viewModel.location,
            onValueChange = { viewModel.location = it },
            label = "Lugar del Evento"
        )
    }
}

@Composable
fun StepSummary(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Resumen", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        SummaryRow("Subtotal", "$${viewModel.subtotal}")
        SummaryRow("Descuento", "-$${viewModel.discount}")
        HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))
        SummaryRow("Total", "$${viewModel.total}", isTotal = true)
    }
}

@Composable
fun SummaryRow(label: String, value: String, isTotal: Boolean = false) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(
            text = label,
            style = if (isTotal) MaterialTheme.typography.titleLarge else MaterialTheme.typography.bodyLarge,
            fontWeight = if (isTotal) androidx.compose.ui.text.font.FontWeight.Bold else null
        )
        Text(
            text = value,
            style = if (isTotal) MaterialTheme.typography.titleLarge else MaterialTheme.typography.bodyLarge,
            color = if (isTotal) SolennixTheme.colors.primary else SolennixTheme.colors.primaryText,
            fontWeight = if (isTotal) androidx.compose.ui.text.font.FontWeight.Bold else null
        )
    }
}
