package com.creapolis.solennix.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.designsystem.theme.SolennixTitle
import com.creapolis.solennix.feature.clients.ui.ClientDetailScreen
import com.creapolis.solennix.feature.clients.ui.ClientListScreen
import com.creapolis.solennix.feature.dashboard.ui.DashboardScreen

@Composable
fun AdaptiveNavigationRailLayout() {
    var selectedSection by remember { mutableStateOf(SidebarSection.DASHBOARD) }

    Row(Modifier.fillMaxSize()) {
        NavigationRail(
            containerColor = SolennixTheme.colors.card,
            header = {
                Text(
                    text = "S",
                    style = SolennixTitle,
                    color = SolennixTheme.colors.primary,
                    modifier = Modifier.padding(vertical = 16.dp)
                )
            }
        ) {
            SidebarSection.entries.forEach { section ->
                NavigationRailItem(
                    selected = selectedSection == section,
                    onClick = { 
                        selectedSection = section
                    },
                    icon = { Icon(section.icon, section.label) },
                    label = { Text(section.label) },
                    colors = NavigationRailItemDefaults.colors(
                        selectedIconColor = SolennixTheme.colors.primary,
                        unselectedIconColor = SolennixTheme.colors.secondaryText,
                        indicatorColor = SolennixTheme.colors.primaryLight
                    )
                )
            }
        }

        // Simple content area for now to avoid adaptive library issues
        Box(
            Modifier
                .fillMaxSize()
                .background(SolennixTheme.colors.surfaceGrouped)
        ) {
            when (selectedSection) {
                SidebarSection.DASHBOARD -> DashboardScreen(viewModel = hiltViewModel())
                SidebarSection.CLIENTS -> ClientListScreen(
                    viewModel = hiltViewModel(),
                    onClientClick = {},
                    onAddClientClick = {}
                )
                else -> PlaceholderScreen("${selectedSection.label} — Phase 6")
            }
        }
    }
}
