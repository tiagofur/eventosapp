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
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.LocalTime
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
    var startTime by mutableStateOf(LocalTime.of(14, 0))
    var serviceType by mutableStateOf("")
    var numPeople by mutableStateOf("0")

    // Client Picker Logic
    private val _clientSearchQuery = MutableStateFlow("")
    val clientSearchQuery = _clientSearchQuery.asStateFlow()
    
    val filteredClients: StateFlow<List<Client>> = _clientSearchQuery
        .debounce(300)
        .flatMapLatest { query ->
            if (query.isBlank()) clientRepository.getClients()
            else clientRepository.getClients().map { clients ->
                clients.filter { it.name.contains(query, ignoreCase = true) }
            }
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun onClientSearchQueryChange(query: String) {
        _clientSearchQuery.value = query
    }

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
        val existing = selectedProducts.find { it.productId == product.id }
        if (existing != null) {
            val index = selectedProducts.indexOf(existing)
            selectedProducts[index] = existing.copy(
                quantity = existing.quantity + quantity,
                totalPrice = (existing.quantity + quantity) * existing.unitPrice
            )
        } else {
            val eventProduct = EventProduct(
                id = UUID.randomUUID().toString(),
                eventId = "", 
                productId = product.id,
                quantity = quantity,
                unitPrice = product.basePrice,
                totalPrice = product.basePrice * quantity,
                createdAt = ""
            )
            selectedProducts.add(eventProduct)
        }
    }

    fun removeProduct(productId: String) {
        selectedProducts.removeAll { it.productId == productId }
    }

    fun updateProductQuantity(productId: String, newQuantity: Int) {
        if (newQuantity <= 0) {
            removeProduct(productId)
            return
        }
        val existing = selectedProducts.find { it.productId == productId }
        if (existing != null) {
            val index = selectedProducts.indexOf(existing)
            selectedProducts[index] = existing.copy(
                quantity = newQuantity,
                totalPrice = newQuantity * existing.unitPrice
            )
        }
    }

    fun addExtra(description: String, price: Double) {
        if (description.isBlank() || price <= 0) return
        val extra = EventExtra(
            id = UUID.randomUUID().toString(),
            eventId = "",
            description = description,
            cost = 0.0, // Default cost to 0, price is what matters for total
            price = price,
            createdAt = ""
        )
        eventExtras.add(extra)
    }

    fun removeExtra(id: String) {
        eventExtras.removeAll { it.id == id }
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
                    startTime = startTime.toString(),
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
                val createdEvent = eventRepository.createEvent(newEvent)

                // Save products and extras for the event
                if (selectedProducts.isNotEmpty() || eventExtras.isNotEmpty()) {
                    eventRepository.updateItems(
                        eventId = createdEvent.id,
                        products = selectedProducts.toList(),
                        extras = eventExtras.toList()
                    )
                }

                saveSuccess = true
            } catch (e: Exception) {
                // Handle error
            } finally {
                isLoading = false
            }
        }
    }
}
