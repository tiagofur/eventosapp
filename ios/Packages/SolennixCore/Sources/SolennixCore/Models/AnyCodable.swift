import Foundation

/// A type-erased Codable wrapper for arbitrary JSON values.
/// Used for fields like `Product.recipe` that can contain any JSON structure.
public struct AnyCodable: Codable, Sendable, Hashable {
    public let value: AnyCodableValue

    public init(_ value: Any?) {
        self.value = AnyCodableValue(value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = .null
        } else if let bool = try? container.decode(Bool.self) {
            value = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            value = .int(int)
        } else if let double = try? container.decode(Double.self) {
            value = .double(double)
        } else if let string = try? container.decode(String.self) {
            value = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            value = .array(array.map(\.value))
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = .object(dict.mapValues(\.value))
        } else {
            value = .null
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

// MARK: - AnyCodableValue

public enum AnyCodableValue: Sendable, Hashable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([AnyCodableValue])
    case object([String: AnyCodableValue])

    init(_ value: Any?) {
        guard let value else {
            self = .null
            return
        }
        switch value {
        case let bool as Bool:
            self = .bool(bool)
        case let int as Int:
            self = .int(int)
        case let double as Double:
            self = .double(double)
        case let string as String:
            self = .string(string)
        case let array as [Any?]:
            self = .array(array.map { AnyCodableValue($0) })
        case let dict as [String: Any?]:
            self = .object(dict.mapValues { AnyCodableValue($0) })
        default:
            self = .null
        }
    }

    func encode(to container: inout SingleValueEncodingContainer) throws {
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let val):
            try container.encode(val)
        case .int(let val):
            try container.encode(val)
        case .double(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        case .array(let vals):
            try container.encode(vals.map { AnyCodable(wrapping: $0) })
        case .object(let dict):
            try container.encode(dict.mapValues { AnyCodable(wrapping: $0) })
        }
    }
}

// MARK: - Internal helpers

extension AnyCodable {
    fileprivate init(wrapping value: AnyCodableValue) {
        self.value = value
    }
}
