import Foundation
import TipKit

// MARK: - Tips

public struct NewEventTip: Tip {
    public var title: Text {
        Text("Crear un Evento")
    }
    
    public var message: Text? {
        Text("Toca aquí para iniciar la creación de un nuevo evento, cotización o contrato.")
    }
    
    public var image: Image? {
        Image(systemName: "calendar.badge.plus")
    }
    
    public init() {}
}

public struct QuickQuoteTip: Tip {
    public var title: Text {
        Text("Cotización Rápida")
    }
    
    public var message: Text? {
        Text("Usa esta herramienta para generar un presupuesto en el momento sin necesidad de crear el cliente primero.")
    }
    
    public var image: Image? {
        Image(systemName: "doc.text.magnifyingglass")
    }
    
    public init() {}
}

public struct SwipeActionTip: Tip {
    public var title: Text {
        Text("Acciones Rápidas")
    }
    
    public var message: Text? {
        Text("Desliza los elementos de la lista hacia la izquierda o derecha para ver más opciones como editar, eliminar o llamar.")
    }
    
    public var image: Image? {
        Image(systemName: "hand.draw")
    }
    
    public init() {}
}

// MARK: - Configuration

public struct TipsHelper {
    public static func configure() {
        // Run this in AppDelegate or App init
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
}

