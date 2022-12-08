/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.database;

public class Constants {
  public static final String APP_NAME = "appName";

  // FirebaseDatabase instance options.
  public static final String DATABASE_URL = "databaseURL";
  public static final String DATABASE_LOGGING_ENABLED = "loggingEnabled";
  public static final String DATABASE_PERSISTENCE_ENABLED = "persistenceEnabled";
  public static final String DATABASE_EMULATOR_HOST = "emulatorHost";
  public static final String DATABASE_EMULATOR_PORT = "emulatorPort";
  public static final String DATABASE_CACHE_SIZE_BYTES = "cacheSizeBytes";

  public static final String EVENT_CHANNEL_NAME_PREFIX = "eventChannelNamePrefix";

  public static final String PATH = "path";
  public static final String KEY = "key";
  public static final String VALUE = "value";
  public static final String PRIORITY = "priority";
  public static final String SNAPSHOT = "snapshot";

  public static final String COMMITTED = "committed";

  public static final String MODIFIERS = "modifiers";
  public static final String ORDER_BY = "orderBy";
  public static final String CURSOR = "cursor";
  public static final String LIMIT = "limit";
  public static final String START_AT = "startAt";
  public static final String START_AFTER = "startAfter";
  public static final String END_AT = "endAt";
  public static final String END_BEFORE = "endBefore";
  public static final String LIMIT_TO_FIRST = "limitToFirst";
  public static final String LIMIT_TO_LAST = "limitToLast";

  public static final String EVENT_TYPE = "eventType";

  public static final String EVENT_TYPE_CHILD_ADDED = "childAdded";
  public static final String EVENT_TYPE_CHILD_REMOVED = "childRemoved";
  public static final String EVENT_TYPE_CHILD_CHANGED = "childChanged";
  public static final String EVENT_TYPE_CHILD_MOVED = "childMoved";
  public static final String EVENT_TYPE_VALUE = "value";

  public static final String CHILD_KEYS = "childKeys";
  public static final String PREVIOUS_CHILD_NAME = "previousChildKey";

  public static final String METHOD_CALL_TRANSACTION_HANDLER =
      "FirebaseDatabase#callTransactionHandler";
  public static final String TRANSACTION_KEY = "transactionKey";
  public static final String TRANSACTION_APPLY_LOCALLY = "transactionApplyLocally";

  public static final String ERROR_CODE = "code";
  public static final String ERROR_MESSAGE = "message";
  public static final String ERROR_DETAILS = "details";
}
