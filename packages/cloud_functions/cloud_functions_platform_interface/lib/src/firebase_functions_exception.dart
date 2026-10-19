// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';

/// Generic exception related to Cloud Functions. Check the error code
/// and message for more details.
///
/// [code] is one of the following strings:
///
/// - **cancelled**: The operation was cancelled (typically by the caller).
/// - **unknown**: Unknown error or an error from a different error domain.
/// - **invalid-argument**: The client specified an invalid argument. Unlike
///   `failed-precondition`, this indicates arguments that are problematic
///   regardless of the state of the system.
/// - **deadline-exceeded**: The deadline expired before the operation could
///   complete, for example because the call exceeded
///   `HttpsCallableOptions.timeout`. For operations that change the state of
///   the system, this may be returned even if the operation completed.
/// - **not-found**: A requested resource was not found. On Android and Apple
///   platforms, this is also the code when the function does not exist, for
///   example because of a wrong name or region.
/// - **already-exists**: A resource that the function attempted to create
///   already exists.
/// - **permission-denied**: The caller does not have permission to execute
///   the operation.
/// - **resource-exhausted**: A resource has been exhausted, such as a
///   per-user quota.
/// - **failed-precondition**: The operation was rejected because the system
///   is not in a state required for its execution.
/// - **aborted**: The operation was aborted, typically due to a concurrency
///   issue such as a transaction abort.
/// - **out-of-range**: The operation was attempted past the valid range.
/// - **unimplemented**: The operation is not implemented, or not supported or
///   enabled.
/// - **internal**: An internal error. This is also the code when the function
///   throws an error that is not an `HttpsError`. On web, network and CORS
///   failures, including calling a function that does not exist, are reported
///   with this code.
/// - **unavailable**: The service is currently unavailable. This is usually
///   transient and can be retried with a backoff. On Android, network errors
///   are reported with this code. On Apple platforms they are reported as
///   `unknown`.
/// - **data-loss**: Unrecoverable data loss or corruption.
/// - **unauthenticated**: The request does not have valid authentication
///   credentials for the operation.
///
/// When a callable function throws an `HttpsError`, [code] is the error's
/// code, [message] its message and [details] its details. See
/// [Handle errors](https://firebase.google.com/docs/functions/callable#handle-errors-client).
///
/// Errors from `HttpsCallable.stream` are reported with these codes on web
/// only. On Apple platforms, stream errors have the code `unknown`. On
/// Android, a stream that fails ends without an error.
class FirebaseFunctionsException extends FirebaseException
    implements Exception {
  // ignore: public_member_api_docs
  @protected
  FirebaseFunctionsException({
    required String message,
    required String code,
    StackTrace? stackTrace,
    this.details,
  }) : super(
            plugin: 'firebase_functions',
            message: message,
            code: code,
            stackTrace: stackTrace);

  /// Additional data provided with the exception.
  final dynamic details;
}
