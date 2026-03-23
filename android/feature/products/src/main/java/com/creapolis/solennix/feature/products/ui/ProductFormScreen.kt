package com.creapolis.solennix.feature.products.ui

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.Category
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import com.creapolis.solennix.core.network.UrlResolver
import com.creapolis.solennix.core.designsystem.component.PremiumButton
import com.creapolis.solennix.core.designsystem.component.SolennixTextField
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.feature.products.viewmodel.ProductFormViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductFormScreen(
    viewModel: ProductFormViewModel,
    onNavigateBack: () -> Unit
) {
    val scrollState = rememberScrollState()
    val context = LocalContext.current

    LaunchedEffect(viewModel.saveSuccess) {
        if (viewModel.saveSuccess) {
            onNavigateBack()
        }
    }

    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let { viewModel.uploadImage(context, it) }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Producto") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        if (viewModel.isLoading) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .verticalScroll(scrollState)
                    .padding(16.dp)
            ) {
                // Image section
                Text(
                    text = "Imagen del Producto",
                    style = MaterialTheme.typography.labelLarge,
                    color = SolennixTheme.colors.primary,
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = MaterialTheme.shapes.medium,
                    color = SolennixTheme.colors.card,
                    tonalElevation = 1.dp
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Image preview
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(180.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(SolennixTheme.colors.surfaceGrouped)
                                .clickable(enabled = !viewModel.isUploadingImage) {
                                    imagePickerLauncher.launch("image/*")
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            if (viewModel.imageUrl.isNotBlank()) {
                                AsyncImage(
                                    model = ImageRequest.Builder(context)
                                        .data(UrlResolver.resolve(viewModel.imageUrl))
                                        .crossfade(true)
                                        .build(),
                                    contentDescription = "Imagen del producto",
                                    modifier = Modifier.fillMaxSize(),
                                    contentScale = ContentScale.Crop
                                )
                            } else {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Icon(
                                        Icons.Default.Image,
                                        contentDescription = null,
                                        modifier = Modifier.size(48.dp),
                                        tint = SolennixTheme.colors.secondaryText
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text(
                                        text = "Toca para seleccionar imagen",
                                        style = MaterialTheme.typography.bodySmall,
                                        color = SolennixTheme.colors.secondaryText
                                    )
                                }
                            }

                            // Upload overlay
                            if (viewModel.isUploadingImage) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .background(
                                            SolennixTheme.colors.surfaceGrouped.copy(alpha = 0.7f)
                                        ),
                                    contentAlignment = Alignment.Center
                                ) {
                                    CircularProgressIndicator(
                                        color = SolennixTheme.colors.primary
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        OutlinedButton(
                            onClick = { imagePickerLauncher.launch("image/*") },
                            enabled = !viewModel.isUploadingImage
                        ) {
                            if (viewModel.isUploadingImage) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(16.dp),
                                    strokeWidth = 2.dp,
                                    color = SolennixTheme.colors.primary
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Subiendo...")
                            } else {
                                Icon(
                                    Icons.Default.PhotoCamera,
                                    contentDescription = null,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    if (viewModel.imageUrl.isNotBlank()) "Cambiar Imagen"
                                    else "Seleccionar Imagen"
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))

                SolennixTextField(
                    value = viewModel.name,
                    onValueChange = { viewModel.name = it },
                    label = "Nombre *",
                    leadingIcon = Icons.Default.ShoppingCart
                )
                Spacer(modifier = Modifier.height(16.dp))

                SolennixTextField(
                    value = viewModel.category,
                    onValueChange = { viewModel.category = it },
                    label = "Categoria *",
                    leadingIcon = Icons.Default.Category
                )
                Spacer(modifier = Modifier.height(16.dp))

                SolennixTextField(
                    value = viewModel.basePrice,
                    onValueChange = { viewModel.basePrice = it },
                    label = "Precio Base *",
                    leadingIcon = Icons.Default.AttachMoney,
                    keyboardType = KeyboardType.Decimal
                )
                Spacer(modifier = Modifier.height(16.dp))

                // Active toggle
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Producto activo",
                        style = MaterialTheme.typography.bodyLarge,
                        color = SolennixTheme.colors.primaryText
                    )
                    Switch(
                        checked = viewModel.isActive,
                        onCheckedChange = { viewModel.isActive = it },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = SolennixTheme.colors.primary,
                            checkedTrackColor = SolennixTheme.colors.primaryLight
                        )
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))

                // Recipe / preparation notes
                OutlinedTextField(
                    value = viewModel.recipe,
                    onValueChange = { viewModel.recipe = it },
                    modifier = Modifier.fillMaxWidth(),
                    label = { Text("Receta / Notas de preparacion") },
                    placeholder = { Text("Instrucciones de preparacion, ingredientes, etc.") },
                    minLines = 3,
                    maxLines = 6,
                    shape = MaterialTheme.shapes.small,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = SolennixTheme.colors.primary,
                        focusedLabelColor = SolennixTheme.colors.primary,
                        cursorColor = SolennixTheme.colors.primary
                    )
                )
                Spacer(modifier = Modifier.height(32.dp))

                if (viewModel.errorMessage != null) {
                    Text(
                        text = viewModel.errorMessage.orEmpty(),
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodySmall,
                        modifier = Modifier.padding(bottom = 16.dp)
                    )
                }

                PremiumButton(
                    text = "Guardar",
                    onClick = { viewModel.saveProduct() },
                    isLoading = viewModel.isSaving,
                    enabled = viewModel.isFormValid
                )
                Spacer(modifier = Modifier.height(32.dp))
            }
        }
    }
}
