// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_web;

// Cannot use `guardWebExceptions` since we are inferring the
// exception type from the message.
FirebaseException convertFirebaseDatabaseException(Object exception,
    [StackTrace? stackTrace]) {
  final castedJSObject = exception as core_interop.JSError;
  String code = 'unknown';
  String message = castedJSObject.message?.toDart ?? '';

  // FirebaseWeb SDK for Database has no error codes, so we manually map known
  // messages to known error codes for cross platform consistency.
  if (message.toLowerCase().contains('index not defined')) {
    code = 'index-not-defined';
  } else if (message.toLowerCase().contains('permission denied')) {
    code = 'permission-denied';
  } else if (message
      .toLowerCase()
      .contains('transaction needs to be run again with current data')) {
    code = 'data-stale';
  } else if (message
      .toLowerCase()
      .contains('transaction had too many retries')) {
    code = 'max-retries';
  } else if (message.toLowerCase().contains('service is unavailable')) {
    code = 'unavailable';
  } else if (message.toLowerCase().contains('network error')) {
    code = 'network-error';
  } else if (message.toLowerCase().contains('write was canceled')) {
    code = 'write-cancelled';
  }

  return FirebaseException(
    plugin: 'firebase_database',
    code: code,
    message: message,
    stackTrace: stackTrace,
  );
}
