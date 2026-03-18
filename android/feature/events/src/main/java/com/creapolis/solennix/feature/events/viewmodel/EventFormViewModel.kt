package com.creapolis.solennix.feature.events.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.InventoryRepository
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
    private val productRepository: ProductRepository,
    private val inventoryRepository: InventoryRepository
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

    // Step 4: Equipment
    val selectedEquipment = mutableStateListOf<EventEquipment>()
    private val _equipmentConflicts = MutableStateFlow<List<EquipmentConflict>>(emptyList())
    val equipmentConflicts: StateFlow<List<EquipmentConflict>> = _equipmentConflicts.asStateFlow()
    private val _equipmentSuggestions = MutableStateFlow<List<EquipmentSuggestion>>(emptyList())
    val equipmentSuggestions: StateFlow<List<EquipmentSuggestion>> = _equipmentSuggestions.asStateFlow()
    private val _availableEquipment = MutableStateFlow<List<InventoryItem>>(emptyList())
    val availableEquipment: StateFlow<List<InventoryItem>> = _availableEquipment.asStateFlow()
    var isCheckingConflicts by mutableStateOf(false)

    // Step 5: Supplies
    val selectedSupplies = mutableStateListOf<EventSupply>()
    private val _supplySuggestions = MutableStateFlow<List<SupplySuggestion>>(emptyList())
    val supplySuggestions: StateFlow<List<SupplySuggestion>> = _supplySuggestions.asStateFlow()
    private val _availableSupplies = MutableStateFlow<List<InventoryItem>>(emptyList())
    val availableSupplies: StateFlow<List<InventoryItem>> = _availableSupplies.asStateFlow()

    // Step 6: Location & Details (moved to GeneralInfo in UI)
    var location by mutableStateOf("")
    var city by mutableStateOf("")
    var notes by mutableStateOf("")

    // Summary Logic
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
        viewModelScope.launch {
            inventoryRepository.getInventoryItems().collect { items ->
                _availableEquipment.value = items.filter { it.type == InventoryType.EQUIPMENT }
                _availableSupplies.value = items.filter {
                    it.type == InventoryType.SUPPLY || it.type == InventoryType.INGREDIENT
                }
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

    // Equipment Methods
    fun addEquipment(item: InventoryItem, quantity: Int) {
        val existing = selectedEquipment.find { it.inventoryId == item.id }
        if (existing != null) {
            val index = selectedEquipment.indexOf(existing)
            selectedEquipment[index] = existing.copy(quantity = existing.quantity + quantity)
        } else {
            val equipment = EventEquipment(
                id = UUID.randomUUID().toString(),
                eventId = "",
                inventoryId = item.id,
                quantity = quantity,
                createdAt = "",
                equipmentName = item.ingredientName,
                unit = item.unit,
                currentStock = item.currentStock
            )
            selectedEquipment.add(equipment)
        }
        checkEquipmentConflicts()
    }

    fun removeEquipment(inventoryId: String) {
        selectedEquipment.removeAll { it.inventoryId == inventoryId }
        checkEquipmentConflicts()
    }

    fun updateEquipmentQuantity(inventoryId: String, newQuantity: Int) {
        if (newQuantity <= 0) {
            removeEquipment(inventoryId)
            return
        }
        val existing = selectedEquipment.find { it.inventoryId == inventoryId }
        if (existing != null) {
            val index = selectedEquipment.indexOf(existing)
            selectedEquipment[index] = existing.copy(quantity = newQuantity)
        }
        checkEquipmentConflicts()
    }

    fun checkEquipmentConflicts() {
        if (selectedEquipment.isEmpty()) {
            _equipmentConflicts.value = emptyList()
            return
        }
        viewModelScope.launch {
            isCheckingConflicts = true
            try {
                val conflicts = eventRepository.getEquipmentConflicts(
                    eventDate = eventDate.toString(),
                    equipmentIds = selectedEquipment.map { it.inventoryId }
                )
                _equipmentConflicts.value = conflicts
            } catch (e: Exception) {
                _equipmentConflicts.value = emptyList()
            } finally {
                isCheckingConflicts = false
            }
        }
    }

    fun fetchEquipmentSuggestions() {
        if (selectedProducts.isEmpty()) {
            _equipmentSuggestions.value = emptyList()
            return
        }
        viewModelScope.launch {
            try {
                val suggestions = eventRepository.getEquipmentSuggestions(
                    productIds = selectedProducts.map { it.productId }
                )
                _equipmentSuggestions.value = suggestions
            } catch (e: Exception) {
                _equipmentSuggestions.value = emptyList()
            }
        }
    }

    fun addEquipmentFromSuggestion(suggestion: EquipmentSuggestion) {
        val existing = selectedEquipment.find { it.inventoryId == suggestion.id }
        if (existing == null) {
            val equipment = EventEquipment(
                id = UUID.randomUUID().toString(),
                eventId = "",
                inventoryId = suggestion.id,
                quantity = suggestion.suggestedQuantity.toInt().coerceAtLeast(1),
                createdAt = "",
                equipmentName = suggestion.ingredientName,
                unit = suggestion.unit,
                currentStock = suggestion.currentStock
            )
            selectedEquipment.add(equipment)
            checkEquipmentConflicts()
        }
    }

    // Supplies Methods
    fun addSupply(item: InventoryItem, quantity: Double, source: SupplySource = SupplySource.STOCK) {
        val existing = selectedSupplies.find { it.inventoryId == item.id }
        if (existing != null) {
            val index = selectedSupplies.indexOf(existing)
            selectedSupplies[index] = existing.copy(quantity = existing.quantity + quantity)
        } else {
            val supply = EventSupply(
                id = UUID.randomUUID().toString(),
                eventId = "",
                inventoryId = item.id,
                quantity = quantity,
                unitCost = item.unitCost ?: 0.0,
                source = source,
                createdAt = "",
                supplyName = item.ingredientName,
                unit = item.unit,
                currentStock = item.currentStock
            )
            selectedSupplies.add(supply)
        }
    }

    fun removeSupply(inventoryId: String) {
        selectedSupplies.removeAll { it.inventoryId == inventoryId }
    }

    fun updateSupplyQuantity(inventoryId: String, newQuantity: Double) {
        if (newQuantity <= 0) {
            removeSupply(inventoryId)
            return
        }
        val existing = selectedSupplies.find { it.inventoryId == inventoryId }
        if (existing != null) {
            val index = selectedSupplies.indexOf(existing)
            selectedSupplies[index] = existing.copy(quantity = newQuantity)
        }
    }

    fun updateSupplySource(inventoryId: String, source: SupplySource) {
        val existing = selectedSupplies.find { it.inventoryId == inventoryId }
        if (existing != null) {
            val index = selectedSupplies.indexOf(existing)
            selectedSupplies[index] = existing.copy(source = source)
        }
    }

    fun fetchSupplySuggestions() {
        if (selectedProducts.isEmpty()) {
            _supplySuggestions.value = emptyList()
            return
        }
        viewModelScope.launch {
            try {
                val suggestions = eventRepository.getSupplySuggestions(
                    productIds = selectedProducts.map { it.productId },
                    numPeople = numPeople.toIntOrNull() ?: 0
                )
                _supplySuggestions.value = suggestions
            } catch (e: Exception) {
                _supplySuggestions.value = emptyList()
            }
        }
    }

    fun addSupplyFromSuggestion(suggestion: SupplySuggestion) {
        val existing = selectedSupplies.find { it.inventoryId == suggestion.id }
        if (existing == null) {
            val source = if (suggestion.currentStock >= suggestion.suggestedQuantity) {
                SupplySource.STOCK
            } else {
                SupplySource.PURCHASE
            }
            val supply = EventSupply(
                id = UUID.randomUUID().toString(),
                eventId = "",
                inventoryId = suggestion.id,
                quantity = suggestion.suggestedQuantity,
                unitCost = suggestion.unitCost,
                source = source,
                createdAt = "",
                supplyName = suggestion.ingredientName,
                unit = suggestion.unit,
                currentStock = suggestion.currentStock
            )
            selectedSupplies.add(supply)
        }
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

                // Save equipment for the event
                if (selectedEquipment.isNotEmpty()) {
                    eventRepository.updateEventEquipment(
                        eventId = createdEvent.id,
                        equipment = selectedEquipment.toList()
                    )
                }

                // Save supplies for the event
                if (selectedSupplies.isNotEmpty()) {
                    eventRepository.updateEventSupplies(
                        eventId = createdEvent.id,
                        supplies = selectedSupplies.toList()
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
