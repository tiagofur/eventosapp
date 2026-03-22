package com.creapolis.solennix.feature.clients.viewmodel

import android.content.Context
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.ProductRepository
import com.creapolis.solennix.core.model.Client
import com.creapolis.solennix.core.model.DiscountType
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.core.network.AuthManager
import com.creapolis.solennix.feature.clients.pdf.QuickQuotePdfGenerator
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.io.File
import java.util.UUID
import javax.inject.Inject

data class QuoteItem(
    val id: String = UUID.randomUUID().toString(),
    val productId: String = "",
    val productName: String = "",
    val quantity: Int = 1,
    val unitPrice: Double = 0.0
) {
    val subtotal: Double get() = quantity * unitPrice
}

data class QuoteExtra(
    val id: String = UUID.randomUUID().toString(),
    val description: String = "",
    val price: Double = 0.0
)

data class QuickQuoteUiState(
    val products: List<Product> = emptyList(),
    val client: Client? = null,
    val selectedItems: List<QuoteItem> = listOf(QuoteItem()),
    val extras: List<QuoteExtra> = emptyList(),
    val numPeople: String = "",
    val requiresInvoice: Boolean = false,
    val taxRate: String = "16",
    val discount: String = "",
    val discountType: DiscountType = DiscountType.PERCENT,
    val isLoading: Boolean = false,
    val isGeneratingPdf: Boolean = false,
    val errorMessage: String? = null,
    val generatedPdfFile: File? = null
) {
    val subtotal: Double
        get() = selectedItems.sumOf { it.subtotal } + extras.sumOf { it.price }

    val discountAmount: Double
        get() {
            val discountValue = discount.toDoubleOrNull() ?: 0.0
            return when (discountType) {
                DiscountType.PERCENT -> subtotal * discountValue / 100.0
                DiscountType.FIXED -> discountValue
            }
        }

    val taxAmount: Double
        get() {
            if (!requiresInvoice) return 0.0
            val rate = taxRate.toDoubleOrNull() ?: 0.0
            return (subtotal - discountAmount) * rate / 100.0
        }

    val total: Double
        get() = subtotal - discountAmount + taxAmount
}

@HiltViewModel
class QuickQuoteViewModel @Inject constructor(
    private val productRepository: ProductRepository,
    private val clientRepository: ClientRepository,
    private val authManager: AuthManager,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val clientId: String? = savedStateHandle["clientId"]

    private val _uiState = MutableStateFlow(QuickQuoteUiState(isLoading = true))
    val uiState: StateFlow<QuickQuoteUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            try {
                // Sync products from network first
                try {
                    productRepository.syncProducts()
                } catch (_: Exception) {
                    // Use cached data if sync fails
                }

                val products = productRepository.getProducts().first()
                val client = clientId?.let { clientRepository.getClient(it) }

                _uiState.update {
                    it.copy(
                        products = products.filter { p -> p.isActive },
                        client = client,
                        isLoading = false
                    )
                }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        errorMessage = "Error al cargar productos: ${e.message}",
                        isLoading = false
                    )
                }
            }
        }
    }

    fun updateNumPeople(value: String) {
        _uiState.update { it.copy(numPeople = value) }
    }

    fun addItem() {
        _uiState.update { state ->
            state.copy(selectedItems = state.selectedItems + QuoteItem())
        }
    }

    fun removeItem(itemId: String) {
        _uiState.update { state ->
            val items = state.selectedItems.filter { it.id != itemId }
            state.copy(selectedItems = items.ifEmpty { listOf(QuoteItem()) })
        }
    }

    fun updateItemProduct(itemId: String, product: Product) {
        _uiState.update { state ->
            state.copy(
                selectedItems = state.selectedItems.map { item ->
                    if (item.id == itemId) {
                        item.copy(
                            productId = product.id,
                            productName = product.name,
                            unitPrice = product.basePrice
                        )
                    } else item
                }
            )
        }
    }

    fun updateItemQuantity(itemId: String, quantity: String) {
        val qty = quantity.toIntOrNull() ?: return
        if (qty < 1) return
        _uiState.update { state ->
            state.copy(
                selectedItems = state.selectedItems.map { item ->
                    if (item.id == itemId) item.copy(quantity = qty) else item
                }
            )
        }
    }

    fun updateItemPrice(itemId: String, price: String) {
        val p = price.toDoubleOrNull() ?: return
        if (p < 0) return
        _uiState.update { state ->
            state.copy(
                selectedItems = state.selectedItems.map { item ->
                    if (item.id == itemId) item.copy(unitPrice = p) else item
                }
            )
        }
    }

    fun addExtra() {
        _uiState.update { state ->
            state.copy(extras = state.extras + QuoteExtra())
        }
    }

    fun removeExtra(extraId: String) {
        _uiState.update { state ->
            state.copy(extras = state.extras.filter { it.id != extraId })
        }
    }

    fun updateExtraDescription(extraId: String, description: String) {
        _uiState.update { state ->
            state.copy(
                extras = state.extras.map { extra ->
                    if (extra.id == extraId) extra.copy(description = description) else extra
                }
            )
        }
    }

    fun updateExtraPrice(extraId: String, price: String) {
        val p = price.toDoubleOrNull() ?: return
        _uiState.update { state ->
            state.copy(
                extras = state.extras.map { extra ->
                    if (extra.id == extraId) extra.copy(price = p) else extra
                }
            )
        }
    }

    fun updateRequiresInvoice(value: Boolean) {
        _uiState.update { it.copy(requiresInvoice = value) }
    }

    fun updateTaxRate(value: String) {
        _uiState.update { it.copy(taxRate = value) }
    }

    fun updateDiscount(value: String) {
        _uiState.update { it.copy(discount = value) }
    }

    fun updateDiscountType(type: DiscountType) {
        _uiState.update { it.copy(discountType = type) }
    }

    fun clearPdfFile() {
        _uiState.update { it.copy(generatedPdfFile = null) }
    }

    fun clearError() {
        _uiState.update { it.copy(errorMessage = null) }
    }

    fun generatePdf(context: Context) {
        val state = _uiState.value
        val validItems = state.selectedItems.filter { it.productId.isNotEmpty() && it.quantity > 0 }

        if (validItems.isEmpty()) {
            _uiState.update { it.copy(errorMessage = "Agrega al menos un producto a la cotizacion") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isGeneratingPdf = true) }
            try {
                val user = authManager.currentUser.value
                val file = QuickQuotePdfGenerator.generate(
                    context = context,
                    client = state.client,
                    items = validItems,
                    extras = state.extras.filter { it.description.isNotBlank() },
                    numPeople = state.numPeople.toIntOrNull(),
                    subtotal = state.subtotal,
                    discountAmount = state.discountAmount,
                    discountType = state.discountType,
                    discountValue = state.discount.toDoubleOrNull() ?: 0.0,
                    requiresInvoice = state.requiresInvoice,
                    taxRate = state.taxRate.toDoubleOrNull() ?: 0.0,
                    taxAmount = state.taxAmount,
                    total = state.total,
                    user = user
                )
                _uiState.update { it.copy(generatedPdfFile = file, isGeneratingPdf = false) }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        errorMessage = "Error al generar PDF: ${e.message}",
                        isGeneratingPdf = false
                    )
                }
            }
        }
    }
}
