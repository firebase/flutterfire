// Copyright 2022 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_core_platform_interface;

/// A generic class which provides exceptions for any API that has been deprecated and will be removed in the future.
class DeprecatedException implements Exception {
  DeprecatedException(this.message);
  final String message;

  @override
  String toString() {
    var message = this.message;
    return 'DeprecatedException: $message';
  }
}
