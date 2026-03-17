import UIKit
import SolennixCore

struct PaymentReportPDFGenerator {

    /// Generates a payment report PDF for the given event.
    static func generate(
        event: Event,
        client: Client,
        profile: User?,
        payments: [Payment]
    ) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: PDFConstants.pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            // MARK: Header
            var y = PDFConstants.drawHeader(context: context, title: "Reporte de Pagos", profile: profile)

            // MARK: Info Grid
            let leftItems: [(String, String)] = [
                ("Cliente:", client.name),
                ("Teléfono:", client.phone),
                ("Email:", client.email ?? "—")
            ]
            let rightItems: [(String, String)] = [
                ("Evento:", event.serviceType),
                ("Fecha:", PDFConstants.formatDate(event.eventDate)),
                ("Total evento:", PDFConstants.formatCurrency(event.totalAmount))
            ]
            y = PDFConstants.drawInfoGrid(context: context, y: y, leftItems: leftItems, rightItems: rightItems)
            y += 8

            // MARK: Payments Table
            y = PDFConstants.drawSectionHeader(context: context, y: y, title: "PAGOS REGISTRADOS")

            let rows: [[String]] = payments.map { payment in
                let date = PDFConstants.formatDate(payment.paymentDate)
                let method = mapPaymentMethod(payment.paymentMethod)
                let note = payment.notes ?? "—"
                let amount = PDFConstants.formatCurrency(payment.amount)
                return [date, method, note, amount]
            }

            y = PDFConstants.drawTable(
                context: context,
                y: y,
                headers: ["Fecha", "Método", "Nota", "Monto"],
                rows: rows,
                columnWidths: [0.22, 0.20, 0.33, 0.25],
                rightAlignedColumns: [3]
            )

            y += 4

            // MARK: Financial Summary
            let totalPaid = payments.reduce(0.0) { $0 + $1.amount }
            let pendingBalance = event.totalAmount - totalPaid

            y = PDFConstants.drawSummaryRow(
                context: context,
                y: y,
                label: "Total pagado:",
                value: PDFConstants.formatCurrency(totalPaid)
            )

            if pendingBalance > 0.01 {
                y = PDFConstants.drawSummaryRow(
                    context: context,
                    y: y,
                    label: "Saldo pendiente:",
                    value: PDFConstants.formatCurrency(pendingBalance),
                    valueColor: UIColor.systemRed,
                    bold: true
                )
            } else {
                y = PDFConstants.drawSummaryRow(
                    context: context,
                    y: y,
                    label: "Estado:",
                    value: "COMPLETADO",
                    valueColor: UIColor.systemGreen,
                    bold: true
                )
            }

            // MARK: Signature Box
            y += 32
            y = drawSignatureBox(context: context, y: y, client: client)

            // Page footer
            PDFConstants.drawFooterText(context: context, text: "Generado por Solennix")
        }
    }

    // MARK: - Payment Method Mapping

    private static func mapPaymentMethod(_ method: String) -> String {
        switch method.lowercased() {
        case "cash", "efectivo":
            return "Efectivo"
        case "transfer", "transferencia":
            return "Transferencia"
        case "card", "tarjeta":
            return "Tarjeta"
        case "check", "cheque":
            return "Cheque"
        default:
            return "Otro"
        }
    }

    // MARK: - Signature Box

    private static func drawSignatureBox(context: UIGraphicsPDFRendererContext, y startY: CGFloat, client: Client) -> CGFloat {
        var y = PDFConstants.ensureSpace(context: context, currentY: startY, needed: 70)

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: PDFConstants.bodyBoldFont,
            .foregroundColor: PDFConstants.textColor
        ]
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: PDFConstants.bodyFont,
            .foregroundColor: PDFConstants.grayColor
        ]

        let centerX = PDFConstants.marginLeft + (PDFConstants.contentWidth - 200) / 2

        ("Recibido por:" as NSString).draw(
            in: CGRect(x: centerX, y: y, width: 200, height: 16),
            withAttributes: labelAttrs
        )

        let lineY = y + 40
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: centerX, y: lineY))
        linePath.addLine(to: CGPoint(x: centerX + 200, y: lineY))
        linePath.lineWidth = 0.5
        PDFConstants.grayColor.setStroke()
        linePath.stroke()

        (client.name as NSString).draw(
            in: CGRect(x: centerX, y: lineY + 4, width: 200, height: 16),
            withAttributes: nameAttrs
        )

        return lineY + 24
    }
}
