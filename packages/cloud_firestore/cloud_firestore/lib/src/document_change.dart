// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
class DocumentChange {
  final platform.DocumentChangePlatform _delegate;
  final Firestore _firestore;

  DocumentChange._(this._delegate, this._firestore) {
    platform.DocumentChangePlatform.verifyExtends(_delegate);
  }

  /// The type of change that occurred (added, modified, or removed).
  platform.DocumentChangeType get type => _delegate.type;

  /// The index of the changed document in the result set immediately prior to
  /// this [DocumentChange] (i.e. supposing that all prior DocumentChange objects
  /// have been applied).
  ///
  /// -1 for [DocumentChangeType.added] events.
  int get oldIndex => _delegate.oldIndex;

  /// The index of the changed document in the result set immediately after this
  /// DocumentChange (i.e. supposing that all prior [DocumentChange] objects
  /// and the current [DocumentChange] object have been applied).
  ///
  /// -1 for [DocumentChangeType.removed] events.
  int get newIndex => _delegate.newIndex;

  /// The document affected by this change.
  DocumentSnapshot get document =>
      DocumentSnapshot._(_delegate.document, _firestore);
}
