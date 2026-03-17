import UIKit
import SolennixCore

struct BudgetPDFGenerator {

    /// Generates a budget PDF for the given event.
    /// - Parameters:
    ///   - event: The event to generate the budget for.
    ///   - client: The client associated with the event.
    ///   - profile: The user/business profile (optional).
    ///   - products: Products included in the event (with product names set externally if needed).
    ///   - extras: Extra items/services for the event.
    ///   - productNames: Dictionary mapping productId -> display name.
    /// - Returns: PDF data.
    static func generate(
        event: Event,
        client: Client,
        profile: User?,
        products: [EventProduct],
        extras: [EventExtra],
        productNames: [String: String] = [:]
    ) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: PDFConstants.pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            // MARK: Header
            var y = PDFConstants.drawHeader(context: context, title: "Presupuesto", profile: profile)

            // MARK: Client Info Grid
            let leftItems: [(String, String)] = [
                ("Cliente:", client.name),
                ("Teléfono:", client.phone),
                ("Email:", client.email ?? "—")
            ]
            let rightItems: [(String, String)] = [
                ("Fecha evento:", PDFConstants.formatDate(event.eventDate)),
                ("Tipo servicio:", event.serviceType),
                ("Personas:", "\(event.numPeople)")
            ]
            y = PDFConstants.drawInfoGrid(context: context, y: y, leftItems: leftItems, rightItems: rightItems)
            y += 8

            // MARK: Products & Extras Table
            y = PDFConstants.drawSectionHeader(context: context, y: y, title: "DETALLE")

            var tableRows: [[String]] = []

            for product in products {
                let name = productNames[product.productId] ?? "Producto"
                let qty = "\(product.quantity)"
                let unitPrice = PDFConstants.formatCurrency(product.unitPrice)
                let total = PDFConstants.formatCurrency(product.totalPrice ?? (Double(product.quantity) * product.unitPrice))
                tableRows.append([name, qty, unitPrice, total])
            }

            for extra in extras {
                let total = PDFConstants.formatCurrency(extra.price)
                tableRows.append([extra.description, "1", total, total])
            }

            y = PDFConstants.drawTable(
                context: context,
                y: y,
                headers: ["Descripción", "Cant.", "Precio Unit.", "Total"],
                rows: tableRows,
                columnWidths: [0.45, 0.10, 0.22, 0.23],
                rightAlignedColumns: [1, 2, 3]
            )

            y += 4

            // MARK: Financial Summary
            let productsSubtotal = products.reduce(0.0) { sum, p in
                sum + (p.totalPrice ?? (Double(p.quantity) * p.unitPrice))
            }
            let extrasSubtotal = extras.reduce(0.0) { $0 + $1.price }
            let subtotal = productsSubtotal + extrasSubtotal

            y = PDFConstants.drawSummaryRow(context: context, y: y, label: "Subtotal:", value: PDFConstants.formatCurrency(subtotal))

            // Discount
            if event.discount > 0 {
                let discountLabel: String
                let discountValue: Double
                if event.discountType == .percent {
                    discountLabel = "Descuento (\(Int(event.discount))%):"
                    discountValue = subtotal * (event.discount / 100)
                } else {
                    discountLabel = "Descuento:"
                    discountValue = event.discount
                }
                y = PDFConstants.drawSummaryRow(context: context, y: y, label: discountLabel, value: "- \(PDFConstants.formatCurrency(discountValue))")
            }

            // IVA
            if event.taxRate > 0 {
                let taxLabel = "IVA (\(Int(event.taxRate))%):"
                y = PDFConstants.drawSummaryRow(context: context, y: y, label: taxLabel, value: PDFConstants.formatCurrency(event.taxAmount))
            }

            // Separator before total
            PDFConstants.drawSeparator(context: context, y: y, color: PDFConstants.brandColor, thickness: 1)
            y += 6

            // Total
            y = PDFConstants.drawSummaryRow(
                context: context,
                y: y,
                label: "TOTAL:",
                value: PDFConstants.formatCurrency(event.totalAmount),
                valueColor: PDFConstants.brandColor,
                bold: true
            )

            // MARK: Deposit info
            if let depositPercent = event.depositPercent, depositPercent > 0 {
                y += 8
                let depositAmount = event.totalAmount * (depositPercent / 100)
                y = PDFConstants.drawBodyText(
                    context: context,
                    y: y,
                    text: "Anticipo requerido (\(Int(depositPercent))%): \(PDFConstants.formatCurrency(depositAmount))"
                )
            }

            // MARK: Footer Note
            y += 12
            y = PDFConstants.drawBodyText(
                context: context,
                y: y,
                text: "Este presupuesto es válido por 15 días a partir de la fecha de emisión. Los precios pueden estar sujetos a cambios sin previo aviso."
            )

            // Page footer
            PDFConstants.drawFooterText(context: context, text: "Generado por Solennix")
        }
    }
}
