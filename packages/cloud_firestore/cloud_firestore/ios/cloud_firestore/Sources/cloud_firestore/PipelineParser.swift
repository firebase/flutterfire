// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import FirebaseFirestore
import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#endif

private let kPipelineNotAvailable =
  "Pipeline API is not available. Firestore Pipelines require Firebase iOS SDK with pipeline support."
private let kPipelineErrorDomain = "FLTFirebaseFirestore"
private let kPipelineParseErrorCode = -1
private let kMaxPipelineExpressionDepth = 64
private let kMaxPipelineStageDepth = 32

private let kBinaryNames: [String] = [
  "equal", "not_equal", "greater_than", "greater_than_or_equal", "less_than",
  "less_than_or_equal", "add", "subtract", "multiply", "divide", "mod", "bit_and",
  "bit_or", "bit_left_shift", "bit_right_shift",
]

private let kFilterComparisonKeys: [String] = [
  "isEqualTo", "isNotEqualTo", "isGreaterThan", "isGreaterThanOrEqualTo", "isLessThan",
  "isLessThanOrEqualTo", "arrayContains", "arrayContainsAny", "whereIn", "whereNotIn",
  "isNull", "isNotNull",
]

private func pipelineUnavailableError() -> NSError {
  NSError(
    domain: kPipelineErrorDomain,
    code: kPipelineParseErrorCode,
    userInfo: [NSLocalizedDescriptionKey: kPipelineNotAvailable]
  )
}

private func parseError(_ message: String) -> NSError {
  NSError(
    domain: kPipelineErrorDomain,
    code: kPipelineParseErrorCode,
    userInfo: [NSLocalizedDescriptionKey: message]
  )
}

private func asMap(_ value: Any?) -> [String: Any]? {
  guard let value, !(value is NSNull) else { return nil }
  if let dict = value as? [String: Any] {
    return dict
  }
  if let dict = value as? [String: Any?] {
    var result: [String: Any] = [:]
    for (key, nested) in dict {
      result[key] = nested ?? NSNull()
    }
    return result
  }
  if let dict = value as? [AnyHashable: Any] {
    var result: [String: Any] = [:]
    for (key, nested) in dict {
      if let key = key as? String {
        result[key] = nested
      }
    }
    return result
  }
  return nil
}

private func asArray(_ value: Any?) -> [Any]? {
  guard let value, !(value is NSNull) else { return nil }
  if let array = value as? [Any] {
    return array
  }
  if let array = value as? NSArray {
    return array.map { $0 as Any }
  }
  return nil
}

private func dictionaryFromOptionalKeyed(_ map: [String: Any?]) -> [String: Any] {
  var result: [String: Any] = [:]
  for (key, value) in map {
    result[key] = value ?? NSNull()
  }
  return result
}

private func nestedValue(_ map: [String: Any], keyPath: String) -> Any? {
  let parts = keyPath.split(separator: ".").map(String.init)
  var current: Any? = map
  for part in parts {
    guard let currentMap = asMap(current) else { return nil }
    current = currentMap[part]
  }
  return current
}

private func toExprBridge(_ expression: any FirebaseFirestore.Expression) throws -> ExprBridge {
  if let bridge = exprBridge(from: expression) {
    return bridge
  }
  throw parseError("Could not convert pipeline expression into a native bridge")
}

/// Typed pipeline expressions must be lowered to `ExprBridge` for stage constructors.
/// `Score` and `DocumentMatches` expose a public `.bridge`. Other SDK expression types
/// (`Field`, `Constant`, `FunctionExpression`, internal boolean wrappers) keep `bridge`
/// internal, and `Expression.toBridge()` is also internal, so there is no supported public
/// accessor. Mirror is the same approach React Native Firebase uses until Firebase exposes one.
private func exprBridge(from value: Any) -> ExprBridge? {
  if let bridge = value as? ExprBridge {
    return bridge
  }
  if let score = value as? Score {
    return score.bridge
  }
  if let matches = value as? DocumentMatches {
    return matches.bridge
  }

  var mirror: Mirror? = Mirror(reflecting: value)
  while let current = mirror {
    for child in current.children {
      if child.label == "bridge", let bridge = child.value as? ExprBridge {
        return bridge
      }
    }
    mirror = current.superclassMirror
  }

  for child in Mirror(reflecting: value).children {
    if child.label == "expr" || child.label == "constant" || child.label == "field",
      let nested = exprBridge(from: child.value)
    {
      return nested
    }
  }
  return nil
}

private func sendableExpressions(_ expressions: [any FirebaseFirestore.Expression])
  -> [any Sendable]
{
  expressions.map { $0 as any Sendable }
}

private func constantExpression(from value: Any) throws -> any FirebaseFirestore.Expression {
  if value is NSNull {
    return Constant.nil
  }
  if let number = value as? NSNumber {
    if CFGetTypeID(number) == CFBooleanGetTypeID() {
      return Constant(number.boolValue)
    }
    let doubleValue = number.doubleValue
    if doubleValue.isFinite, doubleValue.rounded() == doubleValue,
      doubleValue >= Double(Int.min), doubleValue <= Double(Int.max)
    {
      return Constant(number.intValue)
    }
    return Constant(number.doubleValue)
  }
  if let stringValue = value as? String {
    return Constant(stringValue)
  }
  if let boolValue = value as? Bool {
    return Constant(boolValue)
  }
  if let intValue = value as? Int {
    return Constant(intValue)
  }
  if let doubleValue = value as? Double {
    return Constant(doubleValue)
  }
  if let dateValue = value as? Date {
    return Constant(dateValue)
  }
  if let timestampValue = value as? Timestamp {
    return Constant(timestampValue)
  }
  if let geoPointValue = value as? GeoPoint {
    return Constant(geoPointValue)
  }
  if let referenceValue = value as? DocumentReference {
    return Constant(referenceValue)
  }
  if let vectorValue = value as? VectorValue {
    return Constant(vectorValue)
  }
  if let data = value as? Data {
    return Constant(data)
  }
  if let typedData = value as? FlutterStandardTypedData {
    return Constant(typedData.data)
  }
  throw parseError("Unsupported constant value: \(type(of: value))")
}

private func functionExpression(
  name: String,
  args: [any FirebaseFirestore.Expression]
) -> FunctionExpression {
  FunctionExpression(functionName: name, args: args)
}

