/*
 * Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */
package io.flutter.plugins.firebase.crashlytics

object Constants {
  const val EXCEPTION: String = "exception"
  const val REASON: String = "reason"
  const val INFORMATION: String = "information"
  const val STACK_TRACE_ELEMENTS: String = "stackTraceElements"
  const val FLUTTER_ERROR_EXCEPTION: String = "flutter_error_exception"
  const val FLUTTER_ERROR_REASON: String = "flutter_error_reason"
  const val MESSAGE: String = "message"
  const val ENABLED: String = "enabled"
  const val IDENTIFIER: String = "identifier"
  const val KEY: String = "key"
  const val VALUE: String = "value"
  const val FILE: String = "file"
  const val LINE: String = "line"
  const val CLASS: String = "class"
  const val METHOD: String = "method"
  const val DID_CRASH_ON_PREVIOUS_EXECUTION: String = "didCrashOnPreviousExecution"
  const val UNSENT_REPORTS: String = "unsentReports"
  const val IS_CRASHLYTICS_COLLECTION_ENABLED: String = "isCrashlyticsCollectionEnabled"
  const val FATAL: String = "fatal"
  const val BUILD_ID: String = "buildId"
  const val LOADING_UNITS: String = "loadingUnits"
  const val TIMESTAMP: String = "timestamp"
  const val FIREBASE_APPLICATION_EXCEPTION: String = "_ae"
  const val CRASH_EVENT_KEY: String = "com.firebase.crashlytics.flutter.fatal"
}
