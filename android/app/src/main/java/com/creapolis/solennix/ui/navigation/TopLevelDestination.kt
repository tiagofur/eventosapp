package com.creapolis.solennix.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.outlined.CalendarMonth
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.MoreHoriz
import androidx.compose.material.icons.outlined.People
import androidx.compose.ui.graphics.vector.ImageVector

enum class TopLevelDestination(
    val label: String,
    val unselectedIcon: ImageVector,
    val selectedIcon: ImageVector,
    val route: String
) {
    HOME("Inicio", Icons.Outlined.Home, Icons.Filled.Home, "home"),
    CALENDAR("Calendario", Icons.Outlined.CalendarMonth, Icons.Filled.CalendarMonth, "calendar"),
    CLIENTS("Clientes", Icons.Outlined.People, Icons.Filled.People, "clients"),
    MORE("Mas", Icons.Outlined.MoreHoriz, Icons.Filled.MoreHoriz, "more")
}
