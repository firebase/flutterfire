// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:meta/meta.dart';

// Kept in sync with QuerySnapshotChunkProtocol.java.
const String _listenChunkedArgKey = 'firestoreQuerySnapshotChunked';
const String _chunkMarkerKey = 'firestoreQuerySnapshotChunk';
const String _snapshotIdKey = 'snapshotId';
const String _kindKey = 'kind';
const String _payloadKey = 'payload';
const String _documentCountKey = 'documentCount';
const String _documentChangeCountKey = 'documentChangeCount';

const int _startKind = 0;
const int _documentsKind = 1;
const int _documentChangesKind = 2;
const int _endKind = 3;

const Map<String, Object?> querySnapshotChunkListenArguments =
    <String, Object?>{_listenChunkedArgKey: true};

@visibleForTesting
Map<String, Object?> querySnapshotChunkStartMessage({
  required int snapshotId,
  required InternalSnapshotMetadata metadata,
  required int documentCount,
  required int documentChangeCount,
}) {
  return <String, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _startKind,
    _payloadKey: metadata,
    _documentCountKey: documentCount,
    _documentChangeCountKey: documentChangeCount,
  };
}

@visibleForTesting
Map<String, Object?> querySnapshotChunkDocumentsMessage({
  required int snapshotId,
  required List<InternalDocumentSnapshot> items,
}) {
  return <String, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _documentsKind,
    _payloadKey: items,
  };
}

@visibleForTesting
Map<String, Object?> querySnapshotChunkDocumentChangesMessage({
  required int snapshotId,
  required List<InternalDocumentChange> items,
}) {
  return <String, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _documentChangesKind,
    _payloadKey: items,
  };
}

@visibleForTesting
Map<String, Object?> querySnapshotChunkEndMessage({required int snapshotId}) {
  return <String, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _endKind,
  };
}

class QuerySnapshotChunkAssembler {
  _PendingQuerySnapshot? _active;

  bool get hasPendingSnapshot => _active != null;

  void reset() {
    _active = null;
  }

  InternalQuerySnapshot? add(Object? event) {
    if (event is InternalQuerySnapshot) {
      if (_active != null) {
        throw StateError(
          'Received unchunked query snapshot while snapshot '
          '${_active!.snapshotId} was incomplete.',
        );
      }
      return event;
    }

    if (event is! Map<Object?, Object?> || event[_chunkMarkerKey] != true) {
      throw StateError('Unexpected query snapshot event: ${event.runtimeType}');
    }

    final snapshotId = _requireInt(event, _snapshotIdKey);
    final kind = _requireInt(event, _kindKey);

    switch (kind) {
      case _startKind:
        if (_active != null) {
          throw StateError(
            'Received query snapshot $snapshotId start before snapshot '
            '${_active!.snapshotId} completed.',
          );
        }
        final metadata = event[_payloadKey];
        if (metadata is! InternalSnapshotMetadata) {
          throw StateError(
            'Missing or invalid metadata for query snapshot $snapshotId.',
          );
        }
        final documentCount = _requireNonNegativeInt(event, _documentCountKey);
        final documentChangeCount = _requireNonNegativeInt(
          event,
          _documentChangeCountKey,
        );
        _active = _PendingQuerySnapshot(
          snapshotId: snapshotId,
          metadata: metadata,
          expectedDocumentCount: documentCount,
          expectedDocumentChangeCount: documentChangeCount,
        );
        return null;

      case _documentsKind:
        final active = _requireActiveSnapshot(snapshotId, 'document chunk');
        final items = _requireList<InternalDocumentSnapshot>(
          event,
          _payloadKey,
          'InternalDocumentSnapshot',
        );
        if (active.documents.length + items.length >
            active.expectedDocumentCount) {
          throw StateError(
            'Query snapshot $snapshotId received more documents than '
            'expected (${active.documents.length + items.length} > '
            '${active.expectedDocumentCount}).',
          );
        }
        active.documents.addAll(items);
        return null;

      case _documentChangesKind:
        final active = _requireActiveSnapshot(
          snapshotId,
          'document change chunk',
        );
        final items = _requireList<InternalDocumentChange>(
          event,
          _payloadKey,
          'InternalDocumentChange',
        );
        if (active.documentChanges.length + items.length >
            active.expectedDocumentChangeCount) {
          throw StateError(
            'Query snapshot $snapshotId received more document changes than '
            'expected (${active.documentChanges.length + items.length} > '
            '${active.expectedDocumentChangeCount}).',
          );
        }
        active.documentChanges.addAll(items);
        return null;

      case _endKind:
        final active = _requireActiveSnapshot(snapshotId, 'end marker');
        _active = null;
        if (active.documents.length != active.expectedDocumentCount ||
            active.documentChanges.length !=
                active.expectedDocumentChangeCount) {
          throw StateError(
            'Query snapshot $snapshotId ended incomplete: expected '
            '${active.expectedDocumentCount} documents and '
            '${active.expectedDocumentChangeCount} document changes, got '
            '${active.documents.length} and ${active.documentChanges.length}.',
          );
        }
        return InternalQuerySnapshot(
          documents: active.documents,
          documentChanges: active.documentChanges,
          metadata: active.metadata,
        );

      default:
        throw StateError('Unknown query snapshot chunk kind: $kind');
    }
  }

  _PendingQuerySnapshot _requireActiveSnapshot(
    int snapshotId,
    String frameName,
  ) {
    final active = _active;
    if (active == null) {
      throw StateError(
        'Received query snapshot $snapshotId $frameName before its start.',
      );
    }
    if (active.snapshotId != snapshotId) {
      throw StateError(
        'Received query snapshot $snapshotId $frameName while snapshot '
        '${active.snapshotId} was active.',
      );
    }
    return active;
  }

  static int _requireInt(Map<Object?, Object?> map, String key) {
    final value = map[key];
    if (value is! int) {
      throw StateError('Query snapshot chunk field "$key" must be an int.');
    }
    return value;
  }

  static int _requireNonNegativeInt(Map<Object?, Object?> map, String key) {
    final value = _requireInt(map, key);
    if (value < 0) {
      throw StateError(
        'Query snapshot chunk field "$key" must be non-negative.',
      );
    }
    return value;
  }

  static List<T> _requireList<T>(
    Map<Object?, Object?> map,
    String key,
    String elementTypeName,
  ) {
    final value = map[key];
    if (value is! List<Object?>) {
      throw StateError('Query snapshot chunk field "$key" must be a List.');
    }
    final result = <T>[];
    for (final item in value) {
      if (item is! T) {
        throw StateError(
          'Query snapshot chunk field "$key" contains non-$elementTypeName '
          'element: ${item.runtimeType}.',
        );
      }
      result.add(item);
    }
    return result;
  }
}

class _PendingQuerySnapshot {
  _PendingQuerySnapshot({
    required this.snapshotId,
    required this.metadata,
    required this.expectedDocumentCount,
    required this.expectedDocumentChangeCount,
  });

  final int snapshotId;
  final InternalSnapshotMetadata metadata;
  final int expectedDocumentCount;
  final int expectedDocumentChangeCount;
  final List<InternalDocumentSnapshot> documents = <InternalDocumentSnapshot>[];
  final List<InternalDocumentChange> documentChanges =
      <InternalDocumentChange>[];
}
