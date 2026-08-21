// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/query_snapshot_chunk_assembler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuerySnapshotChunkAssembler', () {
    test('passes through the existing platform snapshot message', () {
      final assembler = QuerySnapshotChunkAssembler();
      final snapshot = _snapshot('projects/p/assets/a');

      expect(assembler.add(snapshot), same(snapshot));
    });

    test('reassembles chunked documents and changes atomically', () {
      final assembler = QuerySnapshotChunkAssembler();
      final first = _document('projects/p/assets/a', 1);
      final second = _document('projects/p/assets/b', 2);
      final metadata = _metadata(isFromCache: false);

      expect(
        assembler.add(
          querySnapshotChunkStart(
            snapshotId: 7,
            documentCount: 2,
            documentChangeCount: 2,
            metadata: metadata,
          ),
        ),
        isNull,
      );
      expect(
        assembler.add(querySnapshotDocumentChunk(7, <Object?>[first])),
        isNull,
      );
      expect(
        assembler.add(querySnapshotDocumentChunk(7, <Object?>[second])),
        isNull,
      );
      expect(
        assembler.add(
          querySnapshotDocumentChangeChunk(7, <Object?>[
            _change(first, 0),
            _change(second, 1),
          ]),
        ),
        isNull,
      );

      final result = assembler.add(querySnapshotChunkEnd(7));

      expect(result, isA<InternalQuerySnapshot>());
      final complete = result!;
      expect(complete.documents, <InternalDocumentSnapshot?>[first, second]);
      expect(complete.documentChanges, hasLength(2));
      expect(complete.metadata, metadata);
    });

    test('rejects a new snapshot before the active snapshot ends', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStart(
          snapshotId: 1,
          documentCount: 0,
          documentChangeCount: 0,
          metadata: _metadata(),
        ),
      );

      expect(
        () => assembler.add(
          querySnapshotChunkStart(
            snapshotId: 2,
            documentCount: 0,
            documentChangeCount: 0,
            metadata: _metadata(),
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects chunks for a different snapshot', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStart(
          snapshotId: 4,
          documentCount: 1,
          documentChangeCount: 0,
          metadata: _metadata(),
        ),
      );

      expect(
        () => assembler.add(
          querySnapshotDocumentChunk(
            5,
            <Object?>[_document('projects/p/assets/a', 1)],
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects an incomplete snapshot', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStart(
          snapshotId: 9,
          documentCount: 2,
          documentChangeCount: 0,
          metadata: _metadata(),
        ),
      );
      assembler.add(
        querySnapshotDocumentChunk(
          9,
          <Object?>[_document('projects/p/assets/a', 1)],
        ),
      );

      expect(
        () => assembler.add(querySnapshotChunkEnd(9)),
        throwsStateError,
      );
    });

    test('reset abandons an interrupted snapshot', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStart(
          snapshotId: 1,
          documentCount: 1,
          documentChangeCount: 0,
          metadata: _metadata(),
        ),
      );

      assembler.reset();

      expect(
        assembler.add(
          querySnapshotChunkStart(
            snapshotId: 2,
            documentCount: 0,
            documentChangeCount: 0,
            metadata: _metadata(),
          ),
        ),
        isNull,
      );
      expect(
        assembler.add(querySnapshotChunkEnd(2)),
        isA<InternalQuerySnapshot>(),
      );
    });

    test('reassembles messages after a Pigeon event-channel round trip', () {
      const codec = StandardMethodCodec(PigeonCodec());
      final assembler = QuerySnapshotChunkAssembler();
      final document = _document('projects/p/assets/a', 1);
      final messages = <Object?>[
        querySnapshotChunkStart(
          snapshotId: 3,
          documentCount: 1,
          documentChangeCount: 1,
          metadata: _metadata(),
        ),
        querySnapshotDocumentChunk(3, <Object?>[document]),
        querySnapshotDocumentChangeChunk(3, <Object?>[_change(document, 0)]),
        querySnapshotChunkEnd(3),
      ];

      InternalQuerySnapshot? result;
      for (final message in messages) {
        final envelope = codec.encodeSuccessEnvelope(message);
        result = assembler.add(codec.decodeEnvelope(envelope));
      }

      expect(result, isNotNull);
      expect(result!.documents.single, document);
      expect(result.documentChanges.single!.document, document);
    });
  });
}

InternalQuerySnapshot _snapshot(String path) {
  final document = _document(path, 1);
  return InternalQuerySnapshot(
    documents: <InternalDocumentSnapshot?>[document],
    documentChanges: <InternalDocumentChange?>[_change(document, 0)],
    metadata: _metadata(),
  );
}

InternalDocumentSnapshot _document(String path, int value) {
  return InternalDocumentSnapshot(
    path: path,
    data: <String?, Object?>{'value': value},
    metadata: _metadata(),
  );
}

InternalDocumentChange _change(
  InternalDocumentSnapshot document,
  int newIndex,
) {
  return InternalDocumentChange(
    type: DocumentChangeType.added,
    document: document,
    oldIndex: -1,
    newIndex: newIndex,
  );
}

InternalSnapshotMetadata _metadata({bool isFromCache = true}) {
  return InternalSnapshotMetadata(
    hasPendingWrites: false,
    isFromCache: isFromCache,
  );
}
