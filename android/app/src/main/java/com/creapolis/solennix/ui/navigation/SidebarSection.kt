package com.creapolis.solennix.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

enum class SidebarSection(val label: String, val icon: ImageVector) {
    DASHBOARD("Inicio", Icons.Filled.Home),
    CALENDAR("Calendario", Icons.Filled.CalendarMonth),
    CLIENTS("Clientes", Icons.Filled.People),
    PRODUCTS("Productos", Icons.Filled.Inventory2),
    INVENTORY("Inventario", Icons.Filled.Archive),
    SEARCH("Buscar", Icons.Filled.Search),
    SETTINGS("Ajustes", Icons.Filled.Settings)
}
