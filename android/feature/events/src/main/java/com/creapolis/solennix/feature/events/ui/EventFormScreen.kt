package com.creapolis.solennix.feature.events.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.component.*
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.model.Client
import com.creapolis.solennix.core.model.InventoryItem
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.model.SupplySource
import com.creapolis.solennix.core.model.extensions.asMXN
import com.creapolis.solennix.feature.events.viewmodel.EventFormViewModel
import kotlinx.coroutines.launch
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventFormScreen(
    viewModel: EventFormViewModel,
    onNavigateBack: () -> Unit
) {
    val pagerState = rememberPagerState(pageCount = { 6 })
    val scope = rememberCoroutineScope()

    // Trigger suggestions when entering equipment/supplies steps
    LaunchedEffect(pagerState.currentPage) {
        when (pagerState.currentPage) {
            3 -> viewModel.fetchEquipmentSuggestions()
            4 -> viewModel.fetchSupplySuggestions()
        }
    }

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
                totalPages = 6,
                onNext = {
                    if (pagerState.currentPage < 5) {
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
                progress = { (pagerState.currentPage + 1) / 6f },
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
                    3 -> StepEquipment(viewModel)
                    4 -> StepSupplies(viewModel)
                    5 -> StepSummary(viewModel)
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
    totalPages: Int = 6,
    onNext: () -> Unit,
    onBack: () -> Unit,
    isLoading: Boolean
) {
    val isLastPage = currentPage == totalPages - 1
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
                text = if (isLastPage) "Finalizar" else "Siguiente",
                onClick = onNext,
                modifier = Modifier.weight(1f),
                icon = if (isLastPage) Icons.Default.Check else Icons.AutoMirrored.Filled.ArrowForward,
                isLoading = isLoading
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StepGeneralInfo(viewModel: EventFormViewModel) {
    var showClientPicker by remember { mutableStateOf(false) }
    var showDatePicker by remember { mutableStateOf(false) }

    Column(modifier = Modifier.padding(24.dp)) {
        Text("Información General", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        
        // Client Selection
        Text("Cliente", style = MaterialTheme.typography.labelMedium, color = SolennixTheme.colors.secondaryText)
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .clickable { showClientPicker = true },
            colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.surface)
        ) {
            Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Person, contentDescription = null, tint = SolennixTheme.colors.primary)
                Spacer(modifier = Modifier.width(16.dp))
                Text(
                    text = viewModel.selectedClient?.name ?: "Seleccionar Cliente",
                    style = MaterialTheme.typography.bodyLarge,
                    color = if (viewModel.selectedClient == null) SolennixTheme.colors.tertiaryText else SolennixTheme.colors.primaryText
                )
                Spacer(modifier = Modifier.weight(1f))
                Icon(Icons.Default.Search, contentDescription = null, tint = SolennixTheme.colors.secondaryText)
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        SolennixTextField(
            value = viewModel.serviceType,
            onValueChange = { viewModel.serviceType = it },
            label = "Tipo de Evento",
            placeholder = "Boda, Graduación, etc.",
            leadingIcon = Icons.Default.Event
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            SolennixTextField(
                value = viewModel.numPeople,
                onValueChange = { viewModel.numPeople = it },
                label = "Personas",
                leadingIcon = Icons.Default.People,
                keyboardType = androidx.compose.ui.text.input.KeyboardType.Number,
                modifier = Modifier.weight(1f)
            )

            // Date Selection
            Box(modifier = Modifier.weight(1.2f)) {
                OutlinedTextField(
                    value = viewModel.eventDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")),
                    onValueChange = {},
                    label = { Text("Fecha") },
                    readOnly = true,
                    leadingIcon = { Icon(Icons.Default.CalendarToday, contentDescription = null) },
                    modifier = Modifier.clickable { showDatePicker = true },
                    enabled = false, // To allow click on parent or box
                    colors = OutlinedTextFieldDefaults.colors(
                        disabledTextColor = SolennixTheme.colors.primaryText,
                        disabledBorderColor = SolennixTheme.colors.border,
                        disabledLabelColor = SolennixTheme.colors.secondaryText,
                        disabledLeadingIconColor = SolennixTheme.colors.secondaryText
                    )
                )
                // Transparent overlay to catch clicks because disabled TextField doesn't
                Box(Modifier.matchParentSize().clickable { showDatePicker = true })
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        SolennixTextField(
            value = viewModel.location,
            onValueChange = { viewModel.location = it },
            label = "Lugar del Evento",
            leadingIcon = Icons.Default.LocationOn,
            placeholder = "Nombre del salón o dirección"
        )

        Spacer(modifier = Modifier.height(16.dp))

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            SolennixTextField(
                value = viewModel.city,
                onValueChange = { viewModel.city = it },
                label = "Ciudad",
                leadingIcon = Icons.Default.LocationCity,
                modifier = Modifier.weight(1f)
            )
        }
    }

    if (showClientPicker) {
        ClientPickerSheet(
            viewModel = viewModel,
            onDismiss = { showClientPicker = false },
            onClientSelected = {
                viewModel.selectedClient = it
                showClientPicker = false
            }
        )
    }

    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            initialSelectedDateMillis = System.currentTimeMillis()
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    datePickerState.selectedDateMillis?.let {
                        viewModel.eventDate = java.time.Instant.ofEpochMilli(it)
                            .atZone(java.time.ZoneId.systemDefault()).toLocalDate()
                    }
                    showDatePicker = false
                }) { Text("Aceptar") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Cancelar") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StepProducts(viewModel: EventFormViewModel) {
    var showProductPicker by remember { mutableStateOf(false) }

    Column(modifier = Modifier.padding(24.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Productos y Menú", style = MaterialTheme.typography.headlineSmall, modifier = Modifier.weight(1f))
            IconButton(onClick = { showProductPicker = true }) {
                Icon(Icons.Default.AddCircle, contentDescription = "Añadir", tint = SolennixTheme.colors.primary)
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))

        if (viewModel.selectedProducts.isEmpty()) {
            EmptyState(
                icon = Icons.Default.RestaurantMenu,
                title = "Sin productos",
                message = "Añade platos o servicios al evento para calcular el presupuesto.",
                actionText = "Explorar Catálogo",
                onAction = { showProductPicker = true }
            )
        } else {
            LazyColumn(modifier = Modifier.fillMaxSize()) {
                items(viewModel.selectedProducts) { item ->
                    ProductSelectionItem(
                        item = item,
                        availableProducts = viewModel.availableProducts.value,
                        onQuantityChange = { viewModel.updateProductQuantity(item.productId, it) },
                        onRemove = { viewModel.removeProduct(item.productId) }
                    )
                }
            }
        }
    }

    if (showProductPicker) {
        ProductPickerSheet(
            viewModel = viewModel,
            onDismiss = { showProductPicker = false },
            onProductSelected = { product ->
                viewModel.addProduct(product, 1)
                showProductPicker = false
            }
        )
    }
}

@Composable
fun ProductSelectionItem(
    item: com.creapolis.solennix.core.model.EventProduct,
    availableProducts: List<com.creapolis.solennix.core.model.Product>,
    onQuantityChange: (Int) -> Unit,
    onRemove: () -> Unit
) {
    val product = availableProducts.find { it.id == item.productId } ?: return
    
    Card(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
        border = androidx.compose.foundation.BorderStroke(1.dp, SolennixTheme.colors.borderLight)
    ) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(modifier = Modifier.weight(1f)) {
                Text(product.name, style = MaterialTheme.typography.titleSmall)
                Text(item.unitPrice.asMXN(), style = MaterialTheme.typography.bodySmall, color = SolennixTheme.colors.primary)
            }
            
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = { onQuantityChange(item.quantity - 1) }) {
                    Icon(Icons.Default.Remove, contentDescription = "Menos", modifier = Modifier.size(18.dp))
                }
                Text(item.quantity.toString(), style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(horizontal = 4.dp))
                IconButton(onClick = { onQuantityChange(item.quantity + 1) }) {
                    Icon(Icons.Default.Add, contentDescription = "Más", modifier = Modifier.size(18.dp))
                }
            }
            
            IconButton(onClick = onRemove) {
                Icon(Icons.Default.Delete, contentDescription = "Eliminar", tint = SolennixTheme.colors.error, modifier = Modifier.size(20.dp))
            }
        }
    }
}

