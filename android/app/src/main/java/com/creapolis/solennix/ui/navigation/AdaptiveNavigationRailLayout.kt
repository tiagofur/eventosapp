package com.creapolis.solennix.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.designsystem.theme.SolennixTitle

@Composable
fun AdaptiveNavigationRailLayout() {
    var selectedSection by remember { mutableStateOf(SidebarSection.DASHBOARD) }

    Row(Modifier.fillMaxSize()) {
        NavigationRail(
            containerColor = SolennixTheme.colors.card,
            header = {
                // Solennix logo placeholder
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
                    onClick = { selectedSection = section },
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

        // Content area
        Box(
            Modifier
                .fillMaxSize()
                .background(SolennixTheme.colors.surfaceGrouped)
        ) {
            when (selectedSection) {
                SidebarSection.DASHBOARD -> PlaceholderScreen("Dashboard — Phase 2")
                SidebarSection.SETTINGS -> PlaceholderScreen("Settings — Phase 4")
                else -> PlaceholderScreen("${selectedSection.label} — Phase 2+")
            }
        }
    }
}
