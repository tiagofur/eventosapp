package com.creapolis.solennix

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.adaptive.currentWindowSize
import androidx.compose.material3.windowsizeclass.ExperimentalMaterial3WindowSizeClassApi
import androidx.compose.material3.windowsizeclass.WindowWidthSizeClass
import androidx.compose.material3.windowsizeclass.calculateWindowSizeClass
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.network.AuthManager
import com.creapolis.solennix.feature.auth.ui.BiometricGateScreen
import com.creapolis.solennix.feature.auth.viewmodel.AuthViewModel
import com.creapolis.solennix.ui.navigation.AdaptiveNavigationRailLayout
import com.creapolis.solennix.ui.navigation.AuthNavHost
import com.creapolis.solennix.ui.navigation.CompactBottomNavLayout
import androidx.fragment.app.FragmentActivity

@OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
@Composable
fun MainNavHost() {
    val authViewModel: AuthViewModel = hiltViewModel()
    val authState by authViewModel.authState.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val activity = context as? FragmentActivity
    val windowSizeClass = activity?.let { calculateWindowSizeClass(it) }

    LaunchedEffect(Unit) {
        authViewModel.authManager.restoreSession()
    }

    when (authState) {
        AuthManager.AuthState.Unknown -> {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = SolennixTheme.colors.primary)
            }
        }
        AuthManager.AuthState.Unauthenticated -> {
            AuthNavHost()
        }
        AuthManager.AuthState.BiometricLocked -> {
            BiometricGateScreen(authManager = authViewModel.authManager)
        }
        AuthManager.AuthState.Authenticated -> {
            if (windowSizeClass != null && windowSizeClass.widthSizeClass != WindowWidthSizeClass.Compact) {
                AdaptiveNavigationRailLayout()
            } else {
                CompactBottomNavLayout()
            }
        }
    }
}