@Composable
fun StepExtras(viewModel: EventFormViewModel) {
    var showAddExtra by remember { mutableStateOf(false) }
    var extraDesc by remember { mutableStateOf("") }
    var extraPrice by remember { mutableStateOf("") }

    Column(modifier = Modifier.padding(24.dp)) {
        Text("Extras y Descuentos", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))

        if (showAddExtra) {
            Card(
                modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp),
                colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.surfaceAlt)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Nuevo Extra", style = MaterialTheme.typography.titleSmall)
                    Spacer(modifier = Modifier.height(8.dp))
                    SolennixTextField(value = extraDesc, onValueChange = { extraDesc = it }, label = "Descripción")
                    Spacer(modifier = Modifier.height(8.dp))
                    SolennixTextField(
                        value = extraPrice, 
                        onValueChange = { extraPrice = it }, 
                        label = "Precio", 
                        keyboardType = androidx.compose.ui.text.input.KeyboardType.Decimal
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Row {
                        TextButton(onClick = { showAddExtra = false }) { Text("Cancelar") }
                        Spacer(modifier = Modifier.weight(1f))
                        Button(onClick = {
                            val p = extraPrice.toDoubleOrNull() ?: 0.0
                            viewModel.addExtra(extraDesc, p)
                            extraDesc = ""
                            extraPrice = ""
                            showAddExtra = false
                        }) { Text("Añadir") }
                    }
                }
            }
        } else {
            PremiumButton(
                text = "Añadir Cargo Extra", 
                onClick = { showAddExtra = true },
                style = ButtonStyle.Secondary,
                icon = Icons.Default.Add
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(modifier = Modifier.weight(1f)) {
            items(viewModel.eventExtras) { extra ->
                ListItem(
                    headlineContent = { Text(extra.description) },
                    trailingContent = { 
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(extra.price.asMXN(), color = SolennixTheme.colors.primary)
                            IconButton(onClick = { viewModel.removeExtra(extra.id) }) {
                                Icon(Icons.Default.Close, contentDescription = "Quitar", tint = SolennixTheme.colors.error)
                            }
                        }
                    }
                )
                HorizontalDivider(color = SolennixTheme.colors.divider.copy(alpha = 0.5f))
            }
        }

        Spacer(modifier = Modifier.height(16.dp))
        
        Text("Descuento", style = MaterialTheme.typography.titleSmall)
        Row(modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            SolennixTextField(
                value = viewModel.discount,
                onValueChange = { viewModel.discount = it },
                label = "Valor",
                modifier = Modifier.weight(1f),
                keyboardType = androidx.compose.ui.text.input.KeyboardType.Decimal
            )
            Spacer(modifier = Modifier.width(16.dp))
            SingleChoiceSegmentedButtonRow(modifier = Modifier.weight(1f)) {
                SegmentedButton(
                    selected = viewModel.discountType == com.creapolis.solennix.core.model.DiscountType.PERCENT,
                    onClick = { viewModel.discountType = com.creapolis.solennix.core.model.DiscountType.PERCENT },
                    shape = SegmentedButtonDefaults.itemShape(index = 0, count = 2)
                ) { Text("%") }
                SegmentedButton(
                    selected = viewModel.discountType == com.creapolis.solennix.core.model.DiscountType.FIXED,
                    onClick = { viewModel.discountType = com.creapolis.solennix.core.model.DiscountType.FIXED },
                    shape = SegmentedButtonDefaults.itemShape(index = 1, count = 2)
                ) { Text("$") }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StepEquipment(viewModel: EventFormViewModel) {
    var showEquipmentPicker by remember { mutableStateOf(false) }
    val equipmentSuggestions by viewModel.equipmentSuggestions.collectAsStateWithLifecycle()
    val equipmentConflicts by viewModel.equipmentConflicts.collectAsStateWithLifecycle()

    LazyColumn(modifier = Modifier.padding(24.dp)) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Equipamiento", style = MaterialTheme.typography.headlineSmall, modifier = Modifier.weight(1f))
                IconButton(onClick = { showEquipmentPicker = true }) {
                    Icon(Icons.Default.AddCircle, contentDescription = "Añadir", tint = SolennixTheme.colors.primary)
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "Selecciona el equipo necesario para el evento",
                style = MaterialTheme.typography.bodySmall,
                color = SolennixTheme.colors.secondaryText
            )
            Spacer(modifier = Modifier.height(16.dp))
        }

        // Conflict warnings
        if (equipmentConflicts.isNotEmpty()) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp),
                    colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.warning.copy(alpha = 0.1f)),
                    border = androidx.compose.foundation.BorderStroke(1.dp, SolennixTheme.colors.warning)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Warning, null, tint = SolennixTheme.colors.warning)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Conflictos de Equipo", style = MaterialTheme.typography.titleSmall, color = SolennixTheme.colors.warning)
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                        equipmentConflicts.forEach { conflict ->
                            Text(
                                "• ${conflict.equipmentName}: En uso para ${conflict.serviceType} (${conflict.clientName ?: "otro evento"})",
                                style = MaterialTheme.typography.bodySmall,
                                color = SolennixTheme.colors.warning
                            )
                        }
                    }
                }
            }
        }

        // Suggestions
        if (equipmentSuggestions.isNotEmpty() && viewModel.selectedEquipment.isEmpty()) {
            item {
                Text("Sugerencias basadas en productos", style = MaterialTheme.typography.titleSmall)
                Spacer(modifier = Modifier.height(8.dp))
            }
            items(equipmentSuggestions.size) { index ->
                val suggestion = equipmentSuggestions[index]
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable {
                        viewModel.addEquipmentFromSuggestion(suggestion)
                    },
                    colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.surfaceAlt)
                ) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Lightbulb, null, tint = SolennixTheme.colors.primary)
                        Spacer(modifier = Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(suggestion.ingredientName, style = MaterialTheme.typography.titleSmall)
                            Text("Cantidad sugerida: ${suggestion.suggestedQuantity.toInt()} ${suggestion.unit}", style = MaterialTheme.typography.bodySmall, color = SolennixTheme.colors.secondaryText)
                        }
                        Icon(Icons.Default.Add, null, tint = SolennixTheme.colors.primary)
                    }
                }
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }

        // Selected equipment
        if (viewModel.selectedEquipment.isEmpty() && equipmentSuggestions.isEmpty()) {
            item {
                EmptyState(
                    icon = Icons.Default.Construction,
                    title = "Sin equipamiento",
                    message = "Añade el equipo necesario para el evento, como mesas, sillas, carpas, etc.",
                    actionText = "Añadir Equipo",
                    onAction = { showEquipmentPicker = true }
                )
            }
        } else {
            if (viewModel.selectedEquipment.isNotEmpty()) {
                item {
                    Text("Equipo Seleccionado", style = MaterialTheme.typography.titleSmall)
                    Spacer(modifier = Modifier.height(8.dp))
                }
            }
            items(viewModel.selectedEquipment.size) { index ->
                val equipment = viewModel.selectedEquipment[index]
                EquipmentSelectionItem(
                    equipment = equipment,
                    onQuantityChange = { viewModel.updateEquipmentQuantity(equipment.inventoryId, it) },
                    onRemove = { viewModel.removeEquipment(equipment.inventoryId) }
                )
            }
        }
    }

    if (showEquipmentPicker) {
        EquipmentPickerSheet(
            viewModel = viewModel,
            onDismiss = { showEquipmentPicker = false },
            onEquipmentSelected = { item ->
                viewModel.addEquipment(item, 1)
                showEquipmentPicker = false
            }
        )
    }
}

