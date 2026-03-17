package com.creapolis.solennix.feature.products.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ProductRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ProductFormViewModel @Inject constructor(
    private val productRepository: ProductRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val productId: String? = savedStateHandle["productId"]

    var name by mutableStateOf("")
    var category by mutableStateOf("")
    var basePrice by mutableStateOf("")
    var imageUrl by mutableStateOf("")

    var isLoading by mutableStateOf(false)
    var isSaving by mutableStateOf(false)
    var saveSuccess by mutableStateOf(false)
    var errorMessage by mutableStateOf<String?>(null)

    val isFormValid: Boolean
        get() = name.isNotBlank() && category.isNotBlank() && basePrice.toDoubleOrNull() != null

    init {
        if (productId != null) {
            loadProduct(productId)
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
                // In a real scenario, we'd map this back to Product and use repository.
                // productRepository.createProduct(...)
                saveSuccess = true
            } catch (e: Exception) {
                errorMessage = "Error al guardar producto: ${e.message}"
            } finally {
                isSaving = false
            }
        }
    }
}