private final class PipelineExpressionParser {
  let firestore: Firestore
  private var expressionDepth = 0

  init(firestore: Firestore) {
    self.firestore = firestore
  }

  func parseExpression(_ map: [String: Any]) throws -> ExprBridge {
    try toExprBridge(parseTypedExpression(map))
  }

  func parseBooleanExpression(_ map: [String: Any]) throws -> ExprBridge {
    try toExprBridge(parseBooleanTypedExpression(map))
  }

  private func parseBooleanTypedExpression(_ map: [String: Any]) throws
    -> any FirebaseFirestore.BooleanExpression
  {
    let expression = try parseTypedExpression(map)
    if let booleanExpression = expression as? any FirebaseFirestore.BooleanExpression {
      return booleanExpression
    }
    return expression.asBoolean()
  }

  private func parseTypedExpressions(
    _ maps: [Any],
    errorMessage: String
  ) throws
    -> [any FirebaseFirestore.Expression]
  {
    var expressions: [any FirebaseFirestore.Expression] = []
    for value in maps {
      guard let map = asMap(value) else { continue }
      try expressions.append(parseTypedExpression(map))
    }
    if expressions.isEmpty {
      throw parseError(errorMessage)
    }
    return expressions
  }

  private func parseTypedExpression(_ map: [String: Any]) throws -> any FirebaseFirestore
    .Expression
  {
    expressionDepth += 1
    defer { expressionDepth -= 1 }
    if expressionDepth > kMaxPipelineExpressionDepth {
      throw parseError("Pipeline expression nested too deeply")
    }

    let name = map["name"] as? String
    if name == nil {
      if let args = asMap(map["args"]), let field = args["field"] as? String {
        return Field(field)
      }
      throw parseError("Expression must have a 'name' field")
    }

    let resolvedName = name!
    let args = asMap(map["args"]) ?? [:]

    if resolvedName == "field" {
      guard let field = args["field"] as? String else {
        throw parseError("Field expression requires 'field' argument")
      }
      return Field(field)
    }

    if resolvedName == "constant" {
      guard let value = args["value"] else {
        throw parseError("Constant requires 'value' argument")
      }
      if let valueMap = asMap(value), let path = valueMap["path"] as? String {
        return Constant(firestore.document(path))
      }
      return try constantExpression(from: value)
    }

    if resolvedName == "alias" {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("Alias requires 'expression'")
      }
      return try parseTypedExpression(exprMap)
    }

    if resolvedName == "null" {
      return Constant.nil
    }

    if resolvedName == "score" {
      return Score()
    }

    if resolvedName == "document_id_from_ref" {
      guard let path = args["doc_ref"] as? String, !path.isEmpty else {
        throw parseError("document_id_from_ref requires doc_ref path")
      }
      return Constant(firestore.document(path)).documentId()
    }

