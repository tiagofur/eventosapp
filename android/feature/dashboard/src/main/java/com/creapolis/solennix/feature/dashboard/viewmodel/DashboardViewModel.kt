package com.creapolis.solennix.feature.dashboard.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.model.InventoryItem
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DashboardUiState(
    val upcomingEvents: List<Event> = emptyList(),
    val lowStockItems: List<InventoryItem> = emptyList(),
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val revenueThisMonth: Double = 0.0,
    val eventsThisMonth: Int = 0
)

@HiltViewModel
class DashboardViewModel @Inject constructor(
    private val eventRepository: EventRepository,
    private val inventoryRepository: InventoryRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            
            combine(
                eventRepository.getUpcomingEvents(5),
                inventoryRepository.getLowStockItems(),
                eventRepository.getEvents() // For KPI calculations
            ) { upcoming, lowStock, allEvents ->
                // Basic KPI calculation for this month
                val now = java.time.LocalDate.now()
                val eventsThisMonthList = allEvents.filter {
                    try {
                        val date = java.time.ZonedDateTime.parse(it.eventDate)
                        date.month == now.month && date.year == now.year
                    } catch (e: Exception) { false }
                }
                
                DashboardUiState(
                    upcomingEvents = upcoming,
                    lowStockItems = lowStock,
                    isLoading = false,
                    revenueThisMonth = eventsThisMonthList.sumOf { it.totalAmount },
                    eventsThisMonth = eventsThisMonthList.size
                )
            }.collect { newState ->
                _uiState.value = newState
            }
        }
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.update { it.copy(isRefreshing = true) }
            try {
                eventRepository.syncEvents()
                inventoryRepository.syncInventory()
            } catch (e: Exception) {
                // Handle error
            } finally {
                _uiState.update { it.copy(isRefreshing = false) }
            }
        }
    }
}
