package com.creapolis.solennix.feature.events.viewmodel

import android.content.Context
import android.content.SharedPreferences
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.model.InventoryType
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ChecklistItem(
    val id: String,
    val name: String,
    val quantity: Double,
    val unit: String,
    val section: ChecklistSection,
    val unitCost: Double = 0.0
)

enum class ChecklistSection {
    EQUIPMENT,
    STOCK,
    PURCHASE
}

data class EventChecklistUiState(
    val eventId: String = "",
    val eventName: String = "",
    val eventDate: String = "",
    val items: List<ChecklistItem> = emptyList(),
    val checkedIds: Set<String> = emptySet(),
    val isLoading: Boolean = true,
    val error: String? = null
) {
    val progress: Float
        get() = if (items.isEmpty()) 0f else checkedIds.size.toFloat() / items.size

    val equipmentItems: List<ChecklistItem>
        get() = items.filter { it.section == ChecklistSection.EQUIPMENT }

    val stockItems: List<ChecklistItem>
        get() = items.filter { it.section == ChecklistSection.STOCK }

    val purchaseItems: List<ChecklistItem>
        get() = items.filter { it.section == ChecklistSection.PURCHASE }
}

@HiltViewModel
class EventChecklistViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val eventRepository: EventRepository,
    private val inventoryRepository: InventoryRepository,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val eventId: String = savedStateHandle["eventId"] ?: ""
    private val prefs: SharedPreferences = context.getSharedPreferences("checklist_prefs", Context.MODE_PRIVATE)

    private val _uiState = MutableStateFlow(EventChecklistUiState(eventId = eventId))
    val uiState: StateFlow<EventChecklistUiState> = _uiState.asStateFlow()

    init {
        loadChecklist()
        loadPersistedCheckedState()
    }

    private fun loadChecklist() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                // Get event details
                val event = eventRepository.getEvent(eventId)
                if (event == null) {
                    _uiState.update { it.copy(isLoading = false, error = "Evento no encontrado") }
                    return@launch
                }

                // Collect all checklist items
                val checklistItems = mutableListOf<ChecklistItem>()

                // Get inventory items and categorize them
                inventoryRepository.getInventoryItems().first().forEach { item ->
                    when (item.type) {
                        InventoryType.EQUIPMENT -> {
                            checklistItems.add(
                                ChecklistItem(
                                    id = "eq_${item.id}",
                                    name = item.ingredientName,
                                    quantity = 1.0,
                                    unit = item.unit,
                                    section = ChecklistSection.EQUIPMENT
                                )
                            )
                        }
                        InventoryType.SUPPLY, InventoryType.INGREDIENT -> {
                            // Determine if from stock or purchase based on current stock
                            val section = if (item.currentStock >= item.minimumStock) {
                                ChecklistSection.STOCK
                            } else {
                                ChecklistSection.PURCHASE
                            }
                            checklistItems.add(
                                ChecklistItem(
                                    id = "sup_${item.id}",
                                    name = item.ingredientName,
                                    quantity = item.minimumStock,
                                    unit = item.unit,
                                    section = section,
                                    unitCost = item.unitCost ?: 0.0
                                )
                            )
                        }
                    }
                }

                _uiState.update {
                    it.copy(
                        isLoading = false,
                        eventName = event.serviceType,
                        eventDate = event.eventDate,
                        items = checklistItems
                    )
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }

    private fun loadPersistedCheckedState() {
        val key = "checklist_$eventId"
        val checkedIds = prefs.getStringSet(key, emptySet()) ?: emptySet()
        _uiState.update { it.copy(checkedIds = checkedIds) }
    }

    private fun persistCheckedState(checkedIds: Set<String>) {
        val key = "checklist_$eventId"
        prefs.edit().putStringSet(key, checkedIds).apply()
    }

    fun toggleItem(itemId: String) {
        val currentChecked = _uiState.value.checkedIds
        val newChecked = if (currentChecked.contains(itemId)) {
            currentChecked - itemId
        } else {
            currentChecked + itemId
        }

        _uiState.update { it.copy(checkedIds = newChecked) }
        persistCheckedState(newChecked)
    }

    fun checkAllInSection(section: ChecklistSection) {
        val sectionItems = _uiState.value.items.filter { it.section == section }
        val sectionIds = sectionItems.map { it.id }.toSet()
        val newChecked = _uiState.value.checkedIds + sectionIds

        _uiState.update { it.copy(checkedIds = newChecked) }
        persistCheckedState(newChecked)
    }

    fun uncheckAllInSection(section: ChecklistSection) {
        val sectionItems = _uiState.value.items.filter { it.section == section }
        val sectionIds = sectionItems.map { it.id }.toSet()
        val newChecked = _uiState.value.checkedIds - sectionIds

        _uiState.update { it.copy(checkedIds = newChecked) }
        persistCheckedState(newChecked)
    }

    fun resetChecklist() {
        _uiState.update { it.copy(checkedIds = emptySet()) }
        val key = "checklist_$eventId"
        prefs.edit().remove(key).apply()
    }
}
