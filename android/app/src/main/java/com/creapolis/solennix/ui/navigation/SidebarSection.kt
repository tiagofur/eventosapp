package com.creapolis.solennix.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

enum class SidebarSection(val label: String, val icon: ImageVector) {
    DASHBOARD("Inicio", Icons.Default.Home),
    CALENDAR("Calendario", Icons.Default.DateRange),
    CLIENTS("Clientes", Icons.Default.Person),
    PRODUCTS("Productos", Icons.Default.ShoppingCart),
    INVENTORY("Inventario", Icons.Default.Inventory),
    SEARCH("Buscar", Icons.Default.Search),
    SETTINGS("Ajustes", Icons.Default.Settings)
}
