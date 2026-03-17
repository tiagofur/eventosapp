package com.creapolis.solennix.feature.clients.viewmodel

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.ClientRepository
import com.creapolis.solennix.core.model.Client
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ClientDetailUiState(
    val client: Client? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class ClientDetailViewModel @Inject constructor(
    private val clientRepository: ClientRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val clientId: String = checkNotNull(savedStateHandle["clientId"])

    private val _uiState = MutableStateFlow(ClientDetailUiState(isLoading = true))
    val uiState: StateFlow<ClientDetailUiState> = _uiState.asStateFlow()

    init {
        loadClient()
    }

    private fun loadClient() {
        viewModelScope.launch {
            try {
                val client = clientRepository.getClient(clientId)
                _uiState.value = ClientDetailUiState(client = client, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = ClientDetailUiState(errorMessage = e.message, isLoading = false)
            }
        }
    }
}
