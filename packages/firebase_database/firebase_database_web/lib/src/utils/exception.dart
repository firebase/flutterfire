// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_web;

FirebaseException convertFirebaseFunctionsException(Object exception,
    [StackTrace? stackTrace]) {
  String originalCode = util.getProperty(exception, 'code');
  String code = originalCode.replaceFirst('functions/', '');
  String message = util
      .getProperty(exception, 'message')
      .replaceFirst('($originalCode)', '');

  return FirebaseException(
    plugin: 'firebase_database',
    code: code,
    message: message,
    stackTrace: stackTrace,
  );
}
