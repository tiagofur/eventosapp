package com.creapolis.solennix.feature.search.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.data.repository.EventRepository
import com.creapolis.solennix.core.model.Client
import com.creapolis.solennix.core.model.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val clients: List<Client> = emptyList(),
    val events: List<Event> = emptyList(),
    val isLoading: Boolean = false
)

@HiltViewModel
class SearchViewModel @Inject constructor(
    private val clientRepository: ClientRepository,
    private val eventRepository: EventRepository
) : ViewModel() {

    private val _query = MutableStateFlow("")
    val uiState: StateFlow<SearchUiState> = combine(
        _query,
        clientRepository.getClients(),
        eventRepository.getEvents()
    ) { query, allClients, allEvents ->
        if (query.isBlank()) {
            SearchUiState(query = query)
        } else {
            SearchUiState(
                query = query,
                clients = allClients.filter { it.name.contains(query, ignoreCase = true) },
                events = allEvents.filter { it.serviceType.contains(query, ignoreCase = true) }
            )
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = SearchUiState()
    )

    fun onQueryChange(query: String) {
        _query.value = query
    }
}