@Composable
fun EquipmentSelectionItem(
    equipment: com.creapolis.solennix.core.model.EventEquipment,
    onQuantityChange: (Int) -> Unit,
    onRemove: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
        border = androidx.compose.foundation.BorderStroke(1.dp, SolennixTheme.colors.borderLight)
    ) {
        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Default.Construction, null, tint = SolennixTheme.colors.primary, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(equipment.equipmentName ?: "Equipo", style = MaterialTheme.typography.titleSmall)
                Text("Stock: ${equipment.currentStock?.toInt() ?: 0} ${equipment.unit ?: ""}", style = MaterialTheme.typography.bodySmall, color = SolennixTheme.colors.secondaryText)
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = { onQuantityChange(equipment.quantity - 1) }) {
                    Icon(Icons.Default.Remove, contentDescription = "Menos", modifier = Modifier.size(18.dp))
                }
                Text(equipment.quantity.toString(), style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(horizontal = 4.dp))
                IconButton(onClick = { onQuantityChange(equipment.quantity + 1) }) {
                    Icon(Icons.Default.Add, contentDescription = "Más", modifier = Modifier.size(18.dp))
                }
            }

            IconButton(onClick = onRemove) {
                Icon(Icons.Default.Delete, contentDescription = "Eliminar", tint = SolennixTheme.colors.error, modifier = Modifier.size(20.dp))
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StepSupplies(viewModel: EventFormViewModel) {
    var showSupplyPicker by remember { mutableStateOf(false) }
    val supplySuggestions by viewModel.supplySuggestions.collectAsStateWithLifecycle()

    val stockSupplies = viewModel.selectedSupplies.filter { it.source == SupplySource.STOCK }
    val purchaseSupplies = viewModel.selectedSupplies.filter { it.source == SupplySource.PURCHASE }

    LazyColumn(modifier = Modifier.padding(24.dp)) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Insumos", style = MaterialTheme.typography.headlineSmall, modifier = Modifier.weight(1f))
                IconButton(onClick = { showSupplyPicker = true }) {
                    Icon(Icons.Default.AddCircle, contentDescription = "Añadir", tint = SolennixTheme.colors.primary)
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "Ingredientes y suministros necesarios para el evento",
                style = MaterialTheme.typography.bodySmall,
                color = SolennixTheme.colors.secondaryText
            )
            Spacer(modifier = Modifier.height(16.dp))
        }

        // Suggestions
        if (supplySuggestions.isNotEmpty() && viewModel.selectedSupplies.isEmpty()) {
            item {
                Text("Sugerencias basadas en productos y personas", style = MaterialTheme.typography.titleSmall)
                Spacer(modifier = Modifier.height(8.dp))
            }
            items(supplySuggestions.size) { index ->
                val suggestion = supplySuggestions[index]
                val hasEnoughStock = suggestion.currentStock >= suggestion.suggestedQuantity
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable {
                        viewModel.addSupplyFromSuggestion(suggestion)
                    },
                    colors = CardDefaults.cardColors(
                        containerColor = if (hasEnoughStock) SolennixTheme.colors.surfaceAlt else SolennixTheme.colors.warning.copy(alpha = 0.1f)
                    )
                ) {
                    Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            if (hasEnoughStock) Icons.Default.Inventory else Icons.Default.ShoppingCart,
                            null,
                            tint = if (hasEnoughStock) SolennixTheme.colors.primary else SolennixTheme.colors.warning
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(suggestion.ingredientName, style = MaterialTheme.typography.titleSmall)
                            Text(
                                "Necesario: ${suggestion.suggestedQuantity} ${suggestion.unit} | Stock: ${suggestion.currentStock}",
                                style = MaterialTheme.typography.bodySmall,
                                color = SolennixTheme.colors.secondaryText
                            )
                            if (!hasEnoughStock) {
                                Text(
                                    "Necesita comprar: ${suggestion.suggestedQuantity - suggestion.currentStock} ${suggestion.unit}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = SolennixTheme.colors.warning
                                )
                            }
                        }
                        Icon(Icons.Default.Add, null, tint = SolennixTheme.colors.primary)
                    }
                }
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }

        if (viewModel.selectedSupplies.isEmpty() && supplySuggestions.isEmpty()) {
            item {
                EmptyState(
                    icon = Icons.Default.Inventory2,
                    title = "Sin insumos",
                    message = "Añade los ingredientes y suministros necesarios para preparar el evento.",
                    actionText = "Añadir Insumos",
                    onAction = { showSupplyPicker = true }
                )
            }
        }

        // Stock supplies section
        if (stockSupplies.isNotEmpty()) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Inventory, null, tint = SolennixTheme.colors.success, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("De Inventario", style = MaterialTheme.typography.titleSmall, color = SolennixTheme.colors.success)
                }
                Spacer(modifier = Modifier.height(8.dp))
            }
            items(stockSupplies.size) { index ->
                val supply = stockSupplies[index]
                SupplySelectionItem(
                    supply = supply,
                    onQuantityChange = { viewModel.updateSupplyQuantity(supply.inventoryId, it) },
                    onSourceChange = { viewModel.updateSupplySource(supply.inventoryId, it) },
                    onRemove = { viewModel.removeSupply(supply.inventoryId) }
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
        }

        // Purchase supplies section
        if (purchaseSupplies.isNotEmpty()) {
            item {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.ShoppingCart, null, tint = SolennixTheme.colors.warning, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Por Comprar", style = MaterialTheme.typography.titleSmall, color = SolennixTheme.colors.warning)
                }
                Spacer(modifier = Modifier.height(8.dp))
            }
            items(purchaseSupplies.size) { index ->
                val supply = purchaseSupplies[index]
                SupplySelectionItem(
                    supply = supply,
                    onQuantityChange = { viewModel.updateSupplyQuantity(supply.inventoryId, it) },
                    onSourceChange = { viewModel.updateSupplySource(supply.inventoryId, it) },
                    onRemove = { viewModel.removeSupply(supply.inventoryId) }
                )
            }
        }

        // Notes at the bottom
        item {
            Spacer(modifier = Modifier.height(24.dp))
            SolennixTextField(
                value = viewModel.notes,
                onValueChange = { viewModel.notes = it },
                label = "Notas Adicionales",
                leadingIcon = Icons.Default.Notes,
                modifier = Modifier.heightIn(min = 100.dp)
            )
        }
    }

    if (showSupplyPicker) {
        SupplyPickerSheet(
            viewModel = viewModel,
            onDismiss = { showSupplyPicker = false },
            onSupplySelected = { item ->
                viewModel.addSupply(item, 1.0)
                showSupplyPicker = false
            }
        )
    }
}

