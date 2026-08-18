// Copyright 2025 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import Foundation

public struct AnyEncodable: Encodable {
  private let value: Any?

  public init(_ value: Any?) {
    self.value = value ?? NSNull()
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch value {
    case is NSNull:
      try container.encodeNil()
    case let stringValue as String:
      try container.encode(stringValue)
    case let boolValue as Bool:
      try container.encode(boolValue)
    case let intValue as Int:
      try container.encode(intValue)
    case let int8Value as Int8:
      try container.encode(int8Value)
    case let int16Value as Int16:
      try container.encode(int16Value)
    case let int32Value as Int32:
      try container.encode(int32Value)
    case let int64Value as Int64:
      try container.encode(int64Value)
    case let uintValue as UInt:
      try container.encode(uintValue)
    case let uint8Value as UInt8:
      try container.encode(uint8Value)
    case let uint16Value as UInt16:
      try container.encode(uint16Value)
    case let uint32Value as UInt32:
      try container.encode(uint32Value)
    case let uint64Value as UInt64:
      try container.encode(uint64Value)
    case let doubleValue as Double:
      try container.encode(doubleValue)
    case let floatValue as Float:
      try container.encode(floatValue)
    case let arrayValue as [Any]:
      try container.encode(arrayValue.map { AnyEncodable($0) })
    case let dictionaryValue as [String: Any]:
      try container.encode(dictionaryValue.mapValues { AnyEncodable($0) })
    default:
      throw EncodingError.invalidValue(
        value as Any,
        EncodingError.Context(
          codingPath: encoder.codingPath,
          debugDescription: "Unsupported type: \(type(of: value))"
        )
      )
    }
  }
}

public struct AnyDecodable: Decodable {
  public let value: Any?

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      value = NSNull()
      return
    }

    if let stringValue = try? container.decode(String.self) {
      value = stringValue
    } else if let intValue = try? container.decode(Int.self) {
      value = intValue
    } else if let int8Value = try? container.decode(Int8.self) {
      value = int8Value
    } else if let int16Value = try? container.decode(Int16.self) {
      value = int16Value
    } else if let int32Value = try? container.decode(Int32.self) {
      value = int32Value
    } else if let int64Value = try? container.decode(Int64.self) {
      value = int64Value
    } else if let uintValue = try? container.decode(UInt.self) {
      value = uintValue
    } else if let uint8Value = try? container.decode(UInt8.self) {
      value = uint8Value
    } else if let uint16Value = try? container.decode(UInt16.self) {
      value = uint16Value
    } else if let uint32Value = try? container.decode(UInt32.self) {
      value = uint32Value
    } else if let uint64Value = try? container.decode(UInt64.self) {
      value = uint64Value
    } else if let doubleValue = try? container.decode(Double.self) {
      value = doubleValue
    } else if let floatValue = try? container.decode(Float.self) {
      value = floatValue
    } else if let boolValue = try? container.decode(Bool.self) {
      value = boolValue
    } else if let arrayValue = try? container.decode([AnyDecodable].self) {
      value = arrayValue.map(\.value)
    } else if let dictionaryValue = try? container.decode([String: AnyDecodable].self) {
      value = dictionaryValue.mapValues { $0.value }

    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unable to decode value of type: \(type(of: value))"
      )
    }
  }

  public init(_ value: Any?) {
    self.value = value
  }
}
