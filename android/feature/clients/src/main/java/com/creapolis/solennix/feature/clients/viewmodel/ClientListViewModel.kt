package com.creapolis.solennix.feature.clients.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.model.Client
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ClientListUiState(
    val clients: List<Client> = emptyList(),
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val searchQuery: String = ""
)

@HiltViewModel
class ClientListViewModel @Inject constructor(
    private val clientRepository: ClientRepository
) : ViewModel() {

    private val _searchQuery = MutableStateFlow("")
    
    val uiState: StateFlow<ClientListUiState> = combine(
        clientRepository.getClients(),
        _searchQuery,
        MutableStateFlow(false), // isLoading
        MutableStateFlow(false)  // isRefreshing
    ) { clients, query, loading, refreshing ->
        val filteredClients = if (query.isBlank()) {
            clients
        } else {
            clients.filter { 
                it.name.contains(query, ignoreCase = true) || 
                it.email?.contains(query, ignoreCase = true) == true 
            }
        }
        ClientListUiState(
            clients = filteredClients,
            isLoading = loading,
            isRefreshing = refreshing,
            searchQuery = query
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = ClientListUiState(isLoading = true)
    )

    init {
        refresh()
    }

    fun onSearchQueryChange(query: String) {
        _searchQuery.value = query
    }

    fun refresh() {
        viewModelScope.launch {
            try {
                clientRepository.syncClients()
            } catch (e: Exception) {
                // Handle error
            }
        }
    }
}