@Composable
fun SupplySelectionItem(
    supply: com.creapolis.solennix.core.model.EventSupply,
    onQuantityChange: (Double) -> Unit,
    onSourceChange: (SupplySource) -> Unit,
    onRemove: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
        border = androidx.compose.foundation.BorderStroke(1.dp, SolennixTheme.colors.borderLight)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    if (supply.source == SupplySource.STOCK) Icons.Default.Inventory else Icons.Default.ShoppingCart,
                    null,
                    tint = if (supply.source == SupplySource.STOCK) SolennixTheme.colors.success else SolennixTheme.colors.warning,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(supply.supplyName ?: "Insumo", style = MaterialTheme.typography.titleSmall)
                    Text(
                        "Stock: ${supply.currentStock ?: 0} ${supply.unit ?: ""} | Costo: ${supply.unitCost.asMXN()}/${supply.unit ?: "u"}",
                        style = MaterialTheme.typography.bodySmall,
                        color = SolennixTheme.colors.secondaryText
                    )
                }
                IconButton(onClick = onRemove) {
                    Icon(Icons.Default.Delete, contentDescription = "Eliminar", tint = SolennixTheme.colors.error, modifier = Modifier.size(20.dp))
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Quantity controls
                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.weight(1f)) {
                    IconButton(onClick = { onQuantityChange(supply.quantity - 1) }) {
                        Icon(Icons.Default.Remove, contentDescription = "Menos", modifier = Modifier.size(18.dp))
                    }
                    Text("${supply.quantity}", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(horizontal = 4.dp))
                    Text(supply.unit ?: "", style = MaterialTheme.typography.bodySmall, color = SolennixTheme.colors.secondaryText)
                    IconButton(onClick = { onQuantityChange(supply.quantity + 1) }) {
                        Icon(Icons.Default.Add, contentDescription = "Más", modifier = Modifier.size(18.dp))
                    }
                }
                // Source toggle
                SingleChoiceSegmentedButtonRow {
                    SegmentedButton(
                        selected = supply.source == SupplySource.STOCK,
                        onClick = { onSourceChange(SupplySource.STOCK) },
                        shape = SegmentedButtonDefaults.itemShape(index = 0, count = 2)
                    ) {
                        Icon(Icons.Default.Inventory, null, modifier = Modifier.size(16.dp))
                    }
                    SegmentedButton(
                        selected = supply.source == SupplySource.PURCHASE,
                        onClick = { onSourceChange(SupplySource.PURCHASE) },
                        shape = SegmentedButtonDefaults.itemShape(index = 1, count = 2)
                    ) {
                        Icon(Icons.Default.ShoppingCart, null, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}

@Composable
fun StepSummary(viewModel: EventFormViewModel) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text("Resumen del Evento", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Text(viewModel.serviceType.ifBlank { "Nuevo Evento" }, style = MaterialTheme.typography.titleLarge)
                Text(viewModel.selectedClient?.name ?: "Sin cliente asignado", color = SolennixTheme.colors.secondaryText)
                Spacer(modifier = Modifier.height(16.dp))
                Row {
                    Icon(Icons.Default.CalendarToday, null, Modifier.size(16.dp), tint = SolennixTheme.colors.tertiaryText)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(viewModel.eventDate.toString(), style = MaterialTheme.typography.bodySmall)
                }
            }
        }
        
        Spacer(modifier = Modifier.height(24.dp))
        
        SummaryRow("Subtotal", viewModel.subtotal.asMXN())
        if (viewModel.discount.toDoubleOrNull() ?: 0.0 > 0) {
            val label = if (viewModel.discountType == com.creapolis.solennix.core.model.DiscountType.PERCENT) "Descuento (${viewModel.discount}%)" else "Descuento"
            val discountValue = if (viewModel.discountType == com.creapolis.solennix.core.model.DiscountType.PERCENT) 
                viewModel.subtotal * (viewModel.discount.toDouble() / 100)
            else viewModel.discount.toDouble()
            
            SummaryRow(label, "-${discountValue.asMXN()}", color = SolennixTheme.colors.success)
        }
        
        HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))
        SummaryRow("Total a Cobrar", viewModel.total.asMXN(), isTotal = true)
        
        Spacer(modifier = Modifier.height(32.dp))
        Surface(
            color = SolennixTheme.colors.info.copy(alpha = 0.1f),
            shape = MaterialTheme.shapes.small,
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Info, null, tint = SolennixTheme.colors.info)
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    "Al finalizar, se creará el evento en estado 'Cotizado'. Podrás generar el PDF de presupuesto desde el detalle.",
                    style = MaterialTheme.typography.bodySmall,
                    color = SolennixTheme.colors.info
                )
            }
        }
    }
}

