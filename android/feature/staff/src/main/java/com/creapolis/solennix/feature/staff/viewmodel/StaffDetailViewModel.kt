package com.creapolis.solennix.feature.staff.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.data.repository.StaffRepository
import com.creapolis.solennix.core.model.Staff
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class StaffDetailUiState(
    val staff: Staff? = null,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class StaffDetailViewModel @Inject constructor(
    private val staffRepository: StaffRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val staffId: String = checkNotNull(savedStateHandle["staffId"])

    private val _uiState = MutableStateFlow(StaffDetailUiState(isLoading = true))
    val uiState: StateFlow<StaffDetailUiState> = _uiState.asStateFlow()

    var deleteSuccess by mutableStateOf(false)
        private set

    init {
        loadStaff()
    }

    private fun loadStaff() {
        viewModelScope.launch {
            try {
                val staff = staffRepository.getStaffMember(staffId)
                _uiState.update { it.copy(staff = staff, isLoading = false) }
            } catch (e: Exception) {
                _uiState.update { it.copy(errorMessage = e.message, isLoading = false) }
            }
        }
    }

    fun deleteStaff() {
        viewModelScope.launch {
            try {
                staffRepository.deleteStaff(staffId)
                deleteSuccess = true
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(errorMessage = "Error al eliminar colaborador: ${e.message}")
                }
            }
        }
    }
}
