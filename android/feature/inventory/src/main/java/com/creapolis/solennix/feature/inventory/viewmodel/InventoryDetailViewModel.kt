package com.creapolis.solennix.feature.inventory.viewmodel

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.model.InventoryItem
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class InventoryDetailUiState(
    val item: InventoryItem? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class InventoryDetailViewModel @Inject constructor(
    private val inventoryRepository: InventoryRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val itemId: String = checkNotNull(savedStateHandle["itemId"])

    private val _uiState = MutableStateFlow(InventoryDetailUiState(isLoading = true))
    val uiState: StateFlow<InventoryDetailUiState> = _uiState.asStateFlow()

    init {
        loadItem()
    }

    private fun loadItem() {
        viewModelScope.launch {
            try {
                val item = inventoryRepository.getInventoryItem(itemId)
                _uiState.value = InventoryDetailUiState(item = item, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = InventoryDetailUiState(errorMessage = e.message, isLoading = false)
            }
        }
    }
}