    if resolvedName == "as_boolean" {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("as_boolean requires expression")
      }
      return try parseBooleanTypedExpression(exprMap)
    }

    if resolvedName == "document_matches" {
      guard let query = args["query"] as? String else {
        throw parseError("document_matches requires query")
      }
      return DocumentMatches(query)
    }

    var sdkName = resolvedName
    if resolvedName == "bit_xor" { sdkName = "xor" }
    if resolvedName == "modulo" { sdkName = "mod" }

    if kBinaryNames.contains(sdkName) || resolvedName == "bit_xor" {
      guard let leftMap = asMap(args["left"]), let rightMap = asMap(args["right"]) else {
        throw parseError("\(resolvedName) requires left and right expressions")
      }
      let left = try parseTypedExpression(leftMap)
      let right = try parseTypedExpression(rightMap)
      switch sdkName {
      case "equal":
        return left.equal(right)
      case "not_equal":
        return left.notEqual(right)
      case "greater_than":
        return left.greaterThan(right)
      case "greater_than_or_equal":
        return left.greaterThanOrEqual(right)
      case "less_than":
        return left.lessThan(right)
      case "less_than_or_equal":
        return left.lessThanOrEqual(right)
      case "add":
        return left.add(right)
      case "subtract":
        return left.subtract(right)
      case "multiply":
        return left.multiply(right)
      case "divide":
        return left.divide(right)
      case "mod":
        return left.mod(right)
      default:
        return functionExpression(name: sdkName, args: [left, right])
      }
    }

    if resolvedName == "exists" || resolvedName == "is_error" || resolvedName == "is_absent"
      || resolvedName == "not"
    {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("\(resolvedName) requires expression")
      }
      if resolvedName == "not" {
        return try !parseBooleanTypedExpression(exprMap)
      }
      let expr = try parseTypedExpression(exprMap)
      switch resolvedName {
      case "exists":
        return expr.exists()
      case "is_error":
        return expr.isError()
      default:
        return expr.isAbsent()
      }
    }

    if [
      "length", "to_lower_case", "to_upper_case", "trim", "abs", "array_length",
      "array_reverse", "bit_not", "document_id", "collection_id",
    ].contains(resolvedName) {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("\(resolvedName) requires expression")
      }
      let expr = try parseTypedExpression(exprMap)
      switch resolvedName {
      case "length":
        return expr.length()
      case "to_lower_case":
        return expr.toLower()
      case "to_upper_case":
        return expr.toUpper()
      case "trim":
        return expr.trim()
      case "abs":
        return expr.abs()
      case "array_length":
        return expr.arrayLength()
      case "array_reverse":
        return expr.arrayReverse()
      case "document_id":
        return expr.documentId()
      case "collection_id":
        return expr.collectionId()
      default:
        return functionExpression(name: resolvedName, args: [expr])
      }
    }

    if resolvedName == "and" || resolvedName == "or" || resolvedName == "xor"
      || resolvedName == "nor"
    {
      guard let exprMaps = asArray(args["expressions"]), !exprMaps.isEmpty else {
        throw parseError("\(resolvedName) requires at least one expression")
      }
      var booleanExprs: [any FirebaseFirestore.BooleanExpression] = []
      for em in exprMaps {
        guard let emMap = asMap(em) else { continue }
        try booleanExprs.append(parseBooleanTypedExpression(emMap))
      }
      guard let first = booleanExprs.first else {
        throw parseError("\(resolvedName) requires at least one expression")
      }
      if resolvedName == "and" {
        return booleanExprs.dropFirst().reduce(first) { $0 && $1 }
      }
      if resolvedName == "or" {
        return booleanExprs.dropFirst().reduce(first) { $0 || $1 }
      }
      if resolvedName == "xor" {
        return booleanExprs.dropFirst().reduce(first) { $0 ^ $1 }
      }
      return !(booleanExprs.dropFirst().reduce(first) { $0 || $1 })
    }

    if resolvedName == "equal_any" || resolvedName == "not_equal_any" {
      let valuesMaps = asArray(args["values"])
      guard let valueMap = asMap(args["value"]),
        let valuesMaps, !valuesMaps.isEmpty
      else {
        throw parseError("\(resolvedName) requires value and non-empty values")
      }
      let valueExpr = try parseTypedExpression(valueMap)
      let valueExprs = try parseTypedExpressions(
        valuesMaps,
        errorMessage: "\(resolvedName) requires at least one value"
      )
      if resolvedName == "equal_any" {
        return valueExpr.equalAny(valueExprs)
      }
      return valueExpr.notEqualAny(valueExprs)
    }

    if resolvedName == "array_contains" {
      guard let arrayMap = asMap(args["array"]), let elementMap = asMap(args["element"]) else {
        throw parseError("array_contains requires array and element")
      }
      return try parseTypedExpression(arrayMap)
        .arrayContains(parseTypedExpression(elementMap))
    }

    if resolvedName == "array_contains_all" || resolvedName == "array_contains_any" {
      guard let arrayMap = asMap(args["array"]) else {
        throw parseError("\(resolvedName) requires array")
      }
      let arrayExpr = try parseTypedExpression(arrayMap)

      var valuesMaps = asArray(args["values"])
      if valuesMaps == nil {
        valuesMaps = asArray(args["elements"])
      }

      if let valuesMaps, !valuesMaps.isEmpty {
        let valueExprs = try parseTypedExpressions(
          valuesMaps,
          errorMessage: "\(resolvedName) requires at least one value"
        )
        if resolvedName == "array_contains_all" {
          return arrayExpr.arrayContainsAll(valueExprs)
        }
        return arrayExpr.arrayContainsAny(valueExprs)
      }

      if resolvedName == "array_contains_all",
        let arrayExpressionMap = asMap(args["array_expression"])
      {
        return try arrayExpr.arrayContainsAll(parseTypedExpression(arrayExpressionMap))
      }

      throw parseError(
        "\(resolvedName) requires array and values/elements, or array_contains_all with array_expression"
      )
    }

    if resolvedName == "concat" {
      guard let exprMaps = asArray(args["expressions"]), !exprMaps.isEmpty else {
        throw parseError("concat requires non-empty expressions")
      }
      let expressions = try parseTypedExpressions(
        exprMaps,
        errorMessage: "concat requires at least one expression"
      )
      if expressions.count == 1 {
        return expressions[0]
      }
      return expressions[0].concat(sendableExpressions(Array(expressions.dropFirst())))
    }

    if resolvedName == "substring" {
      guard let exprMap = asMap(args["expression"]),
        let startMap = asMap(args["start"]),
        let endMap = asMap(args["end"])
      else {
        throw parseError("substring requires expression, start, and end")
      }
      return try parseTypedExpression(exprMap).substring(
        position: parseTypedExpression(startMap),
        length: parseTypedExpression(endMap)
      )
    }

    if resolvedName == "replace" || resolvedName == "string_replace_all" {
      guard let exprMap = asMap(args["expression"]),
        let findMap = asMap(args["find"]),
        let replacementMap = asMap(args["replacement"])
      else {
        throw parseError("\(resolvedName) requires expression, find, and replacement")
      }
      return try parseTypedExpression(exprMap).stringReplaceAll(
        parseTypedExpression(findMap),
        with: parseTypedExpression(replacementMap)
      )
    }

    if resolvedName == "string_replace_one" {
      guard let exprMap = asMap(args["expression"]),
        let findMap = asMap(args["find"]),
        let replacementMap = asMap(args["replacement"])
      else {
        throw parseError("string_replace_one requires expression, find, and replacement")
      }
      return try parseTypedExpression(exprMap).stringReplaceOne(
        parseTypedExpression(findMap),
        with: parseTypedExpression(replacementMap)
      )
    }

    if resolvedName == "string_index_of" || resolvedName == "string_repeat" {
      let argumentName = resolvedName == "string_index_of" ? "search" : "repetitions"
      guard let exprMap = asMap(args["expression"]),
        let argumentMap = asMap(args[argumentName])
      else {
        throw parseError("\(resolvedName) requires expression and \(argumentName)")
      }
      let expr = try parseTypedExpression(exprMap)
      let argument = try parseTypedExpression(argumentMap)
      if resolvedName == "string_index_of" {
        return expr.stringIndexOf(argument)
      }
      return expr.stringRepeat(argument)
    }

    if resolvedName == "ltrim" || resolvedName == "rtrim" {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("\(resolvedName) requires expression")
      }
      let expr = try parseTypedExpression(exprMap)
      guard let valueMap = asMap(args["value"]) else {
        return resolvedName == "ltrim" ? expr.ltrim() : expr.rtrim()
      }
      let value = try parseTypedExpression(valueMap)
      return resolvedName == "ltrim" ? expr.ltrim(value) : expr.rtrim(value)
    }

    if resolvedName == "split" || resolvedName == "join" {
      guard let exprMap = asMap(args["expression"]),
        let delimiterMap = asMap(args["delimiter"])
      else {
        throw parseError("\(resolvedName) requires expression and delimiter")
      }
      let expr = try parseTypedExpression(exprMap)
      let delimiter = try parseTypedExpression(delimiterMap)
      if resolvedName == "split" {
        return expr.split(delimiter: delimiter)
      }
      if let delimiterMap = asMap(args["delimiter"]),
        (delimiterMap["name"] as? String) == "constant",
        let delimiterValue = asMap(delimiterMap["args"])?["value"] as? String
      {
        return expr.join(delimiter: delimiterValue)
      }
      return functionExpression(name: "join", args: [expr, delimiter])
    }

    if resolvedName == "array_concat" {
      guard let firstMap = asMap(args["first"]), let secondMap = asMap(args["second"]) else {
        throw parseError("array_concat requires first and second")
      }
      return try parseTypedExpression(firstMap)
        .arrayConcat([parseTypedExpression(secondMap)])
    }

    if resolvedName == "array_concat_multiple" {
      guard let arraysMaps = asArray(args["arrays"]), !arraysMaps.isEmpty else {
        throw parseError("array_concat_multiple requires non-empty arrays")
      }
      let expressions = try parseTypedExpressions(
        arraysMaps,
        errorMessage: "array_concat_multiple requires at least one array"
      )
      if expressions.count == 1 {
        return expressions[0]
      }
      return expressions[0].arrayConcat(Array(expressions.dropFirst()))
    }

    if resolvedName == "array_slice" {
      guard let exprMap = asMap(args["expression"]), let offsetMap = asMap(args["offset"]) else {
        throw parseError("array_slice requires expression and offset")
      }
      let expr = try parseTypedExpression(exprMap)
      let offset = try parseTypedExpression(offsetMap)
      if let lengthMap = asMap(args["length"]) {
        return try expr.arraySlice(offset: offset, length: parseTypedExpression(lengthMap))
      }
      return expr.arraySlice(offset: offset)
    }

    if resolvedName == "array_filter" {
      guard let exprMap = asMap(args["expression"]),
        let alias = args["alias"] as? String,
        let filterMap = asMap(args["filter"])
      else {
        throw parseError("array_filter requires expression, alias, and filter")
      }
      return try parseTypedExpression(exprMap).arrayFilter(
        alias: alias,
        filter: parseBooleanTypedExpression(filterMap)
      )
    }

    if resolvedName == "array_transform" {
      guard let exprMap = asMap(args["expression"]),
        let elementAlias = args["element_alias"] as? String,
        let transformMap = asMap(args["transform"])
      else {
        throw parseError("array_transform requires expression, element_alias, and transform")
      }
      return try parseTypedExpression(exprMap).arrayTransform(
        elementAlias: elementAlias,
        transform: parseTypedExpression(transformMap)
      )
    }

    if resolvedName == "array_transform_with_index" {
      guard let exprMap = asMap(args["expression"]),
        let elementAlias = args["element_alias"] as? String,
        let indexAlias = args["index_alias"] as? String,
        let transformMap = asMap(args["transform"])
      else {
        throw parseError(
          "array_transform_with_index requires expression, element_alias, index_alias, and transform"
        )
      }
      return try parseTypedExpression(exprMap).arrayTransformWithIndex(
        elementAlias: elementAlias,
        indexAlias: indexAlias,
        transform: parseTypedExpression(transformMap)
      )
    }

    if resolvedName == "array" {
      guard let elementsMaps = asArray(args["elements"]), !elementsMaps.isEmpty else {
        throw parseError("array requires non-empty elements")
      }
      return try ArrayExpression(
        sendableExpressions(
          parseTypedExpressions(
            elementsMaps,
            errorMessage: "array requires at least one element"
          )
        )
      )
    }

    if resolvedName == "map" {
      guard let dataMap = asMap(args["data"]), !dataMap.isEmpty else {
        throw parseError("map requires non-empty data")
      }
      var elements: [String: any Sendable] = [:]
      for (key, rawValue) in dataMap {
        guard let valueMap = asMap(rawValue) else { continue }
        elements[key] = try parseTypedExpression(valueMap)
      }
      if elements.isEmpty {
        throw parseError("map requires at least one key-value pair")
      }
      return MapExpression(elements)
    }

    if resolvedName == "map_get" {
      guard let mapMap = asMap(args["map"]), let keyMap = asMap(args["key"]) else {
        throw parseError("map_get requires map and key")
      }
      let mapExpr = try parseTypedExpression(mapMap)
      let keyExpr = try parseTypedExpression(keyMap)
      return mapExpr.getField(keyExpr)
    }

    if resolvedName == "if_absent" {
      guard let exprMap = asMap(args["expression"]), let elseMap = asMap(args["else"]) else {
        throw parseError("if_absent requires expression and else")
      }
      return try parseTypedExpression(exprMap).ifAbsent(parseTypedExpression(elseMap))
    }

    if resolvedName == "if_error" {
      guard let exprMap = asMap(args["expression"]), let catchMap = asMap(args["catch"]) else {
        throw parseError("if_error requires expression and catch")
      }
      return try parseTypedExpression(exprMap).ifError(parseTypedExpression(catchMap))
    }

    if resolvedName == "conditional" {
      guard let conditionMap = asMap(args["condition"]),
        let thenMap = asMap(args["then"]),
        let elseMap = asMap(args["else"])
      else {
        throw parseError("conditional requires condition, then, and else")
      }
      return try ConditionalExpression(
        parseBooleanTypedExpression(conditionMap),
        then: parseTypedExpression(thenMap),
        else: parseTypedExpression(elseMap)
      )
    }

    if resolvedName == "timestamp_add" || resolvedName == "timestamp_subtract" {
      let unitVal = args["unit"]
      guard let timestampMap = asMap(args["timestamp"]),
        unitVal != nil,
        let amountMap = asMap(args["amount"])
      else {
        throw parseError("\(resolvedName) requires timestamp, unit, and amount")
      }
      let timestampExpr = try parseTypedExpression(timestampMap)
      let amountExpr = try parseTypedExpression(amountMap)
      if resolvedName == "timestamp_add" {
        if let unit = unitVal as? String {
          return timestampExpr.timestampAdd(amount: amountExpr, unit: unit)
        }
        return try timestampExpr.timestampAdd(
          amount: amountExpr,
          unit: parseTypedExpression(asMap(unitVal) ?? [:])
        )
      }
      if let unit = unitVal as? String {
        return timestampExpr.timestampSubtract(amount: amountExpr, unit: unit)
      }
      return try timestampExpr.timestampSubtract(
        amount: amountExpr,
        unit: parseTypedExpression(asMap(unitVal) ?? [:])
      )
    }

    if resolvedName == "current_timestamp" {
      return CurrentTimestamp()
    }

    if resolvedName == "timestamp_truncate" {
      let unitVal = args["unit"]
      guard let timestampMap = asMap(args["timestamp"]), unitVal != nil else {
        throw parseError("timestamp_truncate requires timestamp and unit")
      }
      let timestampExpr = try parseTypedExpression(timestampMap)
      if let unit = unitVal as? String {
        return timestampExpr.timestampTruncate(granularity: unit)
      }
      return try timestampExpr.timestampTruncate(
        granularity: parseTypedExpression(asMap(unitVal) ?? [:])
      )
    }

    if resolvedName == "map_keys" {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("map_keys requires expression")
      }
      return try parseTypedExpression(exprMap).mapKeys()
    }

    if resolvedName == "map_values" {
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("map_values requires expression")
      }
      return try parseTypedExpression(exprMap).mapValues()
    }

    if resolvedName == "parent" {
      if let docPath = args["doc_ref"] as? String, !docPath.isEmpty {
        return Constant(firestore.document(docPath)).parent()
      }
      guard let exprMap = asMap(args["expression"]) else {
        throw parseError("parent requires expression or doc_ref")
      }
      return try parseTypedExpression(exprMap).parent()
    }

    if resolvedName == "timestamp_diff" {
      let unitObj = args["unit"]
      guard let endMap = asMap(args["end"]),
        let startMap = asMap(args["start"]),
        unitObj != nil
      else {
        throw parseError("timestamp_diff requires end, start, and unit")
      }
      let endExpr = try parseTypedExpression(endMap)
      let startExpr = try parseTypedExpression(startMap)
      if let unit = unitObj as? String {
        return endExpr.timestampDiff(startExpr, unit)
      }
      guard let unitMap = asMap(unitObj) else {
        throw parseError("timestamp_diff unit must be string or expression")
      }
      return try endExpr.timestampDiff(startExpr, parseTypedExpression(unitMap))
    }

    if resolvedName == "timestamp_extract" {
      guard let timestampMap = asMap(args["timestamp"]), let partMap = asMap(args["part"]) else {
        throw parseError("timestamp_extract requires timestamp and part")
      }
      let tsExpr = try parseTypedExpression(timestampMap)
      let partExpr = try parseTypedExpression(partMap)
      let tzRaw = args["timezone"]
      if tzRaw == nil {
        return tsExpr.timestampExtract(part: partExpr)
      }
      if let tzRaw = tzRaw as? String {
        return tsExpr.timestampExtract(part: partExpr, timezone: tzRaw)
      }
      guard let tzMap = asMap(tzRaw) else {
        throw parseError("timestamp_extract timezone must be string or expression")
      }
      return try tsExpr.timestampExtract(part: partExpr, timezone: parseTypedExpression(tzMap))
    }

    if resolvedName == "if_null" {
      guard let exprMap = asMap(args["expression"]),
        let replMap = asMap(args["replacement"])
      else {
        throw parseError("if_null requires expression and replacement")
      }
      return try parseTypedExpression(exprMap).ifNull(parseTypedExpression(replMap))
    }

    if resolvedName == "coalesce" {
      guard let exprMaps = asArray(args["expressions"]), exprMaps.count >= 2 else {
        throw parseError("coalesce requires at least two expressions")
      }
      let exprs = try parseTypedExpressions(
        exprMaps,
        errorMessage: "coalesce requires at least two expressions"
      )
      guard exprs.count >= 2 else {
        throw parseError("coalesce requires at least two expressions")
      }
      return exprs[0].coalesce(Array(exprs.dropFirst()))
    }

    if resolvedName == "switch_on" {
      guard let exprMaps = asArray(args["expressions"]), exprMaps.count >= 2 else {
        throw parseError("switch_on requires at least two expressions")
      }
      var switchArgs: [any FirebaseFirestore.Expression] = []
      for i in 0..<exprMaps.count {
        guard let emMap = asMap(exprMaps[i]) else {
          throw parseError("switch_on requires at least two expressions")
        }
        let isCondition = i % 2 == 0 && i + 1 < exprMaps.count
        if isCondition {
          try switchArgs.append(parseBooleanTypedExpression(emMap))
        } else {
          try switchArgs.append(parseTypedExpression(emMap))
        }
      }
      return FunctionExpression(functionName: "switch_on", args: switchArgs)
    }

    if resolvedName == "filter" {
      return try parseFilterTypedExpression(args: args)
    }

    throw parseError("Unsupported expression: \(resolvedName)")
  }

  private func rightTypedExpression(from value: Any?) throws -> any FirebaseFirestore.Expression {
    if let map = asMap(value) {
      return try parseTypedExpression(map)
    }
    return try constantExpression(from: value as Any)
  }

  private func parseFilterTypedExpression(args: [String: Any]) throws
    -> any FirebaseFirestore.Expression
  {
    let op = args["operator"] as? String
    let exprMaps = asArray(args["expressions"])
    if let op, let exprMaps {
      if exprMaps.isEmpty {
        throw parseError("filter with operator requires at least one expression")
      }
      var booleanExprs: [any FirebaseFirestore.BooleanExpression] = []
      for em in exprMaps {
        guard let emMap = asMap(em) else { continue }
        try booleanExprs.append(parseBooleanTypedExpression(emMap))
      }
      guard let first = booleanExprs.first else {
        throw parseError("filter with operator requires at least one expression")
      }
      if booleanExprs.count == 1 {
        return first
      }
      if op == "or" || op == "OR" {
        return booleanExprs.dropFirst().reduce(first) { $0 || $1 }
      }
      return booleanExprs.dropFirst().reduce(first) { $0 && $1 }
    }

    guard let fieldName = args["field"] as? String else {
      throw parseError("filter requires operator+expressions or field")
    }
    let fieldExpr = Field(fieldName)

    for key in kFilterComparisonKeys {
      let value = args[key]
      if value == nil { continue }

      switch key {
      case "isEqualTo":
        return try fieldExpr.equal(rightTypedExpression(from: value))
      case "isNotEqualTo":
        return try fieldExpr.notEqual(rightTypedExpression(from: value))
      case "isGreaterThan":
        return try fieldExpr.greaterThan(rightTypedExpression(from: value))
      case "isGreaterThanOrEqualTo":
        return try fieldExpr.greaterThanOrEqual(rightTypedExpression(from: value))
      case "isLessThan":
        return try fieldExpr.lessThan(rightTypedExpression(from: value))
      case "isLessThanOrEqualTo":
        return try fieldExpr.lessThanOrEqual(rightTypedExpression(from: value))
      case "arrayContains":
        return try fieldExpr.arrayContains(rightTypedExpression(from: value))
      case "arrayContainsAny":
        let valuesList = asArray(value) ?? []
        let valueExprs = try valuesList.map { try rightTypedExpression(from: $0) }
        if valueExprs.isEmpty {
          throw parseError("arrayContainsAny requires non-empty list")
        }
        return fieldExpr.arrayContainsAny(valueExprs)
      case "whereIn":
        let valuesList = asArray(value) ?? []
        let valueExprs = try valuesList.map { try rightTypedExpression(from: $0) }
        if valueExprs.isEmpty {
          throw parseError("whereIn requires non-empty list")
        }
        return fieldExpr.equalAny(valueExprs)
      case "whereNotIn":
        let valuesList = asArray(value) ?? []
        let valueExprs = try valuesList.map { try rightTypedExpression(from: $0) }
        if valueExprs.isEmpty {
          throw parseError("whereNotIn requires non-empty list")
        }
        return fieldExpr.notEqualAny(valueExprs)
      case "isNull":
        return fieldExpr.equal(Constant.nil)
      case "isNotNull":
        return fieldExpr.notEqual(Constant.nil)
      default:
        continue
      }
    }

    throw parseError(
      "filter requires at least one comparison (isEqualTo, isGreaterThan, etc.)"
    )
  }
}

