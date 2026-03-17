package com.creapolis.solennix.feature.events.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.ProductRepository
import com.creapolis.solennix.core.model.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.util.UUID
import javax.inject.Inject

@HiltViewModel
class EventFormViewModel @Inject constructor(
    private val eventRepository: EventRepository,
    private val clientRepository: ClientRepository,
    private val productRepository: ProductRepository
) : ViewModel() {

    // Step 1: General Info
    var selectedClient by mutableStateOf<Client?>(null)
    var eventDate by mutableStateOf(LocalDate.now())
    var serviceType by mutableStateOf("")
    var numPeople by mutableStateOf("0")

    // Step 2: Products
    val selectedProducts = mutableStateListOf<EventProduct>()
    private val _availableProducts = MutableStateFlow<List<Product>>(emptyList())
    val availableProducts: StateFlow<List<Product>> = _availableProducts.asStateFlow()

    // Step 3: Extras
    val eventExtras = mutableStateListOf<EventExtra>()
    var discount by mutableStateOf("0")
    var discountType by mutableStateOf(DiscountType.PERCENT)

    // Step 4: Location & Details
    var location by mutableStateOf("")
    var city by mutableStateOf("")
    var notes by mutableStateOf("")

    // Step 5: Summary Logic
    val subtotal: Double get() = selectedProducts.sumOf { it.totalPrice ?: 0.0 } + eventExtras.sumOf { it.price }
    val total: Double get() {
        val d = discount.toDoubleOrNull() ?: 0.0
        return if (discountType == DiscountType.PERCENT) {
            subtotal * (1 - d / 100)
        } else {
            (subtotal - d).coerceAtLeast(0.0)
        }
    }

    var isLoading by mutableStateOf(false)
    var saveSuccess by mutableStateOf(false)

    init {
        viewModelScope.launch {
            productRepository.getProducts().collect {
                _availableProducts.value = it
            }
        }
    }

    fun addProduct(product: Product, quantity: Int) {
        val eventProduct = EventProduct(
            id = UUID.randomUUID().toString(),
            eventId = "", // Temp
            productId = product.id,
            quantity = quantity,
            unitPrice = product.basePrice,
            totalPrice = product.basePrice * quantity,
            createdAt = ""
        )
        selectedProducts.add(eventProduct)
    }

    fun saveEvent() {
        val client = selectedClient ?: return
        viewModelScope.launch {
            isLoading = true
            try {
                val newEvent = Event(
                    id = UUID.randomUUID().toString(),
                    userId = "", // Handled by backend
                    clientId = client.id,
                    eventDate = eventDate.toString(),
                    serviceType = serviceType,
                    numPeople = numPeople.toIntOrNull() ?: 0,
                    status = EventStatus.QUOTED,
                    discount = discount.toDoubleOrNull() ?: 0.0,
                    discountType = discountType,
                    totalAmount = total,
                    location = location,
                    city = city,
                    notes = notes,
                    createdAt = "",
                    updatedAt = ""
                )
                eventRepository.createEvent(newEvent)
                saveSuccess = true
            } catch (e: Exception) {
                // Handle error
            } finally {
                isLoading = false
            }
        }
    }
}
