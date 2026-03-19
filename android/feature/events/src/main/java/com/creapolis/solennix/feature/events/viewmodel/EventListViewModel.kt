package com.creapolis.solennix.feature.events.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.model.Client
import com.creapolis.solennix.core.model.Event
import com.creapolis.solennix.core.model.EventStatus
import com.creapolis.solennix.core.model.extensions.asMXN
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class EventListUiState(
    val events: List<Event> = emptyList(),
    val clientMap: Map<String, Client> = emptyMap(),
    val searchQuery: String = "",
    val selectedStatus: EventStatus? = null,
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val statusFilters: List<EventStatusFilter> = emptyList()
)

data class EventStatusFilter(
    val status: EventStatus?,
    val label: String,
    val count: Int = 0
)

@HiltViewModel
class EventListViewModel @Inject constructor(
    private val eventRepository: EventRepository,
    private val clientRepository: ClientRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    private val _selectedStatus = MutableStateFlow<EventStatus?>(null)
    private val _isRefreshing = MutableStateFlow(false)

    val uiState: StateFlow<EventListUiState> = combine(
        eventRepository.getEvents(),
        clientRepository.getClients(),
        _searchQuery,
        _selectedStatus,
        _isRefreshing
    ) { events, clients, searchQuery, selectedStatus, refreshing ->
        val clientMap = clients.associateBy { it.id }

        val statusFilters = buildStatusFilters(events)

        val statusFiltered = if (selectedStatus != null) {
            events.filter { it.status == selectedStatus }
        } else {
            events
        }

        val filtered = if (searchQuery.isBlank()) {
            statusFiltered
        } else {
            statusFiltered.filter { event ->
                event.serviceType.contains(searchQuery, ignoreCase = true) ||
                clientMap[event.clientId]?.name?.contains(searchQuery, ignoreCase = true) == true ||
                event.location?.contains(searchQuery, ignoreCase = true) == true ||
                event.city?.contains(searchQuery, ignoreCase = true) == true
            }
        }

        EventListUiState(
            events = filtered.sortedByDescending { it.eventDate },
            clientMap = clientMap,
            searchQuery = searchQuery,
            selectedStatus = selectedStatus,
            isLoading = false,
            isRefreshing = refreshing,
            statusFilters = statusFilters
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = EventListUiState(isLoading = true)
    )

    private fun buildStatusFilters(events: List<Event>): List<EventStatusFilter> {
        val counts = events.groupingBy { it.status }.eachCount()
        return listOf(
            EventStatusFilter(null, "Todos", events.size),
            EventStatusFilter(EventStatus.QUOTED, "Cotizado", counts[EventStatus.QUOTED] ?: 0),
            EventStatusFilter(EventStatus.CONFIRMED, "Confirmado", counts[EventStatus.CONFIRMED] ?: 0),
            EventStatusFilter(EventStatus.COMPLETED, "Completado", counts[EventStatus.COMPLETED] ?: 0),
            EventStatusFilter(EventStatus.CANCELLED, "Cancelado", counts[EventStatus.CANCELLED] ?: 0)
        )
    }

    init {
        refresh()
    }

    fun onSearchQueryChange(query: String) {
        _searchQuery.value = query
    }

    fun onStatusFilterChange(status: EventStatus?) {
        _selectedStatus.value = status
    }

    fun generateCsvContent(): String {
        val state = uiState.value
        val sb = StringBuilder()
        sb.appendLine("Nombre,Fecha,Cliente,Estado,Total,Pagado,Lugar")
        val statusLabels = mapOf(
            EventStatus.QUOTED to "Cotizado",
            EventStatus.CONFIRMED to "Confirmado",
            EventStatus.COMPLETED to "Completado",
            EventStatus.CANCELLED to "Cancelado"
        )
        state.events.forEach { event ->
            val name = event.serviceType.escapeCsv()
            val date = event.eventDate.escapeCsv()
            val clientName = (state.clientMap[event.clientId]?.name ?: "").escapeCsv()
            val status = (statusLabels[event.status] ?: event.status.name).escapeCsv()
            val total = event.totalAmount.asMXN().escapeCsv()
            val paid = "" // Payment info not available in Event model
            val location = (event.location ?: "").escapeCsv()
            sb.appendLine("$name,$date,$clientName,$status,$total,$paid,$location")
        }
        return sb.toString()
    }

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            try {
                eventRepository.syncEvents()
                clientRepository.syncClients()
            } catch (e: Exception) {
                // Network sync errors are non-fatal
            } finally {
                _isRefreshing.value = false
            }
        }
    }
}

private fun String.escapeCsv(): String {
    return if (contains(",") || contains("\"") || contains("\n")) {
        "\"${replace("\"", "\"\"")}\""
    } else {
        this
    }
}
