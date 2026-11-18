// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// AnyEncodable is compiled with this file. The macOS CodecUtility.swift is a
// symlink to the iOS source, so this covers both platforms.
//
// swiftc -o codec-check \
//   Sources/cloud_functions/CodecUtility.swift \
//   Tests/CodecUtilityEncodingTests.swift \
//   && ./codec-check

import Foundation

func encodedJSON(_ value: Any) throws -> String {
  let data = try JSONEncoder().encode(AnyEncodable(value))
  guard let json = String(data: data, encoding: .utf8) else {
    throw TestFailure("encoded data is not UTF-8")
  }
  return json
}

struct TestFailure: Error, CustomStringConvertible {
  let description: String
  init(_ description: String) { self.description = description }
}

func expect(_ condition: Bool, _ message: String) throws {
  if !condition {
    throw TestFailure(message)
  }
}

func expectJSON(_ value: Any, equals expected: String, _ label: String) throws {
  let actual = try encodedJSON(value)
  try expect(actual == expected, "\(label): expected \(expected), got \(actual)")
}

func expectNumber(_ value: Any, equals expected: Double, _ label: String) throws {
  let json = try encodedJSON(value)
  try expect(json != "true" && json != "false", "\(label) encoded as a boolean: \(json)")
  let data = Data(json.utf8)
  let parsed = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  guard let number = parsed as? NSNumber else {
    throw TestFailure("\(label) did not decode as a number: \(json)")
  }
  try expect(
    CFGetTypeID(number) != CFBooleanGetTypeID(),
    "\(label) decoded as CFBoolean: \(json)"
  )
  try expect(number.doubleValue == expected, "\(label): expected \(expected), got \(number)")
}

func runTests() throws {
  let cases: [(String, Any, Double)] = [
    ("double 0", NSNumber(value: 0.0), 0),
    ("double 1", NSNumber(value: 1.0), 1),
    ("double -1", NSNumber(value: -1.0), -1),
    ("double 5.5", NSNumber(value: 5.5), 5.5),
    ("int 0", NSNumber(value: Int(0)), 0),
    ("int 1", NSNumber(value: Int(1)), 1),
    ("swift double 1", 1.0, 1),
    ("swift int 0", 0, 0),
  ]

  for (label, value, expected) in cases {
    try expectNumber(value, equals: expected, label)
  }

  try expectJSON(NSNumber(value: true), equals: "true", "NSNumber true")
  try expectJSON(NSNumber(value: false), equals: "false", "NSNumber false")
  try expectJSON(true, equals: "true", "Swift true")
  try expectJSON(false, equals: "false", "Swift false")

  try expectJSON(UInt64.max, equals: "18446744073709551615", "UInt64.max")
  try expectJSON(UInt64(Int64.max) + 1, equals: "9223372036854775808", "Int64.max + 1")
  try expectJSON(Int64.max, equals: "9223372036854775807", "Int64.max")
  try expectJSON(Int64.min, equals: "-9223372036854775808", "Int64.min")
  try expectJSON(Float(0.1), equals: "0.1", "Float 0.1")
  try expectNumber(NSNumber(value: Float(1)), equals: 1, "Float 1")

  let payload: [String: Any] = [
    "timezoneOffset": NSNumber(value: 1.0),
    "enabled": NSNumber(value: true),
    "message": "hello",
  ]
  let payloadData = try JSONEncoder().encode(AnyEncodable(payload))
  let payloadObject = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
  guard let payloadObject else {
    throw TestFailure("payload did not encode as an object")
  }
  guard let offset = payloadObject["timezoneOffset"] as? NSNumber else {
    throw TestFailure("timezoneOffset missing")
  }
  try expect(CFGetTypeID(offset) != CFBooleanGetTypeID(), "timezoneOffset became a boolean")
  try expect(offset.doubleValue == 1, "timezoneOffset was \(offset)")
  guard let enabled = payloadObject["enabled"] as? NSNumber else {
    throw TestFailure("enabled missing")
  }
  try expect(
    CFGetTypeID(enabled) == CFBooleanGetTypeID() && enabled.boolValue,
    "enabled was not true"
  )
  try expect(payloadObject["message"] as? String == "hello", "message changed")

  print("CodecUtility encoding tests passed")
}

@main
struct CodecUtilityEncodingTests {
  static func main() {
    do {
      try runTests()
    } catch {
      fputs("\(error)\n", stderr)
      exit(EXIT_FAILURE)
    }
  }
}
