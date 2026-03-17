import UIKit
import SolennixCore

struct InvoicePDFGenerator {

    /// Generates an invoice PDF for the given event.
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
            var y = PDFConstants.drawHeader(context: context, title: "Factura", profile: profile)

            // MARK: Invoice Number & Date
            let invoiceId = "INV-\(String(event.id.prefix(8)).uppercased())"
            let todayFormatted = PDFConstants.dateFormatter.string(from: Date())

            let invoiceInfoAttrs: [NSAttributedString.Key: Any] = [
                .font: PDFConstants.bodyBoldFont,
                .foregroundColor: PDFConstants.textColor
            ]
            let invoiceValueAttrs: [NSAttributedString.Key: Any] = [
                .font: PDFConstants.bodyFont,
                .foregroundColor: PDFConstants.textColor
            ]

            let rightStyle = NSMutableParagraphStyle()
            rightStyle.alignment = .right
            var rightInfoAttrs = invoiceInfoAttrs
            rightInfoAttrs[.paragraphStyle] = rightStyle
            var rightValueAttrs = invoiceValueAttrs
            rightValueAttrs[.paragraphStyle] = rightStyle

            // Invoice number (right aligned)
            ("No. Factura:" as NSString).draw(
                in: CGRect(x: PDFConstants.marginLeft, y: y, width: PDFConstants.contentWidth * 0.7, height: 16),
                withAttributes: rightInfoAttrs
            )
            (invoiceId as NSString).draw(
                in: CGRect(x: PDFConstants.marginLeft + PDFConstants.contentWidth * 0.72, y: y, width: PDFConstants.contentWidth * 0.28, height: 16),
                withAttributes: invoiceValueAttrs
            )
            y += 16

            ("Fecha de emisión:" as NSString).draw(
                in: CGRect(x: PDFConstants.marginLeft, y: y, width: PDFConstants.contentWidth * 0.7, height: 16),
                withAttributes: rightInfoAttrs
            )
            (todayFormatted as NSString).draw(
                in: CGRect(x: PDFConstants.marginLeft + PDFConstants.contentWidth * 0.72, y: y, width: PDFConstants.contentWidth * 0.28, height: 16),
                withAttributes: invoiceValueAttrs
            )
            y += 24

            // MARK: Emisor & Receptor
            let colWidth = PDFConstants.contentWidth / 2 - 10
            let leftX = PDFConstants.marginLeft
            let rightX = PDFConstants.marginLeft + PDFConstants.contentWidth / 2 + 10

            let sectionLabelAttrs: [NSAttributedString.Key: Any] = [
                .font: PDFConstants.sectionHeaderFont,
                .foregroundColor: PDFConstants.brandColor
            ]
            let fieldLabelAttrs: [NSAttributedString.Key: Any] = [
                .font: PDFConstants.bodyBoldFont,
                .foregroundColor: PDFConstants.grayColor
            ]
            let fieldValueAttrs: [NSAttributedString.Key: Any] = [
                .font: PDFConstants.bodyFont,
                .foregroundColor: PDFConstants.textColor
            ]
            let lineHeight: CGFloat = 15

            // Emisor
            ("EMISOR" as NSString).draw(
                in: CGRect(x: leftX, y: y, width: colWidth, height: 18),
                withAttributes: sectionLabelAttrs
            )
            // Receptor
            ("RECEPTOR" as NSString).draw(
                in: CGRect(x: rightX, y: y, width: colWidth, height: 18),
                withAttributes: sectionLabelAttrs
            )
            y += 20

            // Emisor details
            let emisorFields: [(String, String)] = [
                ("Nombre:", profile?.businessName ?? profile?.name ?? "—"),
                ("Email:", profile?.email ?? "—")
            ]

            let receptorFields: [(String, String)] = [
                ("Nombre:", client.name),
                ("Teléfono:", client.phone),
                ("Email:", client.email ?? "—"),
                ("Dirección:", client.address ?? "—")
            ]

