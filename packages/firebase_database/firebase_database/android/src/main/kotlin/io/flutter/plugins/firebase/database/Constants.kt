/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database

object Constants {
  const val APP_NAME = "appName"

  // FirebaseDatabase instance options.
  const val DATABASE_URL = "databaseURL"
  const val DATABASE_LOGGING_ENABLED = "loggingEnabled"
  const val DATABASE_PERSISTENCE_ENABLED = "persistenceEnabled"
  const val DATABASE_EMULATOR_HOST = "emulatorHost"
  const val DATABASE_EMULATOR_PORT = "emulatorPort"
  const val DATABASE_CACHE_SIZE_BYTES = "cacheSizeBytes"

  const val EVENT_CHANNEL_NAME_PREFIX = "eventChannelNamePrefix"

  const val PATH = "path"
  const val KEY = "key"
  const val VALUE = "value"
  const val PRIORITY = "priority"
  const val SNAPSHOT = "snapshot"

  const val COMMITTED = "committed"

  const val MODIFIERS = "modifiers"
  const val ORDER_BY = "orderBy"
  const val CURSOR = "cursor"
  const val LIMIT = "limit"
  const val START_AT = "startAt"
  const val START_AFTER = "startAfter"
  const val END_AT = "endAt"
  const val END_BEFORE = "endBefore"
  const val LIMIT_TO_FIRST = "limitToFirst"
  const val LIMIT_TO_LAST = "limitToLast"

  const val EVENT_TYPE = "eventType"

  const val EVENT_TYPE_CHILD_ADDED = "childAdded"
  const val EVENT_TYPE_CHILD_REMOVED = "childRemoved"
  const val EVENT_TYPE_CHILD_CHANGED = "childChanged"
  const val EVENT_TYPE_CHILD_MOVED = "childMoved"
  const val EVENT_TYPE_VALUE = "value"

  const val CHILD_KEYS = "childKeys"
  const val PREVIOUS_CHILD_NAME = "previousChildKey"

  const val METHOD_CALL_TRANSACTION_HANDLER =
    "FirebaseDatabase#callTransactionHandler"
  const val TRANSACTION_KEY = "transactionKey"
  const val TRANSACTION_APPLY_LOCALLY = "transactionApplyLocally"

  const val ERROR_CODE = "code"
  const val ERROR_MESSAGE = "message"
  const val ERROR_DETAILS = "details"
}
