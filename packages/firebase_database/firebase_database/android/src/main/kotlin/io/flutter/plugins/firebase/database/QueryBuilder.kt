/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import androidx.annotation.NonNull
import com.google.firebase.database.DatabaseReference
import com.google.firebase.database.Query
import java.util.*

class QueryBuilder
  @JvmOverloads
  constructor(
    @NonNull ref: DatabaseReference,
    @NonNull private val modifiers: List<Map<String, Any>>,
  ) {
    private var query: Query = ref

    fun build(): Query {
      if (modifiers.isEmpty()) return query

      for (modifier in modifiers) {
        val type = modifier["type"] as String

        when (type) {
          Constants.LIMIT -> limit(modifier)
          Constants.CURSOR -> cursor(modifier)
          Constants.ORDER_BY -> orderBy(modifier)
        }
      }

      return query
    }

    private fun limit(modifier: Map<String, Any>) {
      val name = modifier["name"] as String
      val value = modifier["limit"] as Int

      query =
        when (name) {
          Constants.LIMIT_TO_FIRST -> query.limitToFirst(value)
          Constants.LIMIT_TO_LAST -> query.limitToLast(value)
          else -> query
        }
    }

    private fun orderBy(modifier: Map<String, Any>) {
      val name = modifier["name"] as String

      query =
        when (name) {
          "orderByKey" -> query.orderByKey()
          "orderByValue" -> query.orderByValue()
          "orderByPriority" -> query.orderByPriority()
          "orderByChild" -> {
            val path = modifier["path"] as String
            query.orderByChild(path)
          }
          else -> query
        }
    }

    private fun cursor(modifier: Map<String, Any>) {
      val name = modifier["name"] as String

      when (name) {
        Constants.START_AT -> startAt(modifier)
        Constants.START_AFTER -> startAfter(modifier)
        Constants.END_AT -> endAt(modifier)
        Constants.END_BEFORE -> endBefore(modifier)
      }
    }

    private fun startAt(modifier: Map<String, Any>) {
      val value = modifier["value"]
      val key = modifier["key"] as String?

      query =
        when (value) {
          is Boolean -> if (key == null) query.startAt(value) else query.startAt(value, key)
          is Number -> if (key == null) query.startAt(value.toDouble()) else query.startAt(value.toDouble(), key)
          else -> if (key == null) query.startAt(value as String) else query.startAt(value as String, key)
        }
    }

    private fun startAfter(modifier: Map<String, Any>) {
      val value = modifier["value"]
      val key = modifier["key"] as String?

      query =
        when (value) {
          is Boolean -> if (key == null) query.startAfter(value) else query.startAfter(value, key)
          is Number -> if (key == null) query.startAfter(value.toDouble()) else query.startAfter(value.toDouble(), key)
          else -> if (key == null) query.startAfter(value as String) else query.startAfter(value as String, key)
        }
    }

    private fun endAt(modifier: Map<String, Any>) {
      val value = modifier["value"]
      val key = modifier["key"] as String?

      query =
        when (value) {
          is Boolean -> if (key == null) query.endAt(value) else query.endAt(value, key)
          is Number -> if (key == null) query.endAt(value.toDouble()) else query.endAt(value.toDouble(), key)
          else -> if (key == null) query.endAt(value as String) else query.endAt(value as String, key)
        }
    }

    private fun endBefore(modifier: Map<String, Any>) {
      val value = modifier["value"]
      val key = modifier["key"] as String?

      query =
        when (value) {
          is Boolean -> if (key == null) query.endBefore(value) else query.endBefore(value, key)
          is Number -> if (key == null) query.endBefore(value.toDouble()) else query.endBefore(value.toDouble(), key)
          else -> if (key == null) query.endBefore(value as String) else query.endBefore(value as String, key)
        }
    }
  }
