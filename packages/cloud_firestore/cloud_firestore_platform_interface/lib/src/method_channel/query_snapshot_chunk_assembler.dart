// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../pigeon/messages.pigeon.dart';

// These map keys and chunk kinds are mirrored by QuerySnapshotsStreamHandler
// on Android. The chunk protocol deliberately uses types already supported by
// PigeonCodec so older Apple and desktop implementations can continue emitting
// InternalQuerySnapshot directly.
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

/// Reassembles the bounded Android transport messages for one logical query
/// snapshot.
///
/// Other platforms still emit [InternalQuerySnapshot] directly, which is
/// passed through unchanged. A chunked snapshot is returned only after its end
/// marker and declared item counts have been received, preserving the public
/// stream's atomic snapshot contract.
class QuerySnapshotChunkAssembler {
  _ActiveQuerySnapshot? _active;

  /// Adds one decoded event-channel [message].
  ///
  /// Returns a complete snapshot, or `null` while a chunked snapshot is still
  /// being assembled. Throws [StateError] when the transport protocol is
  /// malformed or interleaved.
  InternalQuerySnapshot? add(Object? message) {
    if (message is InternalQuerySnapshot) {
      if (_active != null) {
        throw StateError(
          'Received a complete query snapshot while chunk assembly was active.',
        );
      }
      return message;
    }

    if (message is! Map<Object?, Object?> || message[_chunkMarkerKey] != true) {
      throw StateError('Received an unknown query snapshot message.');
    }

    final snapshotId = _requiredInt(message, _snapshotIdKey);
    final kind = _requiredInt(message, _kindKey);

    switch (kind) {
      case _startKind:
        _start(message, snapshotId);
      case _documentsKind:
        _appendDocuments(message, snapshotId);
      case _documentChangesKind:
        _appendDocumentChanges(message, snapshotId);
      case _endKind:
        return _finish(snapshotId);
      default:
        throw StateError('Unknown query snapshot chunk kind: $kind.');
    }

    return null;
  }

  /// Abandons an interrupted snapshot after cancellation or a stream error.
  void reset() {
    _active = null;
  }

  void _start(Map<Object?, Object?> message, int snapshotId) {
    if (_active != null) {
      throw StateError(
        'Query snapshot $snapshotId started before the active snapshot ended.',
      );
    }

    final documentCount = _requiredInt(message, _documentCountKey);
    final documentChangeCount = _requiredInt(message, _documentChangeCountKey);
    final metadata = message[_payloadKey];
    if (documentCount < 0 || documentChangeCount < 0) {
      throw StateError('Query snapshot item counts cannot be negative.');
    }
    if (metadata is! InternalSnapshotMetadata) {
      throw StateError('Query snapshot start is missing metadata.');
    }

    _active = _ActiveQuerySnapshot(
      id: snapshotId,
      expectedDocumentCount: documentCount,
      expectedDocumentChangeCount: documentChangeCount,
      metadata: metadata,
    );
  }

  void _appendDocuments(Map<Object?, Object?> message, int snapshotId) {
    final active = _requireActive(snapshotId);
    final payload = message[_payloadKey];
    if (payload is! List<Object?>) {
      throw StateError('Query snapshot document chunk has an invalid payload.');
    }

    active.documents.addAll(payload.cast<InternalDocumentSnapshot?>());
    if (active.documents.length > active.expectedDocumentCount) {
      throw StateError('Query snapshot received too many documents.');
    }
  }

  void _appendDocumentChanges(
    Map<Object?, Object?> message,
    int snapshotId,
  ) {
    final active = _requireActive(snapshotId);
    final payload = message[_payloadKey];
    if (payload is! List<Object?>) {
      throw StateError(
        'Query snapshot document-change chunk has an invalid payload.',
      );
    }

    active.documentChanges.addAll(payload.cast<InternalDocumentChange?>());
    if (active.documentChanges.length > active.expectedDocumentChangeCount) {
      throw StateError('Query snapshot received too many document changes.');
    }
  }

  InternalQuerySnapshot _finish(int snapshotId) {
    final active = _requireActive(snapshotId);
    _active = null;

    if (active.documents.length != active.expectedDocumentCount ||
        active.documentChanges.length != active.expectedDocumentChangeCount) {
      throw StateError(
        'Query snapshot $snapshotId ended with '
        '${active.documents.length}/${active.expectedDocumentCount} documents '
        'and ${active.documentChanges.length}/'
        '${active.expectedDocumentChangeCount} document changes.',
      );
    }

    return InternalQuerySnapshot(
      documents: active.documents,
      documentChanges: active.documentChanges,
      metadata: active.metadata,
    );
  }

  _ActiveQuerySnapshot _requireActive(int snapshotId) {
    final active = _active;
    if (active == null) {
      throw StateError(
        'Received a chunk for query snapshot $snapshotId before its start.',
      );
    }
    if (active.id != snapshotId) {
      throw StateError(
        'Received a chunk for query snapshot $snapshotId while assembling '
        '${active.id}.',
      );
    }
    return active;
  }
}

class _ActiveQuerySnapshot {
  _ActiveQuerySnapshot({
    required this.id,
    required this.expectedDocumentCount,
    required this.expectedDocumentChangeCount,
    required this.metadata,
  });

  final int id;
  final int expectedDocumentCount;
  final int expectedDocumentChangeCount;
  final InternalSnapshotMetadata metadata;
  final List<InternalDocumentSnapshot?> documents =
      <InternalDocumentSnapshot?>[];
  final List<InternalDocumentChange?> documentChanges =
      <InternalDocumentChange?>[];
}

int _requiredInt(Map<Object?, Object?> message, String key) {
  final value = message[key];
  if (value is! int) {
    throw StateError('Query snapshot chunk is missing integer "$key".');
  }
  return value;
}

/// Creates an Android query-snapshot start message for protocol tests.
Map<Object?, Object?> querySnapshotChunkStart({
  required int snapshotId,
  required int documentCount,
  required int documentChangeCount,
  required InternalSnapshotMetadata metadata,
}) {
  return <Object?, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _startKind,
    _payloadKey: metadata,
    _documentCountKey: documentCount,
    _documentChangeCountKey: documentChangeCount,
  };
}

/// Creates an Android query-snapshot document message for protocol tests.
Map<Object?, Object?> querySnapshotDocumentChunk(
  int snapshotId,
  List<Object?> documents,
) {
  return _itemChunk(snapshotId, _documentsKind, documents);
}

/// Creates an Android query-snapshot change message for protocol tests.
Map<Object?, Object?> querySnapshotDocumentChangeChunk(
  int snapshotId,
  List<Object?> documentChanges,
) {
  return _itemChunk(snapshotId, _documentChangesKind, documentChanges);
}

/// Creates an Android query-snapshot end message for protocol tests.
Map<Object?, Object?> querySnapshotChunkEnd(int snapshotId) {
  return <Object?, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: _endKind,
  };
}

Map<Object?, Object?> _itemChunk(
  int snapshotId,
  int kind,
  List<Object?> payload,
) {
  return <Object?, Object?>{
    _chunkMarkerKey: true,
    _snapshotIdKey: snapshotId,
    _kindKey: kind,
    _payloadKey: payload,
  };
}
