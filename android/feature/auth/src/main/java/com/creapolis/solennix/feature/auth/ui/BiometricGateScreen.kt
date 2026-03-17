package com.creapolis.solennix.feature.auth.ui

import androidx.biometric.BiometricPrompt
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.fragment.app.FragmentActivity
import com.creapolis.solennix.core.designsystem.component.PremiumButton
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.network.AuthManager
import java.util.concurrent.Executors

@Composable
fun BiometricGateScreen(
    authManager: AuthManager
) {
    val context = LocalContext.current
    val executor = Executors.newSingleThreadExecutor()
    
    val biometricPrompt = BiometricPrompt(
        context as FragmentActivity,
        executor,
        object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                if (errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON) {
                    authManager.failedBiometric()
                }
            }

            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                authManager.unlockWithBiometric()
            }

            override fun onAuthenticationFailed() {
                super.onAuthenticationFailed()
            }
        }
    )

    val promptInfo = BiometricPrompt.PromptInfo.Builder()
        .setTitle("Desbloquea Solennix")
        .setSubtitle("Usa tu huella o rostro para continuar")
        .setNegativeButtonText("Cerrar Sesion")
        .build()

    LaunchedEffect(Unit) {
        biometricPrompt.authenticate(promptInfo)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            imageVector = Icons.Default.Fingerprint,
            contentDescription = null,
            modifier = Modifier.size(100.dp),
            tint = SolennixTheme.colors.primary
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Acceso Protegido",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = SolennixTheme.colors.primaryText
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Confirma tu identidad para continuar utilizando la aplicacion.",
            style = MaterialTheme.typography.bodyMedium,
            color = SolennixTheme.colors.secondaryText,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(48.dp))
        PremiumButton(
            text = "Intentar de nuevo",
            onClick = { biometricPrompt.authenticate(promptInfo) }
        )
    }
}
