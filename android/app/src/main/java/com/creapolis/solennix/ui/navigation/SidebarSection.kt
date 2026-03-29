package com.creapolis.solennix.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

/**
 * Sidebar sections for tablet NavigationRail.
 * 7 items: 6 main sections + settings at bottom.
 * Cotización, Cotización Rápida, and Search removed — now accessible via
 * contextual buttons (FAB/toolbar) and search bar in TopAppBar.
 */
enum class SidebarSection(val label: String, val icon: ImageVector, val route: String) {
    DASHBOARD("Inicio", Icons.Default.Dashboard, "home"),
    CALENDAR("Calendario", Icons.Default.CalendarToday, "calendar"),
    EVENTS("Eventos", Icons.Default.Celebration, "events"),
    CLIENTS("Clientes", Icons.Default.People, "clients"),
    PRODUCTS("Productos", Icons.Default.Inventory2, "products"),
    INVENTORY("Inventario", Icons.Default.Widgets, "inventory"),
    SETTINGS("Configuración", Icons.Default.Settings, "settings")
}
