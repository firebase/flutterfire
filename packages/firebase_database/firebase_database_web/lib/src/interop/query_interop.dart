// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'database_interop.dart';

@JS('Query')
@staticInterop
abstract class QueryJsImpl {}

extension ExtensionQueryJsImpl on QueryJsImpl {
  external ReferenceJsImpl get ref;

  external JSBoolean isEqual(QueryJsImpl other);

  external JSObject toJSON();
}