enum PipelineParser {
  static func executePipeline(
    firestore: Firestore,
    stages: [[String: Any?]],
    options: [String: Any?]?,
    completion: @escaping (Any?, Error?) -> Void
  ) {
    _ = options
    if NSClassFromString("FIRPipelineBridge") == nil {
      completion(nil, pipelineUnavailableError())
      return
    }

    if stages.isEmpty {
      completion(nil, parseError("Pipeline requires at least one stage"))
      return
    }

    let stageMaps = stages.map { dictionaryFromOptionalKeyed($0) }
    do {
      let stageBridges = try parseStages(firestore: firestore, stages: stageMaps)
      let pipeline = PipelineBridge(stages: stageBridges, db: firestore)
      pipeline.execute { snapshot, execError in
        if let execError {
          completion(nil, execError)
          return
        }
        completion(snapshot, nil)
      }
    } catch {
      completion(nil, error)
    }
  }

  private static func keyForExpressionMap(_ em: [String: Any]) throws -> String {
    if let alias = nestedValue(em, keyPath: "args.alias") as? String, !alias.isEmpty {
      return alias
    }
    if (em["name"] as? String) == "field" {
      if let field = nestedValue(em, keyPath: "args.field") as? String {
        return field
      }
      throw parseError("field expression must have args.field")
    }
    throw parseError("expression must have alias or be a field reference")
  }

