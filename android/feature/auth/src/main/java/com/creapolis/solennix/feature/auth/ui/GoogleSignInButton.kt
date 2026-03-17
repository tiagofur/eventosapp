package com.creapolis.solennix.feature.auth.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.credentials.*
import androidx.credentials.exceptions.GetCredentialException
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.google.android.libraries.identity.googleid.GetGoogleIdTokenCredentialRequest
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import kotlinx.coroutines.launch

@Composable
fun GoogleSignInButton(
    onSuccess: (String, String?) -> Unit
) {
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    val credentialManager = CredentialManager.create(context)

    OutlinedButton(
        onClick = {
            coroutineScope.launch {
                val googleIdTokenRequest = GetGoogleIdTokenCredentialRequest.Builder()
                    .setFilterByAuthorizedAccounts(false)
                    .setServerClientId("YOUR_GOOGLE_WEB_CLIENT_ID") // Set from BuildConfig in production
                    .setAutoSelectEnabled(true)
                    .build()

                val request = GetCredentialRequest.Builder()
                    .addCredentialOption(googleIdTokenRequest)
                    .build()

                try {
                    val result = credentialManager.getCredential(context, request)
                    val credential = result.credential
                    if (credential is CustomCredential && 
                        credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
                        val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(credential.data)
                        onSuccess(googleIdTokenCredential.idToken, googleIdTokenCredential.displayName)
                    }
                } catch (e: GetCredentialException) {
                    // Handle error
                }
            }
        },
        modifier = Modifier
            .fillMaxWidth()
            .height(50.dp),
        shape = MaterialTheme.shapes.small,
        colors = ButtonDefaults.outlinedButtonColors(
            contentColor = SolennixTheme.colors.primaryText
        ),
        border = ButtonDefaults.outlinedButtonBorder.copy(
            brush = null, // Standard black/white border for Google
            width = 1.dp
        )
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            // Placeholder for Google G icon
            Text(
                text = "G",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = androidx.compose.ui.text.font.FontWeight.Bold,
                color = Color.Red // Simple colored G
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = "Continuar con Google",
                style = MaterialTheme.typography.titleMedium
            )
        }
    }
}
