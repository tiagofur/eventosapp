package com.creapolis.solennix.feature.settings.viewmodel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.get
import com.creapolis.solennix.core.network.post
import com.creapolis.solennix.core.network.put
import com.creapolis.solennix.core.network.Endpoints
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class ChangePasswordViewModel @Inject constructor(
    private val apiService: ApiService
) : ViewModel() {

    var currentPassword by mutableStateOf("")
    var newPassword by mutableStateOf("")
    var confirmPassword by mutableStateOf("")

    var isSaving by mutableStateOf(false)
    var saveSuccess by mutableStateOf(false)
    var errorMessage by mutableStateOf<String?>(null)

    var hasAttemptedSubmit by mutableStateOf(false)

    val currentPasswordError: String?
        get() = if (hasAttemptedSubmit && currentPassword.isBlank()) "La contraseña actual es requerida" else null

    val newPasswordError: String?
        get() = when {
            hasAttemptedSubmit && newPassword.isBlank() -> "La nueva contraseña es requerida"
            hasAttemptedSubmit && newPassword.length < 8 -> "Mínimo 8 caracteres"
            else -> null
        }

    val confirmPasswordError: String?
        get() = when {
            hasAttemptedSubmit && confirmPassword.isBlank() -> "Confirma la contraseña"
            hasAttemptedSubmit && confirmPassword != newPassword -> "Las contraseñas no coinciden"
            else -> null
        }

    val isFormValid: Boolean
        get() = currentPassword.isNotBlank() &&
                newPassword.length >= 8 &&
                confirmPassword == newPassword

    fun changePassword() {
        hasAttemptedSubmit = true
        if (!isFormValid) return

        viewModelScope.launch {
            isSaving = true
            errorMessage = null
            try {
                val payload = mapOf(
                    "current_password" to currentPassword,
                    "new_password" to newPassword
                )
                apiService.post<Any>(Endpoints.CHANGE_PASSWORD, payload)
                saveSuccess = true
            } catch (e: Exception) {
                errorMessage = "Error al cambiar contraseña: ${e.message}"
            } finally {
                isSaving = false
            }
        }
    }
}