  private static func parseSearchFields(
    expressionMaps exprMaps: [Any],
    exprParser: PipelineExpressionParser
  ) throws -> [String: ExprBridge] {
    var fields: [String: ExprBridge] = [:]
    for em in exprMaps {
      guard let emMap = asMap(em) else { continue }
      let expr = try exprParser.parseExpression(emMap)
      let key = try keyForExpressionMap(emMap)
      if key.isEmpty {
        throw parseError("expression must have alias or be a field reference")
      }
      fields[key] = expr
    }
    return fields
  }

  private static func parseSearchStage(
    args: [String: Any],
    exprParser: PipelineExpressionParser
  ) throws -> StageBridge {
    let queryType = args["query_type"] as? String
    let query = args["query"]
    var options: [String: ExprBridge] = [:]

    if queryType == "string" {
      guard let query = query as? String else {
        throw parseError("search query_type 'string' requires string query")
      }
      options["query"] = DocumentMatches(query).bridge
    } else if queryType == "expression" {
      guard let queryMap = asMap(query) else {
        throw parseError("search query_type 'expression' requires expression query")
      }
      options["query"] = try exprParser.parseBooleanExpression(queryMap)
    } else {
      throw parseError("search requires query_type to be 'string' or 'expression'")
    }

    if let limit = args["limit"] as? NSNumber {
      options["limit"] = ConstantBridge(limit)
    }
    if let offset = args["offset"] as? NSNumber {
      options["offset"] = ConstantBridge(offset)
    }
    if let retrievalDepth = args["retrieval_depth"] as? NSNumber {
      options["retrieval_depth"] = ConstantBridge(retrievalDepth)
    }
    if let languageCode = args["language_code"] as? String {
      options["language_code"] = ConstantBridge(languageCode)
    }

    var sort: [OrderingBridge] = []
    if let orderingMaps = asArray(args["sort"]) {
      for om in orderingMaps {
        guard let omMap = asMap(om), let exprMap = asMap(omMap["expression"]) else { continue }
        let dir = omMap["order_direction"] as? String
        let expr = try exprParser.parseExpression(exprMap)
        let direction = dir == "asc" ? "ascending" : "descending"
        sort.append(OrderingBridge(expr: expr, direction: direction))
      }
    }

    var addFields: [String: ExprBridge] = [:]
    if let addFieldMaps = asArray(args["add_fields"]), !addFieldMaps.isEmpty {
      addFields = try parseSearchFields(expressionMaps: addFieldMaps, exprParser: exprParser)
    }

    return SearchStageBridge(
      options: options,
      addFields: addFields,
      select: [:],
      sort: sort
    )
  }

