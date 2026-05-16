import Foundation
import SolennixCore

// Route is now defined in SolennixCore so it can be shared across packages.

// MARK: - Tab

/// The five tabs shown in the compact (iPhone) tab bar.
public enum Tab: Int, Hashable, CaseIterable {
    case home
    case calendar
    case events
    case clients
    case more

    /// The SF Symbol icon name for this tab.
    public var iconName: String {
        switch self {
        case .home:     return "house.fill"
        case .calendar: return "calendar"
        case .events:   return "party.popper.fill"
        case .clients:  return "person.2.fill"
        case .more:     return "ellipsis"
        }
    }

    /// The localized title for this tab.
    public var title: String {
        switch self {
        case .home:     return "Inicio"
        case .calendar: return "Calendario"
        case .events:   return "Eventos"
        case .clients:  return "Clientes"
        case .more:     return "Más"
        }
    }
}

// MARK: - SidebarSection

/// Sections shown in the iPad/Mac sidebar navigation.
public enum SidebarSection: String, Hashable, CaseIterable {
    case dashboard
    case calendar
    case events
    case clients
    case personnel
    case products
    case inventory
    case paymentInbox
    case eventFormLinks
    case settings

    /// The SF Symbol icon name for this sidebar section.
    public var iconName: String {
        switch self {
        case .dashboard:       return "house.fill"
        case .calendar:        return "calendar"
        case .events:          return "party.popper.fill"
        case .clients:         return "person.2.fill"
        case .personnel:       return "person.3.fill"
        case .products:        return "shippingbox.fill"
        case .inventory:       return "archivebox.fill"
        case .paymentInbox:    return "wallet.pass.fill"
        case .eventFormLinks:  return "link"
        case .settings:        return "gearshape.fill"
        }
    }

    /// The localized title for this sidebar section.
    public var title: String {
        switch self {
        case .dashboard:       return "Inicio"
        case .calendar:        return "Calendario"
        case .events:          return "Eventos"
        case .clients:         return "Clientes"
        case .personnel:       return "Personal"
        case .products:        return "Productos"
        case .inventory:       return "Inventario"
        case .paymentInbox:    return "Pagos"
        case .eventFormLinks:  return "Formularios"
        case .settings:        return "Ajustes"
        }
    }
}

// MARK: - SidebarSection Navigation Metadata

extension SidebarSection {
    /// Main sidebar order for iPad/macOS.
    static let mainSections: [SidebarSection] = [
        .dashboard, .calendar, .events, .clients, .personnel, .products, .inventory, .paymentInbox, .eventFormLinks
    ]

    /// Catalog section order for the iPhone "Mas" menu.
    static let moreMenuCatalogSections: [SidebarSection] = [
        .products, .inventory, .paymentInbox, .eventFormLinks, .personnel
    ]

    /// Canonical route destination used by menu navigation.
    /// Sections that are root tabs (dashboard/calendar/events/clients)
    /// are handled by layout selection and do not have a Route case.
    var route: Route? {
        switch self {
        case .dashboard:
            return nil
        case .calendar:
            return nil
        case .events:
            return nil
        case .clients:
            return nil
        case .personnel:
            return .staffList
        case .products:
            return .productList
        case .inventory:
            return .inventoryList
        case .paymentInbox:
            return .paymentInbox
        case .eventFormLinks:
            return .eventFormLinks
        case .settings:
            return .settings
        }
    }

    /// Secondary text used by the iPhone "Mas" list rows.
    var moreMenuSubtitle: String {
        switch self {
        case .products:
            return "Catalogo y recetas"
        case .inventory:
            return "Stock de ingredientes"
        case .paymentInbox:
            return "Revision de pagos de clientes"
        case .eventFormLinks:
            return "Formularios para clientes nuevos"
        case .personnel:
            return "Colaboradores y equipo"
        case .settings:
            return "Perfil, negocio, cuenta"
        case .dashboard, .calendar, .events, .clients:
            return ""
        }
    }
}
