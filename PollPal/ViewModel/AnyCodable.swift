//
//  AnyCodable.swift
//  PollPal
//
//  Created by student on 04/12/25.
//

import Foundation

/// Wrapper untuk menyimpan value apa pun (String, Int, Array, Dictionary, dll)
/// Ini bikin value tetap Codable meskipun tipenya dynamic.
struct AnyCodable: Codable, Equatable {

    let value: Any?

    init(_ value: Any?) {
        self.value = value
    }

    // MARK: - Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = nil
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            var result: [String: Any] = [:]
            dict.forEach { result[$0] = $1.value }
            self.value = result
        } else {
            self.value = nil
        }
    }

    // MARK: - Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case nil:
            try container.encodeNil()

        case let int as Int:
            try container.encode(int)

        case let double as Double:
            try container.encode(double)

        case let bool as Bool:
            try container.encode(bool)

        case let string as String:
            try container.encode(string)

        case let array as [Any]:
            let encodableArray = array.map { AnyCodable($0) }
            try container.encode(encodableArray)

        case let dict as [String: Any]:
            let encodableDict = dict.mapValues { AnyCodable($0) }
            try container.encode(encodableDict)

        default:
            // fallback
            let debugString = String(describing: value)
            try container.encode(debugString)
        }
    }
}

extension AnyCodable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
}