            let maxFields = max(emisorFields.count, receptorFields.count)
            for i in 0..<maxFields {
                if i < emisorFields.count {
                    let (label, value) = emisorFields[i]
                    (label as NSString).draw(
                        in: CGRect(x: leftX, y: y, width: colWidth * 0.35, height: lineHeight),
                        withAttributes: fieldLabelAttrs
                    )
                    (value as NSString).draw(
                        in: CGRect(x: leftX + colWidth * 0.35, y: y, width: colWidth * 0.65, height: lineHeight),
                        withAttributes: fieldValueAttrs
                    )
                }
                if i < receptorFields.count {
                    let (label, value) = receptorFields[i]
                    (label as NSString).draw(
                        in: CGRect(x: rightX, y: y, width: colWidth * 0.35, height: lineHeight),
                        withAttributes: fieldLabelAttrs
                    )
                    (value as NSString).draw(
                        in: CGRect(x: rightX + colWidth * 0.35, y: y, width: colWidth * 0.65, height: lineHeight),
                        withAttributes: fieldValueAttrs
                    )
                }
                y += lineHeight
            }
            y += 12

            // MARK: Event Details
            let eventLeftItems: [(String, String)] = [
                ("Evento:", event.serviceType),
                ("Personas:", "\(event.numPeople)")
            ]
            let eventRightItems: [(String, String)] = [
                ("Fecha evento:", PDFConstants.formatDate(event.eventDate)),
                ("Ubicación:", event.location ?? "—")
            ]
            y = PDFConstants.drawInfoGrid(context: context, y: y, leftItems: eventLeftItems, rightItems: eventRightItems)
            y += 4

            // MARK: Conceptos Table
            y = PDFConstants.drawSectionHeader(context: context, y: y, title: "CONCEPTOS")

            var tableRows: [[String]] = []

            for product in products {
                let name = productNames[product.productId] ?? "Producto"
                let qty = "\(product.quantity)"
                let unitPrice = PDFConstants.formatCurrency(product.unitPrice)
                let discountStr: String
                if product.discount > 0 {
                    discountStr = PDFConstants.formatCurrency(product.discount)
                } else {
                    discountStr = "—"
                }
                let lineTotal = (product.totalPrice ?? (Double(product.quantity) * product.unitPrice))
                let subtotalStr = PDFConstants.formatCurrency(lineTotal)
                tableRows.append([name, qty, unitPrice, discountStr, subtotalStr])
            }

            for extra in extras {
                let priceStr = PDFConstants.formatCurrency(extra.price)
                tableRows.append([extra.description, "1", priceStr, "—", priceStr])
            }

            y = PDFConstants.drawTable(
                context: context,
                y: y,
                headers: ["Descripción", "Cant.", "Precio Unit.", "Desc.", "Subtotal"],
                rows: tableRows,
                columnWidths: [0.35, 0.08, 0.20, 0.15, 0.22],
                rightAlignedColumns: [1, 2, 3, 4]
            )

            y += 4

            // MARK: Financial Summary
            let productsSubtotal = products.reduce(0.0) { sum, p in
                sum + (p.totalPrice ?? (Double(p.quantity) * p.unitPrice))
            }
            let extrasSubtotal = extras.reduce(0.0) { $0 + $1.price }
            let subtotal = productsSubtotal + extrasSubtotal

            y = PDFConstants.drawSummaryRow(context: context, y: y, label: "Subtotal:", value: PDFConstants.formatCurrency(subtotal))

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

            if event.taxRate > 0 {
                y = PDFConstants.drawSummaryRow(
                    context: context,
                    y: y,
                    label: "IVA (\(Int(event.taxRate))%):",
                    value: PDFConstants.formatCurrency(event.taxAmount)
                )
            }

            // Total with brand color background
            PDFConstants.drawSeparator(context: context, y: y, color: PDFConstants.brandColor, thickness: 1.5)
            y += 6

            y = PDFConstants.drawSummaryRow(
                context: context,
                y: y,
                label: "TOTAL:",
                value: PDFConstants.formatCurrency(event.totalAmount),
                valueColor: PDFConstants.brandColor,
                bold: true
            )

            // MARK: Footer Notes
            y += 16
            y = PDFConstants.drawBodyText(
                context: context,
                y: y,
                text: "Esta factura se emite como comprobante de los servicios contratados. Para cualquier aclaración, contactar al emisor."
            )

            // Page footer
            PDFConstants.drawFooterText(context: context, text: "Generado por Solennix")
        }
    }
}
