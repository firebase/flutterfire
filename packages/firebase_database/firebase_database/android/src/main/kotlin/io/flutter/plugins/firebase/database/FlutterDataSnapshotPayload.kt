/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

import com.google.firebase.database.DataSnapshot
import java.util.*

class FlutterDataSnapshotPayload(
  snapshot: DataSnapshot,
) {
  private var payloadMap: MutableMap<String, Any?> = mutableMapOf()

  init {
    val snapshotMap = mutableMapOf<String, Any?>()

    snapshotMap[Constants.KEY] = snapshot.key
    snapshotMap[Constants.VALUE] = snapshot.value
    snapshotMap[Constants.PRIORITY] = snapshot.priority

    val childrenCount = snapshot.childrenCount.toInt()
    if (childrenCount == 0) {
      snapshotMap[Constants.CHILD_KEYS] = emptyList<String>()
    } else {
      val childKeys = Array(childrenCount) { "" }
      var i = 0
      val children = snapshot.children
      for (child in children) {
        childKeys[i] = child.key ?: ""
        i++
      }
      snapshotMap[Constants.CHILD_KEYS] = childKeys.toList()
    }

    payloadMap[Constants.SNAPSHOT] = snapshotMap
  }

  fun withAdditionalParams(params: Map<String, Any?>): FlutterDataSnapshotPayload {
    val prevPayloadMap = payloadMap
    payloadMap = mutableMapOf()
    payloadMap.putAll(prevPayloadMap)
    payloadMap.putAll(params)
    return this
  }

  fun toMap(): Map<String, Any?> = payloadMap
}
