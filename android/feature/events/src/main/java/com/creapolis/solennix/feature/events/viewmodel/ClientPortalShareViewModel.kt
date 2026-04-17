package com.creapolis.solennix.feature.events.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.EventPublicLinkRepository
import com.creapolis.solennix.core.model.EventPublicLink
import com.creapolis.solennix.core.network.SolennixException
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * UI state for the Portal del cliente bottom sheet
 * (PRD/12 feature A).
 *
 * - [isLoading] `true` during the initial fetch; drives the spinner
 *   state.
 * - [isBusy]    `true` during generate / rotate / revoke; disables the
 *   action buttons.
 * - [link]      `null` means no active link exists — render the empty
 *   state CTA.
 * - [error]     one-shot error message for the snackbar; clear via
 *   [ClientPortalShareViewModel.consumeError].
 */
data class ClientPortalShareUiState(
    val link: EventPublicLink? = null,
    val isLoading: Boolean = false,
    val isBusy: Boolean = false,
    val error: String? = null
)

/**
 * ViewModel backing the Portal del cliente bottom sheet.
 *
 * The screen calls [load] with the event id when it becomes visible
 * and the VM handles the three organizer endpoints (get / create or
 * rotate / revoke). 404 from `getActive` is treated as an empty state,
 * not an error.
 */
@HiltViewModel
class ClientPortalShareViewModel @Inject constructor(
    private val repository: EventPublicLinkRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ClientPortalShareUiState())
    val uiState: StateFlow<ClientPortalShareUiState> = _uiState.asStateFlow()

    private var currentEventId: String? = null

    /** Loads the active link for [eventId]. Safe to call repeatedly. */
    fun load(eventId: String) {
        currentEventId = eventId
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val link = repository.getActive(eventId)
                _uiState.update { it.copy(link = link, isLoading = false) }
            } catch (e: SolennixException) {
                _uiState.update {
                    it.copy(
                        link = null,
                        isLoading = false,
                        error = e.message ?: "No pudimos cargar el enlace."
                    )
                }
            }
        }
    }

    /** Creates the very first link for the event (empty-state CTA). */
    fun generate() {
        val eventId = currentEventId ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isBusy = true, error = null) }
            try {
                val link = repository.createOrRotate(eventId, ttlDays = null)
                _uiState.update { it.copy(link = link, isBusy = false) }
            } catch (e: SolennixException) {
                _uiState.update {
                    it.copy(
                        isBusy = false,
                        error = e.message ?: "No pudimos generar el enlace."
                    )
                }
            }
        }
    }

    /** Rotates the active link — previous URL stops working immediately. */
    fun rotate() {
        val eventId = currentEventId ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isBusy = true, error = null) }
            try {
                val link = repository.createOrRotate(eventId, ttlDays = null)
                _uiState.update { it.copy(link = link, isBusy = false) }
            } catch (e: SolennixException) {
                _uiState.update {
                    it.copy(
                        isBusy = false,
                        error = e.message ?: "No pudimos rotar el enlace."
                    )
                }
            }
        }
    }

    /** Revokes the active link and clears the local state. */
    fun revoke() {
        val eventId = currentEventId ?: return
        viewModelScope.launch {
            _uiState.update { it.copy(isBusy = true, error = null) }
            try {
                repository.revoke(eventId)
                _uiState.update { it.copy(link = null, isBusy = false) }
            } catch (e: SolennixException) {
                _uiState.update {
                    it.copy(
                        isBusy = false,
                        error = e.message ?: "No pudimos deshabilitar el enlace."
                    )
                }
            }
        }
    }

    /** Clears the one-shot error after it has been shown. */
    fun consumeError() {
        _uiState.update { it.copy(error = null) }
    }
}
