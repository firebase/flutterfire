// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// An enumeration of document change types.
enum DocumentChangeType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed,
}

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
class DocumentChange {
  final platform.DocumentChange _delegate;

  DocumentChange._(this._delegate);

  /// The type of change that occurred (added, modified, or removed).
  DocumentChangeType get type => _fromPlatform(_delegate.type);

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
      DocumentSnapshot._(_delegate.document);

  DocumentChangeType _fromPlatform(platform.DocumentChangeType platformChange) {
    switch (platformChange) {
      case platform.DocumentChangeType.added:
        return DocumentChangeType.added;
      case platform.DocumentChangeType.modified:
        return DocumentChangeType.modified;
      case platform.DocumentChangeType.removed:
        return DocumentChangeType.removed;
      default:
        throw ArgumentError("Invalud change type");
    }
  }
}