  private static func parseStages(
    firestore: Firestore,
    stages: [[String: Any]],
    depth: Int = 0
  ) throws -> [StageBridge] {
    if depth > kMaxPipelineStageDepth {
      throw parseError("Pipeline nested too deeply")
    }
    let exprParser = PipelineExpressionParser(firestore: firestore)
    var stageBridges: [StageBridge] = []

    for i in 0..<stages.count {
      let stageMap = stages[i]
      guard let stageName = stageMap["stage"] as? String else {
        throw parseError("Stage must have a 'stage' field")
      }
      let argsObj = stageMap["args"]
      let args = asMap(argsObj) ?? [:]
      let argsArray = asArray(argsObj)

      var stage: StageBridge?

      if i == 0 {
        if stageName == "collection" {
          guard let path = args["path"] as? String else {
            throw parseError("collection requires 'path'")
          }
          let ref = firestore.collection(path)
          stage = CollectionSourceStageBridge(ref: ref, firestore: firestore, forceIndex: nil)
        } else if stageName == "collection_group" {
          guard let path = args["path"] as? String else {
            throw parseError("collection_group requires 'path'")
          }
          stage = CollectionGroupSourceStageBridge(collectionId: path, forceIndex: nil)
        } else if stageName == "database" {
          stage = DatabaseSourceStageBridge()
        } else if stageName == "documents" {
          guard let docMaps = argsArray, !docMaps.isEmpty else {
            throw parseError("documents requires array of document refs")
          }
          var refs: [DocumentReference] = []
          for docMap in docMaps {
            guard let docMap = asMap(docMap) else { continue }
            if let path = docMap["path"] as? String {
              refs.append(firestore.document(path))
            }
          }
          stage = DocumentsSourceStageBridge(documents: refs, firestore: firestore)
        } else {
          throw parseError(
            "First stage must be collection, collection_group, documents, or database. Got: \(stageName)"
          )
        }
      } else {
        if stageName == "where" {
          guard let exprMap = asMap(args["expression"]) else {
            throw parseError("where requires expression")
          }
          let expr = try exprParser.parseBooleanExpression(exprMap)
          stage = WhereStageBridge(expr: expr)
        } else if stageName == "search" {
          stage = try parseSearchStage(args: args, exprParser: exprParser)
        } else if stageName == "limit" {
          guard let limit = args["limit"] as? NSNumber else {
            throw parseError("limit requires numeric limit")
          }
          stage = LimitStageBridge(limit: Int(limit.intValue))
        } else if stageName == "offset" {
          guard let offset = args["offset"] as? NSNumber else {
            throw parseError("offset requires numeric offset")
          }
          stage = OffsetStageBridge(offset: Int(offset.intValue))
        } else if stageName == "sort" {
          guard let orderingMaps = asArray(args["orderings"]), !orderingMaps.isEmpty else {
            throw parseError("sort requires at least one ordering")
          }
          var orderings: [OrderingBridge] = []
          for om in orderingMaps {
            guard let omMap = asMap(om), let exprMap = asMap(omMap["expression"]) else { continue }
            let dir = omMap["order_direction"] as? String
            let expr = try exprParser.parseExpression(exprMap)
            let direction = dir == "asc" ? "ascending" : "descending"
            orderings.append(OrderingBridge(expr: expr, direction: direction))
          }
          if orderings.isEmpty {
            throw parseError("sort requires at least one ordering")
          }
          stage = SortStageBridge(orderings: orderings)
        } else if stageName == "select" {
          guard let exprMaps = asArray(args["expressions"]), !exprMaps.isEmpty else {
            throw parseError("select requires at least one expression")
          }
          var fields: [String: ExprBridge] = [:]
          for em in exprMaps {
            guard let emMap = asMap(em) else { continue }
            let expr = try exprParser.parseExpression(emMap)
            let key = try keyForExpressionMap(emMap)
            fields[key] = expr
          }
          stage = SelectStageBridge(selections: fields)
        } else if stageName == "add_fields" {
          guard let exprMaps = asArray(args["expressions"]), !exprMaps.isEmpty else {
            throw parseError("add_fields requires at least one expression")
          }
          var fields: [String: ExprBridge] = [:]
          for em in exprMaps {
            guard let emMap = asMap(em) else { continue }
            let expr = try exprParser.parseExpression(emMap)
            guard let alias = nestedValue(emMap, keyPath: "args.alias") else {
              throw parseError("add_fields expressions must have alias")
            }
            fields["\(alias)"] = expr
          }
          stage = AddFieldsStageBridge(fields: fields)
        } else if stageName == "remove_fields" {
          guard let paths = asArray(args["field_paths"]), !paths.isEmpty else {
            throw parseError("remove_fields requires field_paths")
          }
          let fieldPaths = paths.compactMap { $0 as? String }
          stage = RemoveFieldsStageBridge(fields: fieldPaths)
        } else if stageName == "distinct" {
          guard let exprMaps = asArray(args["expressions"]), !exprMaps.isEmpty else {
            throw parseError("distinct requires at least one expression")
          }
          var fields: [String: ExprBridge] = [:]
          for em in exprMaps {
            guard let emMap = asMap(em) else { continue }
            let expr = try exprParser.parseExpression(emMap)
            let key = try keyForExpressionMap(emMap)
            fields[key] = expr
          }
          stage = DistinctStageBridge(groups: fields)
        } else if stageName == "replace_with" {
          guard let exprMap = asMap(args["expression"]) else {
            throw parseError("replace_with requires expression")
          }
          let expr = try exprParser.parseExpression(exprMap)
          stage = ReplaceWithStageBridge(expr: expr)
        } else if stageName == "union" {
          guard let nestedStagesRaw = asArray(args["pipeline"]), !nestedStagesRaw.isEmpty else {
            throw parseError("union requires non-empty pipeline")
          }
          var nestedStages: [[String: Any]] = []
          for nested in nestedStagesRaw {
            guard let nestedMap = asMap(nested) else {
              throw parseError("Stage must be a map")
            }
            nestedStages.append(nestedMap)
          }
          let otherPipeline = try buildPipeline(
            firestore: firestore, stages: nestedStages, depth: depth + 1
          )
          stage = UnionStageBridge(other: otherPipeline)
        } else if stageName == "sample" {
          let type = args["type"] as? String
          let val = args["value"]
          if type == "percentage" {
            let v = (val as? NSNumber)?.doubleValue ?? 0
            stage = SampleStageBridge(percentage: v)
          } else {
            let v = (val as? NSNumber)?.intValue ?? 0
            stage = SampleStageBridge(count: Int64(v))
          }
        } else if stageName == "aggregate" {
          stage = try? parseAggregateStage(args: args, exprParser: exprParser)
        } else if stageName == "aggregate_with_options" {
          stage = try? parseAggregateStageWithOptions(args: args, exprParser: exprParser)
        } else if stageName == "unnest" {
          guard let exprMap = asMap(args["expression"]) else {
            throw parseError("unnest requires expression")
          }
          var fieldExpr: ExprBridge?
          var aliasStr: String?
          if (exprMap["name"] as? String) == "alias" {
            let aliasArgs = asMap(exprMap["args"])
            if let aliasArgs, aliasArgs["expression"] != nil,
              let innerExpr = asMap(aliasArgs["expression"])
            {
              fieldExpr = try exprParser.parseExpression(innerExpr)
              aliasStr = aliasArgs["alias"] as? String
            }
          }
          if fieldExpr == nil {
            fieldExpr = try exprParser.parseExpression(exprMap)
            if aliasStr == nil, (exprMap["name"] as? String) == "field" {
              let fieldArgs = asMap(exprMap["args"])
              aliasStr = (fieldArgs?["field"] as? String) ?? "_"
            }
          }
          if aliasStr == nil { aliasStr = "_" }
          let aliasExpr = FieldBridge(name: aliasStr!)
          let indexFieldStr = args["index_field"] as? String
          let indexFieldExpr: ExprBridge? =
            (indexFieldStr?.isEmpty == false) ? FieldBridge(name: indexFieldStr!) : nil
          stage = UnnestStageBridge(
            field: fieldExpr!,
            alias: aliasExpr,
            indexField: indexFieldExpr
          )
        } else if stageName == "find_nearest" {
          let vectorFieldName = args["vector_field"] as? String
          let vectorValueArray = asArray(args["vector_value"])
          let distanceMeasure = args["distance_measure"] as? String
          let limit = args["limit"] as? NSNumber
          let distanceField = args["distance_field"] as? String
          guard let vectorFieldName, !vectorFieldName.isEmpty else {
            throw parseError("find_nearest requires 'vector_field'")
          }
          guard let vectorValueArray, !vectorValueArray.isEmpty else {
            throw parseError("find_nearest requires non-empty 'vector_value'")
          }
          guard let distanceMeasure, !distanceMeasure.isEmpty else {
            throw parseError("find_nearest requires 'distance_measure'")
          }
          let embeddingField = FieldBridge(name: vectorFieldName)
          var numbers: [NSNumber] = []
          numbers.reserveCapacity(vectorValueArray.count)
          for v in vectorValueArray {
            if let n = v as? NSNumber {
              numbers.append(n)
            }
          }
          if numbers.count != vectorValueArray.count {
            throw parseError("find_nearest vector_value must be an array of numbers")
          }
          let queryVector = VectorValue(__array: numbers)
          let distanceFieldExpr: ExprBridge? = distanceField.map { FieldBridge(name: $0) }
          stage = FindNearestStageBridge(
            field: embeddingField,
            vectorValue: queryVector,
            distanceMeasure: distanceMeasure,
            limit: limit,
            distanceField: distanceFieldExpr
          )
        } else {
          throw parseError("Unknown pipeline stage: \(stageName)")
        }
      }

      if let stage {
        stageBridges.append(stage)
      }
    }

    if stageBridges.isEmpty {
      throw parseError("No valid stages")
    }

    return stageBridges
  }

