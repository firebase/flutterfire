/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.firestore.utils;

import androidx.annotation.NonNull;
import com.google.firebase.Timestamp;
import com.google.firebase.firestore.Blob;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.GeoPoint;
import com.google.firebase.firestore.VectorValue;
import com.google.firebase.firestore.pipeline.BooleanExpression;
import com.google.firebase.firestore.pipeline.Expression;
import java.util.List;
import java.util.Map;

/** Helper utilities for parsing expressions and handling common patterns. */
class ExpressionHelpers {

  /**
   * Parses an "and" expression from a list of expression maps. Uses Expression.and() with varargs
   * signature.
   *
   * @param exprMaps List of expression maps to combine with AND
   * @param parser Reference to ExpressionParsers for recursive parsing
   */
  @SuppressWarnings("unchecked")
  static BooleanExpression parseAndExpression(
      @NonNull List<Map<String, Object>> exprMaps, @NonNull ExpressionParsers parser) {
    if (exprMaps == null || exprMaps.isEmpty()) {
      throw new IllegalArgumentException("'and' requires at least one expression");
    }

    BooleanExpression first = parser.parseBooleanExpression(exprMaps.get(0));
    if (exprMaps.size() == 1) {
      return first;
    }

    BooleanExpression[] rest = new BooleanExpression[exprMaps.size() - 1];
    for (int i = 1; i < exprMaps.size(); i++) {
      rest[i - 1] = parser.parseBooleanExpression(exprMaps.get(i));
    }
    return Expression.and(first, rest);
  }

  /**
   * Parses an "or" expression from a list of expression maps. Uses Expression.or() with varargs
   * signature.
   *
   * @param exprMaps List of expression maps to combine with OR
   * @param parser Reference to ExpressionParsers for recursive parsing
   */
  @SuppressWarnings("unchecked")
  static BooleanExpression parseOrExpression(
      @NonNull List<Map<String, Object>> exprMaps, @NonNull ExpressionParsers parser) {
    if (exprMaps == null || exprMaps.isEmpty()) {
      throw new IllegalArgumentException("'or' requires at least one expression");
    }

    BooleanExpression first = parser.parseBooleanExpression(exprMaps.get(0));
    if (exprMaps.size() == 1) {
      return first;
    }

    BooleanExpression[] rest = new BooleanExpression[exprMaps.size() - 1];
    for (int i = 1; i < exprMaps.size(); i++) {
      rest[i - 1] = parser.parseBooleanExpression(exprMaps.get(i));
    }
    return Expression.or(first, rest);
  }

  /**
   * Parses a constant value based on its type to match Android SDK constant() overloads. Valid
   * types: String, Number, Boolean, Date, Timestamp, GeoPoint, byte[], Blob, DocumentReference,
   * VectorValue
   */
  static Expression parseConstantValue(Object value) {

    if (value == null) {
      return Expression.nullValue();
    }

    if (value instanceof String) {
      return Expression.constant((String) value);
    } else if (value instanceof Number) {
      return Expression.constant((Number) value);
    } else if (value instanceof Boolean) {
      return Expression.constant((Boolean) value);
    } else if (value instanceof java.util.Date) {
      return Expression.constant((java.util.Date) value);
    } else if (value instanceof Timestamp) {
      return Expression.constant((Timestamp) value);
    } else if (value instanceof GeoPoint) {
      return Expression.constant((GeoPoint) value);
    } else if (value instanceof byte[]) {
      return Expression.constant((byte[]) value);
    } else if (value instanceof List) {
      // Handle List<int> from Dart which comes as List<Integer> or List<Number>
      // This represents byte[] (byte array) for constant expressions
      @SuppressWarnings("unchecked")
      List<?> list = (List<?>) value;
      // Check if all elements are numbers (for byte array)
      boolean isByteArray = true;
      for (Object item : list) {
        if (!(item instanceof Number)) {
          isByteArray = false;
          break;
        }
      }
      if (isByteArray && !list.isEmpty()) {
        byte[] byteArray = new byte[list.size()];
        for (int i = 0; i < list.size(); i++) {
          byteArray[i] = ((Number) list.get(i)).byteValue();
        }
        return Expression.constant(byteArray);
      }
      // If not a byte array, fall through to error
    } else if (value instanceof Blob) {
      return Expression.constant((Blob) value);
    } else if (value instanceof DocumentReference) {
      return Expression.constant((DocumentReference) value);
    } else if (value instanceof VectorValue) {
      return Expression.constant((VectorValue) value);
    }

    throw new IllegalArgumentException(
        "Constant value must be one of: String, Number, Boolean, Date, Timestamp, "
            + "GeoPoint, byte[], Blob, DocumentReference, or VectorValue. Got: "
            + value.getClass().getName());
  }
}
