import UIKit
import SolennixCore

struct ShoppingListPDFGenerator {

    struct Ingredient {
        let name: String
        let quantity: Double
        let unit: String
    }

    /// Generates a shopping list PDF for the given event.
    static func generate(event: Event, profile: User?, ingredients: [Ingredient]) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: PDFConstants.pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            // MARK: Header
            var y = PDFConstants.drawHeader(context: context, title: "Lista de Insumos", profile: profile)

            // MARK: Event Info
            let leftItems: [(String, String)] = [
                ("Tipo de servicio:", event.serviceType),
                ("Personas:", "\(event.numPeople)")
            ]
            let rightItems: [(String, String)] = [
                ("Fecha:", PDFConstants.formatDate(event.eventDate)),
                ("Ubicación:", event.location ?? "—")
            ]
            y = PDFConstants.drawInfoGrid(context: context, y: y, leftItems: leftItems, rightItems: rightItems)
            y += 8

            // MARK: Ingredients Table
            y = PDFConstants.drawSectionHeader(context: context, y: y, title: "INSUMOS")

            let quantityFormatter = NumberFormatter()
            quantityFormatter.numberStyle = .decimal
            quantityFormatter.maximumFractionDigits = 2
            quantityFormatter.minimumFractionDigits = 0
            quantityFormatter.locale = Locale(identifier: "es_MX")

            let rows: [[String]] = ingredients.map { ingredient in
                let qtyStr = quantityFormatter.string(from: NSNumber(value: ingredient.quantity)) ?? "\(ingredient.quantity)"
                return [ingredient.name, qtyStr, ingredient.unit]
            }

            y = PDFConstants.drawTable(
                context: context,
                y: y,
                headers: ["Insumo", "Cantidad", "Unidad"],
                rows: rows,
                columnWidths: [0.55, 0.20, 0.25],
                rightAlignedColumns: [1]
            )

            // MARK: Summary
            y += 8
            let totalItems = ingredients.count
            y = PDFConstants.drawBodyText(
                context: context,
                y: y,
                text: "Total de insumos: \(totalItems)"
            )

            // Page footer
            PDFConstants.drawFooterText(context: context, text: "Generado por Solennix")
        }
    }
}
