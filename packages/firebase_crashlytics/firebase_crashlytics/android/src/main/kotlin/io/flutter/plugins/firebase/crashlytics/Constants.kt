/*
 * Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

package io.flutter.plugins.firebase.crashlytics

open class Constants {
  companion object {
    const val EXCEPTION = "exception"
    const val REASON = "reason"
    const val INFORMATION = "information"
    const val STACK_TRACE_ELEMENTS = "stackTraceElements"
    const val FLUTTER_ERROR_EXCEPTION = "flutter_error_exception"
    const val FLUTTER_ERROR_REASON = "flutter_error_reason"
    const val MESSAGE = "message"
    const val ENABLED = "enabled"
    const val IDENTIFIER = "identifier"
    const val KEY = "key"
    const val VALUE = "value"
    const val FILE = "file"
    const val LINE = "line"
    const val CLASS = "class"
    const val METHOD = "method"
    const val DID_CRASH_ON_PREVIOUS_EXECUTION = "didCrashOnPreviousExecution"
    const val UNSENT_REPORTS = "unsentReports"
    const val IS_CRASHLYTICS_COLLECTION_ENABLED = "isCrashlyticsCollectionEnabled"
    const val FATAL = "fatal"
    const val BUILD_ID = "buildId"
    const val LOADING_UNITS = "loadingUnits"
    const val TIMESTAMP = "timestamp"
    const val FIREBASE_APPLICATION_EXCEPTION = "_ae"
    const val CRASH_EVENT_KEY = "com.firebase.crashlytics.flutter.fatal"
  }
}
