package com.creapolis.solennix.feature.inventory.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.model.InventoryItem
import com.creapolis.solennix.core.model.InventoryType
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class InventoryListUiState(
    val items: List<InventoryItem> = emptyList(),
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val searchQuery: String = "",
    val selectedType: InventoryType? = null,
    val lowStockOnly: Boolean = false
)

@HiltViewModel
class InventoryListViewModel @Inject constructor(
    private val inventoryRepository: InventoryRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    private val _selectedType = MutableStateFlow<InventoryType?>(null)
    private val _lowStockOnly = MutableStateFlow(false)
    private val _isRefreshing = MutableStateFlow(false)

    val uiState: StateFlow<InventoryListUiState> = combine(
        inventoryRepository.getInventoryItems(),
        _searchQuery,
        _selectedType,
        _lowStockOnly,
        _isRefreshing
    ) { items, query, type, lowStock, refreshing ->
        var filtered = items
        if (query.isNotBlank()) {
            filtered = filtered.filter { it.ingredientName.contains(query, ignoreCase = true) }
        }
        if (type != null) {
            filtered = filtered.filter { it.type == type }
        }
        if (lowStock) {
            filtered = filtered.filter { it.currentStock <= it.minimumStock }
        }
        InventoryListUiState(
            items = filtered,
            isRefreshing = refreshing,
            searchQuery = query,
            selectedType = type,
            lowStockOnly = lowStock
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = InventoryListUiState(isLoading = true)
    )

    init {
        refresh()
    }

    fun onSearchQueryChange(query: String) {
        _searchQuery.value = query
    }

    fun onTypeFilterChange(type: InventoryType?) {
        _selectedType.value = type
    }

    fun onLowStockToggle(enabled: Boolean) {
        _lowStockOnly.value = enabled
    }

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            try {
                inventoryRepository.syncInventory()
            } catch (e: Exception) {
                // Non-fatal, data will show from cache
            } finally {
                _isRefreshing.value = false
            }
        }
    }
}
