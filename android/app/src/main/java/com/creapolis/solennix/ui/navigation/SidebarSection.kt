package com.creapolis.solennix.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

enum class SidebarSection(val label: String, val icon: ImageVector, val route: String) {
    DASHBOARD("Inicio", Icons.Default.Home, "home"),
    CALENDAR("Calendario", Icons.Default.DateRange, "calendar"),
    EVENTS("Eventos", Icons.Default.Event, "events"),
    CLIENTS("Clientes", Icons.Default.Person, "clients"),
    PRODUCTS("Productos", Icons.Default.ShoppingCart, "products"),
    INVENTORY("Inventario", Icons.Default.Inventory, "inventory"),
    QUICK_QUOTE("Cotización", Icons.Default.Description, "quick_quote"),
    SEARCH("Buscar", Icons.Default.Search, "search"),
    SETTINGS("Ajustes", Icons.Default.Settings, "settings")
}
