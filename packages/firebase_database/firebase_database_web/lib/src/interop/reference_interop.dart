// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'database_interop.dart';

@JS('TransactionResult')
@staticInterop
abstract class TransactionResultJsImpl {}

extension TransactionResultJsImplExtension on TransactionResultJsImpl {
  external JSObject toJSON();
  external JSBoolean get committed;
  external DataSnapshotJsImpl get snapshot;
}

@JS('DatabaseReference')
@staticInterop
abstract class ReferenceJsImpl extends QueryJsImpl {}

extension ReferenceJsImplExtension on ReferenceJsImpl {
  external JSString? get key;

  external ReferenceJsImpl? get parent;

  external ReferenceJsImpl get root;
}