  private static func aggregateFunction(
    from funcMap: [String: Any],
    exprParser: PipelineExpressionParser
  ) throws
    -> AggregateFunctionBridge
  {
    guard let name = funcMap["name"] as? String else {
      throw parseError("Aggregate function must have a 'name'")
    }
    var iosName = name
    if name == "count_all" {
      iosName = "count"
    } else if name == "minimum" {
      iosName = "min"
    } else if name == "maximum" {
      iosName = "max"
    }
    var argsArray: [ExprBridge] = []
    if let argsDict = asMap(funcMap["args"]), let exprMap = asMap(argsDict["expression"]) {
      let expr = try exprParser.parseExpression(exprMap)
      argsArray.append(expr)
    }
    return AggregateFunctionBridge(name: iosName, args: argsArray)
  }

  private static func parseAggregateStage(
    args: [String: Any],
    exprParser: PipelineExpressionParser
  ) throws
    -> StageBridge
  {
    guard let accumulatorMaps = asArray(args["aggregate_functions"]), !accumulatorMaps.isEmpty
    else {
      throw parseError("aggregate requires aggregate_functions")
    }
    return try parseAggregateStage(
      accumulatorMaps: accumulatorMaps,
      groupMaps: nil,
      exprParser: exprParser
    )
  }