@Composable
private fun SummaryRow(label: String, value: String, isTotal: Boolean = false, color: Color = SolennixTheme.colors.primaryText) {
    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(
            text = label,
            style = if (isTotal) MaterialTheme.typography.titleLarge else MaterialTheme.typography.bodyLarge,
            fontWeight = if (isTotal) FontWeight.Bold else null
        )
        Text(
            text = value,
            style = if (isTotal) MaterialTheme.typography.titleLarge else MaterialTheme.typography.bodyLarge,
            color = if (isTotal) SolennixTheme.colors.primary else color,
            fontWeight = if (isTotal) FontWeight.Bold else null
        )
    }
}

// Picker Bottom Sheets

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ClientPickerSheet(
    viewModel: EventFormViewModel,
    onDismiss: () -> Unit,
    onClientSelected: (Client) -> Unit
) {
    val clients by viewModel.filteredClients.collectAsStateWithLifecycle()
    val query by viewModel.clientSearchQuery.collectAsStateWithLifecycle()

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.fillMaxWidth().padding(16.dp).heightIn(max = 500.dp)) {
            Text("Seleccionar Cliente", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.height(16.dp))
            OutlinedTextField(
                value = query,
                onValueChange = { viewModel.onClientSearchQueryChange(it) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("Buscar por nombre...") },
                leadingIcon = { Icon(Icons.Default.Search, null) },
                shape = MaterialTheme.shapes.medium,
                singleLine = true
            )
            Spacer(modifier = Modifier.height(16.dp))
            LazyColumn(modifier = Modifier.fillMaxWidth()) {
                items(clients) { client ->
                    ListItem(
                        headlineContent = { Text(client.name) },
                        supportingContent = { Text(client.phone) },
                        leadingContent = { Avatar(name = client.name, size = 40.dp) },
                        modifier = Modifier.clickable { onClientSelected(client) }
                    )
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductPickerSheet(
    viewModel: EventFormViewModel,
    onDismiss: () -> Unit,
    onProductSelected: (Product) -> Unit
) {
    val products by viewModel.availableProducts.collectAsStateWithLifecycle()

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.fillMaxWidth().padding(16.dp).heightIn(max = 500.dp)) {
            Text("Catálogo de Productos", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.height(16.dp))
            LazyColumn(modifier = Modifier.fillMaxWidth()) {
                items(products) { product ->
                    ListItem(
                        headlineContent = { Text(product.name) },
                        supportingContent = { Text(product.category) },
                        trailingContent = { Text(product.basePrice.asMXN(), color = SolennixTheme.colors.primary, fontWeight = FontWeight.Bold) },
                        modifier = Modifier.clickable { onProductSelected(product) }
                    )
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EquipmentPickerSheet(
    viewModel: EventFormViewModel,
    onDismiss: () -> Unit,
    onEquipmentSelected: (InventoryItem) -> Unit
) {
    val equipment by viewModel.availableEquipment.collectAsStateWithLifecycle()

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.fillMaxWidth().padding(16.dp).heightIn(max = 500.dp)) {
            Text("Equipamiento Disponible", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.height(16.dp))
            if (equipment.isEmpty()) {
                Box(modifier = Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                    Text("No hay equipamiento registrado", color = SolennixTheme.colors.secondaryText)
                }
            } else {
                LazyColumn(modifier = Modifier.fillMaxWidth()) {
                    items(equipment) { item ->
                        ListItem(
                            headlineContent = { Text(item.ingredientName) },
                            supportingContent = { Text("Stock: ${item.currentStock.toInt()} ${item.unit}") },
                            leadingContent = {
                                Icon(Icons.Default.Construction, null, tint = SolennixTheme.colors.primary)
                            },
                            modifier = Modifier.clickable { onEquipmentSelected(item) }
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SupplyPickerSheet(
    viewModel: EventFormViewModel,
    onDismiss: () -> Unit,
    onSupplySelected: (InventoryItem) -> Unit
) {
    val supplies by viewModel.availableSupplies.collectAsStateWithLifecycle()

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(modifier = Modifier.fillMaxWidth().padding(16.dp).heightIn(max = 500.dp)) {
            Text("Insumos Disponibles", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.height(16.dp))
            if (supplies.isEmpty()) {
                Box(modifier = Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                    Text("No hay insumos registrados", color = SolennixTheme.colors.secondaryText)
                }
            } else {
                LazyColumn(modifier = Modifier.fillMaxWidth()) {
                    items(supplies) { item ->
                        val hasLowStock = item.currentStock < item.minimumStock
                        ListItem(
                            headlineContent = { Text(item.ingredientName) },
                            supportingContent = {
                                Text(
                                    "Stock: ${item.currentStock} ${item.unit} | Costo: ${(item.unitCost ?: 0.0).asMXN()}",
                                    color = if (hasLowStock) SolennixTheme.colors.warning else SolennixTheme.colors.secondaryText
                                )
                            },
                            leadingContent = {
                                Icon(
                                    if (hasLowStock) Icons.Default.Warning else Icons.Default.Inventory,
                                    null,
                                    tint = if (hasLowStock) SolennixTheme.colors.warning else SolennixTheme.colors.primary
                                )
                            },
                            modifier = Modifier.clickable { onSupplySelected(item) }
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}
