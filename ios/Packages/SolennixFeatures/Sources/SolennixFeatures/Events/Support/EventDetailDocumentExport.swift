import Foundation

public enum EventDetailDocumentExport {

    public struct Option: Sendable {
        public let key: String
        public let labelKey: String
        public let defaultLabel: String
        public let icon: String

        public init(key: String, labelKey: String, defaultLabel: String, icon: String) {
            self.key = key
            self.labelKey = labelKey
            self.defaultLabel = defaultLabel
            self.icon = icon
        }
    }

    public static let options: [Option] = [
        Option(key: "cotizacion", labelKey: "events.detail.documents.quote", defaultLabel: "Cotizacion", icon: "doc.text"),
        Option(key: "contrato", labelKey: "events.detail.documents.contract", defaultLabel: "Contrato", icon: "doc.richtext"),
        Option(key: "insumos", labelKey: "events.detail.documents.supplies", defaultLabel: "Lista de insumos", icon: "list.clipboard"),
        Option(key: "equipo", labelKey: "events.detail.documents.equipment", defaultLabel: "Lista de equipo", icon: "wrench.and.screwdriver"),
        Option(key: "checklist", labelKey: "events.detail.documents.checklist", defaultLabel: "Checklist", icon: "checklist"),
        Option(key: "pagos", labelKey: "events.detail.documents.payments", defaultLabel: "Pagos", icon: "dollarsign.circle"),
    ]

    public static func resolve(
        for key: String,
        eventServiceType: String,
        clientName: String?,
        localize: (String, String) -> String,
        locale: Locale
    ) -> (pdfType: String, filename: String)? {
        guard let config = configurations[key] else { return nil }

        let rawComponent: String
        if config.usesClientName,
           let clientName,
           !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            rawComponent = clientName
        } else {
            rawComponent = eventServiceType
        }

        let safeComponent = sanitizedFileComponent(rawComponent)
        let template = localize(config.filenameKey, config.defaultFilenameTemplate)
        let filename = String(format: template, locale: locale, safeComponent)
        return (config.pdfType, filename)
    }

    public static func sanitizedFileComponent(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: " ", with: "_")
    }

    private struct ExportConfig {
        let pdfType: String
        let filenameKey: String
        let defaultFilenameTemplate: String
        let usesClientName: Bool
    }

    private static let configurations: [String: ExportConfig] = [
        "cotizacion": ExportConfig(
            pdfType: "budget",
            filenameKey: "events.detail.documents.filename.quote",
            defaultFilenameTemplate: "Quote_%@.pdf",
            usesClientName: false
        ),
        "contrato": ExportConfig(
            pdfType: "contract",
            filenameKey: "events.detail.documents.filename.contract",
            defaultFilenameTemplate: "Contract_%@.pdf",
            usesClientName: true
        ),
        "insumos": ExportConfig(
            pdfType: "shopping-list",
            filenameKey: "events.detail.documents.filename.supplies",
            defaultFilenameTemplate: "Supplies_%@.pdf",
            usesClientName: false
        ),
        "equipo": ExportConfig(
            pdfType: "equipment-list",
            filenameKey: "events.detail.documents.filename.equipment",
            defaultFilenameTemplate: "Equipment_%@.pdf",
            usesClientName: false
        ),
        "checklist": ExportConfig(
            pdfType: "checklist",
            filenameKey: "events.detail.documents.filename.checklist",
            defaultFilenameTemplate: "Checklist_%@.pdf",
            usesClientName: false
        ),
        "pagos": ExportConfig(
            pdfType: "payment-report",
            filenameKey: "events.detail.documents.filename.payments",
            defaultFilenameTemplate: "Payments_%@.pdf",
            usesClientName: true
        ),
    ]
}