  private static func parseAggregateStageWithOptions(
    args: [String: Any],
    exprParser: PipelineExpressionParser
  ) throws
    -> StageBridge
  {
    guard let stageMap = asMap(args["aggregate_stage"]) else {
      throw parseError("aggregate_with_options requires aggregate_stage")
    }
    var accumulatorMaps = asArray(stageMap["accumulators"])
    if accumulatorMaps == nil || accumulatorMaps?.isEmpty == true {
      accumulatorMaps = asArray(stageMap["aggregate_functions"])
    }
    guard let accumulatorMaps, !accumulatorMaps.isEmpty else {
      throw parseError("aggregate_stage requires accumulators or aggregate_functions")
    }
    let groupMaps = asArray(stageMap["groups"])
    return try parseAggregateStage(
      accumulatorMaps: accumulatorMaps,
      groupMaps: groupMaps,
      exprParser: exprParser
    )
  }

  private static func parseAggregateStage(
    accumulatorMaps: [Any],
    groupMaps: [Any]?,
    exprParser: PipelineExpressionParser
  ) throws
    -> StageBridge
  {
    var accumulators: [String: AggregateFunctionBridge] = [:]
    for accMap in accumulatorMaps {
      guard let accMap = asMap(accMap) else { continue }
      var alias: String?
      var funcMap: [String: Any]?
      if (accMap["name"] as? String) == "alias" {
        guard let accArgs = asMap(accMap["args"]) else { continue }
        alias = accArgs["alias"] as? String
        funcMap = asMap(accArgs["aggregate_function"])
      }
      guard let alias, let funcMap else {
        throw parseError("Each accumulator must have alias and aggregate_function")
      }
      let funcBridge = try aggregateFunction(from: funcMap, exprParser: exprParser)
      accumulators[alias] = funcBridge
    }
    if accumulators.isEmpty {
      throw parseError("aggregate requires at least one valid accumulator")
    }

    var groups: [String: ExprBridge] = [:]
    if let groupMaps, !groupMaps.isEmpty {
      for gm in groupMaps {
        guard let gmMap = asMap(gm) else { continue }
        guard let expr = try? exprParser.parseExpression(gmMap) else { continue }
        let groupKey = try keyForExpressionMap(gmMap)
        if groupKey.isEmpty {
          throw parseError(
            "aggregate group expression must be a field reference or have an alias"
          )
        }
        groups[groupKey] = expr
      }
    }

    return AggregateStageBridge(accumulators: accumulators, groups: groups)
  }

  private static func buildPipeline(
    firestore: Firestore,
    stages: [[String: Any]],
    depth: Int = 0
  ) throws -> PipelineBridge {
    let stageBridges = try parseStages(firestore: firestore, stages: stages, depth: depth)
    return PipelineBridge(stages: stageBridges, db: firestore)
  }
}
