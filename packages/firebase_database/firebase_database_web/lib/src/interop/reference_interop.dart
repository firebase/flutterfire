// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase.database_interop;

@JS('TransactionResult')
abstract class TransactionResultJsImpl {
  external dynamic toJSON();
  external bool get committed;
  external DataSnapshotJsImpl get snapshot;
}

@JS('Reference')
abstract class ReferenceJsImpl extends QueryJsImpl {
  external String? get key;

  external ReferenceJsImpl? get parent;

  external ReferenceJsImpl get root;
}
