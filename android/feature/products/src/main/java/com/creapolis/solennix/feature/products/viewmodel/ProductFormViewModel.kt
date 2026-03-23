package com.creapolis.solennix.feature.products.viewmodel

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.plan.LimitCheckResult
import com.creapolis.solennix.core.data.plan.PlanLimitsManager
import com.creapolis.solennix.core.data.repository.ProductRepository
import com.creapolis.solennix.core.model.Plan
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.AuthManager
import com.creapolis.solennix.core.network.Endpoints
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class ProductFormViewModel @Inject constructor(
    private val productRepository: ProductRepository,
    private val apiService: ApiService,
    private val planLimitsManager: PlanLimitsManager,
    private val authManager: AuthManager,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val productId: String? = savedStateHandle["productId"]

    // Plan limit check
    var limitCheckResult by mutableStateOf<LimitCheckResult?>(null)
        private set
    val isLimitReached: Boolean
        get() = limitCheckResult is LimitCheckResult.LimitReached

    var name by mutableStateOf("")
    var category by mutableStateOf("")
    var basePrice by mutableStateOf("")
    var imageUrl by mutableStateOf("")
    var isActive by mutableStateOf(true)
    var recipe by mutableStateOf("")

    var isLoading by mutableStateOf(false)
    var isSaving by mutableStateOf(false)
    var isUploadingImage by mutableStateOf(false)
    var saveSuccess by mutableStateOf(false)
    var errorMessage by mutableStateOf<String?>(null)

    val isFormValid: Boolean
        get() = name.isNotBlank() && category.isNotBlank() && basePrice.toDoubleOrNull() != null

    init {
        if (productId != null) {
            loadProduct(productId)
        } else {
            // Only check plan limits when creating a new product
            viewModelScope.launch {
                val plan = authManager.currentUser.value?.plan ?: Plan.BASIC
                limitCheckResult = planLimitsManager.canCreateProduct(plan)
            }
        }
    }

    private fun loadProduct(id: String) {
        viewModelScope.launch {
            isLoading = true
            try {
                val product = productRepository.getProduct(id)
                if (product != null) {
                    name = product.name
                    category = product.category
                    basePrice = product.basePrice.toString()
                    imageUrl = product.imageUrl ?: ""
                    isActive = product.isActive
                    recipe = product.recipe ?: ""
                }
            } catch (e: Exception) {
                errorMessage = "Error al cargar producto: ${e.message}"
            } finally {
                isLoading = false
            }
        }
    }

    fun saveProduct() {
        if (!isFormValid) return

        viewModelScope.launch {
            isSaving = true
            errorMessage = null
            try {
                val product = Product(
                    id = productId ?: UUID.randomUUID().toString(),
                    userId = "", // Managed by backend
                    name = name,
                    category = category,
                    basePrice = basePrice.toDoubleOrNull() ?: 0.0,
                    recipe = recipe.takeIf { it.isNotBlank() },
                    imageUrl = imageUrl.takeIf { it.isNotBlank() },
                    isActive = isActive,
                    createdAt = "", // Handled by backend
                    updatedAt = ""  // Handled by backend
                )

                if (productId != null) {
                    productRepository.updateProduct(product)
                } else {
                    productRepository.createProduct(product)
                }
                saveSuccess = true
            } catch (e: Exception) {
                errorMessage = "Error al guardar producto: ${e.message}"
            } finally {
                isSaving = false
            }
        }
    }

    fun uploadImage(context: Context, uri: Uri) {
        viewModelScope.launch {
            isUploadingImage = true
            errorMessage = null
            try {
                val contentResolver = context.contentResolver
                val mimeType = contentResolver.getType(uri) ?: "image/jpeg"
                val fileName = getFileName(context, uri) ?: "product_image.jpg"
                val inputStream = contentResolver.openInputStream(uri)
                val bytes = inputStream?.readBytes()
                inputStream?.close()

                if (bytes != null) {
                    val response = apiService.upload(
                        Endpoints.UPLOAD_IMAGE,
                        bytes,
                        fileName,
                        mimeType
                    )
                    imageUrl = response.url
                } else {
                    errorMessage = "No se pudo leer la imagen seleccionada"
                }
            } catch (e: Exception) {
                errorMessage = "Error al subir imagen: ${e.message}"
            } finally {
                isUploadingImage = false
            }
        }
    }

    private fun getFileName(context: Context, uri: Uri): String? {
        var name: String? = null
        val cursor = context.contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) {
                    name = it.getString(index)
                }
            }
        }
        return name
    }
}
