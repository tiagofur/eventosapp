package com.creapolis.solennix.feature.clients.ui

import android.content.Intent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.model.DiscountType
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.model.extensions.asMXN
import com.creapolis.solennix.feature.clients.viewmodel.QuickQuoteViewModel
import com.creapolis.solennix.feature.clients.viewmodel.QuoteExtra
import com.creapolis.solennix.feature.clients.viewmodel.QuoteItem

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuickQuoteScreen(
    viewModel: QuickQuoteViewModel,
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scrollState = rememberScrollState()

    // Share PDF when generated
    LaunchedEffect(uiState.generatedPdfFile) {
        uiState.generatedPdfFile?.let { file ->
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )
            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                type = "application/pdf"
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            context.startActivity(Intent.createChooser(shareIntent, "Compartir Cotizacion"))
            viewModel.clearPdfFile()
        }
    }

    // Show error snackbar
    val snackbarHostState = remember { SnackbarHostState() }
    LaunchedEffect(uiState.errorMessage) {
        uiState.errorMessage?.let {
            snackbarHostState.showSnackbar(it)
            viewModel.clearError()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Cotizacion Rapida") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Volver")
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        if (uiState.isLoading) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = SolennixTheme.colors.primary)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(scrollState)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Client info (if available)
                if (uiState.client != null) {
                    val client = uiState.client!!
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                Icons.Default.Person,
                                contentDescription = null,
                                tint = SolennixTheme.colors.primary
                            )
                            Spacer(Modifier.width(12.dp))
                            Column {
                                Text(
                                    text = client.name,
                                    style = MaterialTheme.typography.titleSmall,
                                    color = SolennixTheme.colors.primaryText
                                )
                                Text(
                                    text = client.phone,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = SolennixTheme.colors.secondaryText
                                )
                            }
                        }
                    }
                }

                // Number of people
                OutlinedTextField(
                    value = uiState.numPeople,
                    onValueChange = viewModel::updateNumPeople,
                    label = { Text("Numero de Personas") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.fillMaxWidth(),
                    leadingIcon = { Icon(Icons.Default.Group, contentDescription = null) }
                )

                // Products section
                SectionHeader(
                    title = "Productos",
                    onAddClick = viewModel::addItem
                )

                uiState.selectedItems.forEach { item ->
                    ProductItemCard(
                        item = item,
                        products = uiState.products,
                        onProductSelected = { product -> viewModel.updateItemProduct(item.id, product) },
                        onQuantityChanged = { qty -> viewModel.updateItemQuantity(item.id, qty) },
                        onPriceChanged = { price -> viewModel.updateItemPrice(item.id, price) },
                        onRemove = { viewModel.removeItem(item.id) },
                        canRemove = uiState.selectedItems.size > 1
                    )
                }

                // Extras section
                SectionHeader(
                    title = "Extras",
                    onAddClick = viewModel::addExtra
                )

                if (uiState.extras.isEmpty()) {
                    Text(
                        text = "Sin extras agregados",
                        style = MaterialTheme.typography.bodySmall,
                        color = SolennixTheme.colors.secondaryText,
                        modifier = Modifier.padding(start = 4.dp)
                    )
                }

                uiState.extras.forEach { extra ->
                    ExtraItemCard(
                        extra = extra,
                        onDescriptionChanged = { desc -> viewModel.updateExtraDescription(extra.id, desc) },
                        onPriceChanged = { price -> viewModel.updateExtraPrice(extra.id, price) },
                        onRemove = { viewModel.removeExtra(extra.id) }
                    )
                }

                // Invoice toggle
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Incluir factura (IVA)",
                                style = MaterialTheme.typography.bodyLarge,
                                color = SolennixTheme.colors.primaryText
                            )
                            Switch(
                                checked = uiState.requiresInvoice,
                                onCheckedChange = viewModel::updateRequiresInvoice,
                                colors = SwitchDefaults.colors(
                                    checkedThumbColor = SolennixTheme.colors.primary,
                                    checkedTrackColor = SolennixTheme.colors.primaryLight
                                )
                            )
                        }

                        if (uiState.requiresInvoice) {
                            Spacer(Modifier.height(8.dp))
                            OutlinedTextField(
                                value = uiState.taxRate,
                                onValueChange = viewModel::updateTaxRate,
                                label = { Text("Tasa de IVA (%)") },
                                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }
                }

                // Discount section
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Descuento",
                            style = MaterialTheme.typography.titleSmall,
                            color = SolennixTheme.colors.primaryText
                        )
                        Spacer(Modifier.height(8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            FilterChip(
                                selected = uiState.discountType == DiscountType.PERCENT,
                                onClick = { viewModel.updateDiscountType(DiscountType.PERCENT) },
                                label = { Text("Porcentaje") },
                                modifier = Modifier.weight(1f)
                            )
                            FilterChip(
                                selected = uiState.discountType == DiscountType.FIXED,
                                onClick = { viewModel.updateDiscountType(DiscountType.FIXED) },
                                label = { Text("Monto fijo") },
                                modifier = Modifier.weight(1f)
                            )
                        }

                        Spacer(Modifier.height(8.dp))

                        OutlinedTextField(
                            value = uiState.discount,
                            onValueChange = viewModel::updateDiscount,
                            label = {
                                Text(
                                    if (uiState.discountType == DiscountType.PERCENT) "Descuento (%)"
                                    else "Descuento ($)"
                                )
                            },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }

                // Financial summary
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card),
                    shape = MaterialTheme.shapes.large
                ) {
                    Column(modifier = Modifier.padding(20.dp)) {
                        Text(
                            text = "Resumen",
                            style = MaterialTheme.typography.titleMedium,
                            color = SolennixTheme.colors.primaryText
                        )
                        Spacer(Modifier.height(12.dp))

                        SummaryRow("Subtotal", uiState.subtotal.asMXN())

                        if (uiState.discountAmount > 0) {
                            SummaryRow(
                                label = if (uiState.discountType == DiscountType.PERCENT) {
                                    "Descuento (${uiState.discount}%)"
                                } else {
                                    "Descuento"
                                },
                                value = "-${uiState.discountAmount.asMXN()}"
                            )
                        }

                        if (uiState.requiresInvoice && uiState.taxAmount > 0) {
                            SummaryRow("IVA (${uiState.taxRate}%)", uiState.taxAmount.asMXN())
                        }

                        HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "Total",
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = SolennixTheme.colors.primaryText
                            )
                            Text(
                                text = uiState.total.asMXN(),
                                style = MaterialTheme.typography.titleLarge,
                                fontWeight = FontWeight.Bold,
                                color = SolennixTheme.colors.primary
                            )
                        }
                    }
                }

                // Generate PDF button
                Button(
                    onClick = { viewModel.generatePdf(context) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = SolennixTheme.colors.primary
                    ),
                    enabled = !uiState.isGeneratingPdf
                ) {
                    if (uiState.isGeneratingPdf) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(24.dp),
                            color = MaterialTheme.colorScheme.onPrimary
                        )
                    } else {
                        Icon(Icons.Default.PictureAsPdf, contentDescription = null)
                        Spacer(Modifier.width(8.dp))
                        Text("Generar Cotizacion", style = MaterialTheme.typography.titleMedium)
                    }
                }

                Spacer(Modifier.height(32.dp))
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String, onAddClick: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            color = SolennixTheme.colors.primaryText
        )
        IconButton(onClick = onAddClick) {
            Icon(
                Icons.Default.AddCircle,
                contentDescription = "Agregar $title",
                tint = SolennixTheme.colors.primary
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ProductItemCard(
    item: QuoteItem,
    products: List<Product>,
    onProductSelected: (Product) -> Unit,
    onQuantityChanged: (String) -> Unit,
    onPriceChanged: (String) -> Unit,
    onRemove: () -> Unit,
    canRemove: Boolean
) {
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Product dropdown
                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { expanded = !expanded },
                    modifier = Modifier.weight(1f)
                ) {
                    OutlinedTextField(
                        value = item.productName.ifEmpty { "Seleccionar producto" },
                        onValueChange = {},
                        readOnly = true,
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                        modifier = Modifier.menuAnchor(),
                        textStyle = MaterialTheme.typography.bodyMedium
                    )
                    ExposedDropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        products.forEach { product ->
                            DropdownMenuItem(
                                text = {
                                    Column {
                                        Text(product.name, style = MaterialTheme.typography.bodyMedium)
                                        Text(
                                            product.basePrice.asMXN(),
                                            style = MaterialTheme.typography.bodySmall,
                                            color = SolennixTheme.colors.secondaryText
                                        )
                                    }
                                },
                                onClick = {
                                    onProductSelected(product)
                                    expanded = false
                                }
                            )
                        }
                    }
                }

                if (canRemove) {
                    IconButton(onClick = onRemove) {
                        Icon(
                            Icons.Default.RemoveCircle,
                            contentDescription = "Eliminar",
                            tint = SolennixTheme.colors.error
                        )
                    }
                }
            }

            Spacer(Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedTextField(
                    value = item.quantity.toString(),
                    onValueChange = onQuantityChanged,
                    label = { Text("Cant.") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier.weight(1f)
                )
                OutlinedTextField(
                    value = if (item.unitPrice > 0) item.unitPrice.toString() else "",
                    onValueChange = onPriceChanged,
                    label = { Text("Precio Unit.") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                    modifier = Modifier.weight(1.5f)
                )
                Column(
                    modifier = Modifier.weight(1f).padding(top = 8.dp),
                    horizontalAlignment = Alignment.End
                ) {
                    Text(
                        text = "Subtotal",
                        style = MaterialTheme.typography.labelSmall,
                        color = SolennixTheme.colors.secondaryText
                    )
                    Text(
                        text = item.subtotal.asMXN(),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = SolennixTheme.colors.primary
                    )
                }
            }
        }
    }
}

@Composable
private fun ExtraItemCard(
    extra: QuoteExtra,
    onDescriptionChanged: (String) -> Unit,
    onPriceChanged: (String) -> Unit,
    onRemove: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = extra.description,
                    onValueChange = onDescriptionChanged,
                    label = { Text("Descripcion") },
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = onRemove) {
                    Icon(
                        Icons.Default.RemoveCircle,
                        contentDescription = "Eliminar",
                        tint = SolennixTheme.colors.error
                    )
                }
            }
            Spacer(Modifier.height(8.dp))
            OutlinedTextField(
                value = if (extra.price > 0) extra.price.toString() else "",
                onValueChange = onPriceChanged,
                label = { Text("Precio") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

@Composable
private fun SummaryRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = SolennixTheme.colors.secondaryText
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = SolennixTheme.colors.primaryText
        )
    }
}
