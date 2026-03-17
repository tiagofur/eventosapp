import Foundation

/// Represents errors that can occur during API communication.
public enum APIError: LocalizedError, Sendable {
    case unauthorized
    case networkError(String)
    case serverError(statusCode: Int, message: String)
    case decodingError
    case unknown

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Tu sesion ha expirado. Por favor inicia sesion de nuevo."
        case .networkError(let message):
            return "Error de red: \(message)"
        case .serverError(let statusCode, let message):
            return "Error del servidor (\(statusCode)): \(message)"
        case .decodingError:
            return "Error al procesar la respuesta del servidor."
        case .unknown:
            return "Ocurrio un error desconocido."
        }
    }
}
