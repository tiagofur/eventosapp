package com.creapolis.solennix.feature.products.viewmodel

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.ProductRepository
import com.creapolis.solennix.core.model.Product
import com.creapolis.solennix.feature.products.ui.DemandDataPoint
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

data class ProductDetailUiState(
    val product: Product? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class ProductDetailViewModel @Inject constructor(
    private val productRepository: ProductRepository,
    private val eventRepository: EventRepository,
    private val clientRepository: ClientRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val productId: String = checkNotNull(savedStateHandle["productId"])

    private val _uiState = MutableStateFlow(ProductDetailUiState(isLoading = true))
    val uiState: StateFlow<ProductDetailUiState> = _uiState.asStateFlow()

    private val _demandData = MutableStateFlow<List<DemandDataPoint>>(emptyList())
    val demandData: StateFlow<List<DemandDataPoint>> = _demandData.asStateFlow()

    var deleteSuccess by mutableStateOf(false)
        private set

    init {
        loadProduct()
        loadDemandData()
    }

    private fun loadProduct() {
        viewModelScope.launch {
            try {
                val product = productRepository.getProduct(productId)
                _uiState.value = ProductDetailUiState(product = product, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = ProductDetailUiState(errorMessage = e.message, isLoading = false)
            }
        }
    }

    private fun loadDemandData() {
        viewModelScope.launch {
            try {
                val today = LocalDate.now().toString()

                // Collect upcoming events from local DB
                val events = eventRepository.getEvents().first()
                val upcomingEvents = events.filter { it.eventDate >= today && it.status == com.creapolis.solennix.core.model.EventStatus.CONFIRMED }

                val demandPoints = mutableListOf<DemandDataPoint>()

                for (event in upcomingEvents) {
                    // Get products for this event
                    val eventProducts = eventRepository.getEventProducts(event.id).first()
                    val matchingProduct = eventProducts.find { it.productId == productId }

                    if (matchingProduct != null) {
                        // Get client name
                        val client = clientRepository.getClient(event.clientId)
                        val clientName = client?.name ?: "Cliente"

                        demandPoints.add(
                            DemandDataPoint(
                                eventId = event.id,
                                eventDate = event.eventDate,
                                clientName = clientName,
                                quantity = matchingProduct.quantity.toInt(),
                                numPeople = event.numPeople
                            )
                        )
                    }
                }

                // Sort by date ascending
                _demandData.value = demandPoints.sortedBy { it.eventDate }
            } catch (_: Exception) {
                // Silently fail — demand data is supplementary
                _demandData.value = emptyList()
            }
        }
    }

    fun deleteProduct() {
        viewModelScope.launch {
            try {
                productRepository.deleteProduct(productId)
                deleteSuccess = true
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(errorMessage = "Error al eliminar producto: ${e.message}")
            }
        }
    }
}
