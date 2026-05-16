import Foundation
import SolennixNetwork
import UIKit

enum EventPDFFileService {
    static func download(
        apiClient: APIClient,
        eventId: String,
        type: String,
        filename: String
    ) async throws -> URL {
        let pdfData = try await apiClient.getData(Endpoint.eventPDF(eventId, type: type))
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try pdfData.write(to: fileURL)
        return fileURL
    }

    @MainActor
    static func presentShareSheet(fileURL: URL) throws {
        guard let presenter = topMostViewController() else {
            throw EventPDFFileServiceError.missingPresenter
        }

        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        presenter.present(activityVC, animated: true)
    }

    @MainActor
    private static func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
              ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        else { return nil }

        var top = window.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}

enum EventPDFFileServiceError: Error {
    case missingPresenter
}