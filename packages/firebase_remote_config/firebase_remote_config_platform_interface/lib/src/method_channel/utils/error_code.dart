// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The codes the native SDKs report when they could not tell us what went
/// wrong, and which therefore carry no information a caller can act on.
const Set<String> _genericCodes = <String>{'internal', 'unknown'};

/// Message fragments the native SDKs use for a fetch that could not reach the
/// Remote Config backend.
const List<String> _networkFragments = <String>[
  'data connection is not currently allowed',
  'network',
  'unable to resolve host',
  'no internet',
  'offline',
  'unreachable',
  'connection refused',
  'connection reset',
  'connection lost',
  'timed out',
  'timeout',
];

/// Message fragments the native SDKs use for a fetch that was cancelled.
const List<String> _cancelledFragments = <String>['cancelled', 'canceled'];

/// The HTTP status the backend replied with, as the native SDKs word it, e.g.
/// `Internal Error. Status code: 503`.
final RegExp _httpStatus = RegExp(r'status(?:\s+code)?:?\s*(\d{3})');

/// Turns a generic native error code into a code describing what actually
/// failed, so that callers can tell transient failures apart from real ones.
///
/// Every failure that is not throttling or a server error arrives from the
/// native SDKs as `internal` or `unknown`, which is why the native message is
/// the only thing left to classify on. Codes the native SDKs already
/// classified, and messages that cannot be classified, are returned unchanged.
String refineRemoteConfigErrorCode(String? code, String? message) {
  if (code == null || !_genericCodes.contains(code) || message == null) {
    return code ?? 'unknown';
  }

  final String lowerCaseMessage = message.toLowerCase();

  final Match? status = _httpStatus.firstMatch(lowerCaseMessage);
  if (status != null) {
    final int? statusCode = int.tryParse(status.group(1)!);
    if (statusCode == 403) {
      return 'forbidden';
    }
    if (statusCode == 429) {
      return 'throttled';
    }
    if (statusCode != null && statusCode >= 400) {
      return 'remote-config-server-error';
    }
  }

  if (_cancelledFragments.any(lowerCaseMessage.contains)) {
    return 'cancelled';
  }

  if (_networkFragments.any(lowerCaseMessage.contains)) {
    return 'network-error';
  }

  return code;
}
