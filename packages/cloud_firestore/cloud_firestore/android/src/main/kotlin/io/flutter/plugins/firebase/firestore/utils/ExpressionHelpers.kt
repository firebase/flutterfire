/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils

import com.google.firebase.Timestamp
import com.google.firebase.firestore.Blob
import com.google.firebase.firestore.DocumentReference
import com.google.firebase.firestore.GeoPoint
import com.google.firebase.firestore.VectorValue
import com.google.firebase.firestore.pipeline.BooleanExpression
import com.google.firebase.firestore.pipeline.Expression
import java.util.Date

/** Helper utilities for parsing expressions and handling common patterns. */
internal object ExpressionHelpers {
  @Suppress("UNCHECKED_CAST")
  fun parseAndExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): BooleanExpression {
    require(exprMaps.isNotEmpty()) { "'and' requires at least one expression" }
    val first = parser.parseBooleanExpression(exprMaps[0])
    if (exprMaps.size == 1) {
      return first
    }
    val rest = Array(exprMaps.size - 1) { i -> parser.parseBooleanExpression(exprMaps[i + 1]) }
    return Expression.and(first, *rest)
  }

  fun parseOrExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): BooleanExpression {
    require(exprMaps.isNotEmpty()) { "'or' requires at least one expression" }
    val first = parser.parseBooleanExpression(exprMaps[0])
    if (exprMaps.size == 1) {
      return first
    }
    val rest = Array(exprMaps.size - 1) { i -> parser.parseBooleanExpression(exprMaps[i + 1]) }
    return Expression.or(first, *rest)
  }

  fun parseXorExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): BooleanExpression {
    require(exprMaps.isNotEmpty()) { "'xor' requires at least one expression" }
    val first = parser.parseBooleanExpression(exprMaps[0])
    if (exprMaps.size == 1) {
      return first
    }
    val rest = Array(exprMaps.size - 1) { i -> parser.parseBooleanExpression(exprMaps[i + 1]) }
    return Expression.xor(first, *rest)
  }

  fun parseNorExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): BooleanExpression {
    require(exprMaps.isNotEmpty()) { "'nor' requires at least one expression" }
    val first = parser.parseBooleanExpression(exprMaps[0])
    if (exprMaps.size == 1) {
      return first
    }
    val rest = Array(exprMaps.size - 1) { i -> parser.parseBooleanExpression(exprMaps[i + 1]) }
    return Expression.nor(first, *rest)
  }

  fun parseCoalesceExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): Expression {
    require(exprMaps.size >= 2) { "'coalesce' requires at least two expressions" }
    val first = parser.parseExpression(exprMaps[0])
    val second = parser.parseExpression(exprMaps[1])
    if (exprMaps.size == 2) {
      return Expression.coalesce(first, second)
    }
    val rest = Array<Any>(exprMaps.size - 2) { i -> parser.parseExpression(exprMaps[i + 2]) }
    return Expression.coalesce(first, second, *rest)
  }

  fun parseSwitchOnExpression(
      exprMaps: List<Map<String, Any>>,
      parser: ExpressionParsers
  ): Expression {
    val n = exprMaps.size
    require(n >= 2) { "'switch_on' requires at least two expressions" }
    val first = parser.parseBooleanExpression(exprMaps[0])
    val second = parser.parseExpression(exprMaps[1])
    if (n == 2) {
      return Expression.switchOn(first, second)
    }
    val tail =
        Array<Any>(n - 2) { i ->
          val index = i + 2
          if (n % 2 == 1 && index == n - 1) {
            parser.parseExpression(exprMaps[index])
          } else if (index % 2 == 0) {
            parser.parseBooleanExpression(exprMaps[index])
          } else {
            parser.parseExpression(exprMaps[index])
          }
        }
    return Expression.switchOn(first, second, *tail)
  }

  fun parseConstantValue(value: Any?): Expression {
    if (value == null) {
      return Expression.nullValue()
    }
    when (value) {
      is String -> return Expression.constant(value)
      is Number -> return Expression.constant(value)
      is Boolean -> return Expression.constant(value)
      is Date -> return Expression.constant(value)
      is Timestamp -> return Expression.constant(value)
      is GeoPoint -> return Expression.constant(value)
      is ByteArray -> return Expression.constant(value)
      is List<*> -> {
        val isByteArray = value.isNotEmpty() && value.all { it is Number }
        if (isByteArray) {
          val byteArray = ByteArray(value.size) { i -> (value[i] as Number).toByte() }
          return Expression.constant(byteArray)
        }
      }
      is Blob -> return Expression.constant(value)
      is DocumentReference -> return Expression.constant(value)
      is VectorValue -> return Expression.constant(value)
    }
    throw IllegalArgumentException(
        "Constant value must be one of: String, Number, Boolean, Date, Timestamp, " +
            "GeoPoint, byte[], Blob, DocumentReference, or VectorValue. Got: " +
            value.javaClass.name)
  }
}
