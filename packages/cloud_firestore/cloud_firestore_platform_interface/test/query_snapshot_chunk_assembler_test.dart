// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/query_snapshot_chunk_assembler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InternalSnapshotMetadata metadata({
    bool hasPendingWrites = false,
    bool isFromCache = false,
  }) {
    return InternalSnapshotMetadata(
      hasPendingWrites: hasPendingWrites,
      isFromCache: isFromCache,
    );
  }

  InternalDocumentSnapshot document(String path, String title) {
    return InternalDocumentSnapshot(
      path: path,
      data: <String, Object?>{'title': title},
      metadata: metadata(),
    );
  }

  InternalDocumentChange change(
    InternalDocumentSnapshot doc, {
    DocumentChangeType type = DocumentChangeType.added,
    int oldIndex = -1,
    int newIndex = 0,
  }) {
    return InternalDocumentChange(
      type: type,
      document: doc,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  group('$QuerySnapshotChunkAssembler', () {
    test('passes unchunked snapshots through unchanged', () {
      final assembler = QuerySnapshotChunkAssembler();
      final doc = document('projects/p/assets/a', 'A');
      final snapshot = InternalQuerySnapshot(
        documents: <InternalDocumentSnapshot>[doc],
        documentChanges: <InternalDocumentChange>[change(doc)],
        metadata: metadata(isFromCache: true),
      );

      expect(assembler.add(snapshot), same(snapshot));
      expect(assembler.hasPendingSnapshot, isFalse);
    });

    test('reassembles a multi-chunk snapshot atomically in order', () {
      final assembler = QuerySnapshotChunkAssembler();
      final docA = document('projects/p/assets/a', 'A');
      final docB = document('projects/p/assets/b', 'B');
      final docC = document('projects/p/assets/c', 'C');
      final changeA = change(docA);
      final changeB = change(docB, newIndex: 1);
      final changeC = change(docC, newIndex: 2);
      final snapshotMeta = metadata(hasPendingWrites: true, isFromCache: true);

      expect(
        assembler.add(
          querySnapshotChunkStartMessage(
            snapshotId: 1,
            metadata: snapshotMeta,
            documentCount: 3,
            documentChangeCount: 3,
          ),
        ),
        isNull,
      );
      expect(assembler.hasPendingSnapshot, isTrue);

      expect(
        assembler.add(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[docA, docB],
          ),
        ),
        isNull,
      );
      expect(
        assembler.add(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[docC],
          ),
        ),
        isNull,
      );
      expect(
        assembler.add(
          querySnapshotChunkDocumentChangesMessage(
            snapshotId: 1,
            items: <InternalDocumentChange>[changeA],
          ),
        ),
        isNull,
      );
      expect(
        assembler.add(
          querySnapshotChunkDocumentChangesMessage(
            snapshotId: 1,
            items: <InternalDocumentChange>[changeB, changeC],
          ),
        ),
        isNull,
      );

      final assembled = assembler.add(
        querySnapshotChunkEndMessage(snapshotId: 1),
      );
      expect(assembled, isNotNull);
      expect(assembler.hasPendingSnapshot, isFalse);
      expect(assembled!.metadata.hasPendingWrites, isTrue);
      expect(assembled.metadata.isFromCache, isTrue);
      expect(assembled.documents.map((d) => d!.path), <String>[
        'projects/p/assets/a',
        'projects/p/assets/b',
        'projects/p/assets/c',
      ]);
      expect(assembled.documentChanges.map((c) => c!.newIndex), <int>[0, 1, 2]);
    });

    test('reassembles an empty snapshot from start and end messages', () {
      final assembler = QuerySnapshotChunkAssembler();
      final snapshotMeta = metadata();

      expect(
        assembler.add(
          querySnapshotChunkStartMessage(
            snapshotId: 1,
            metadata: snapshotMeta,
            documentCount: 0,
            documentChangeCount: 0,
          ),
        ),
        isNull,
      );

      final assembled = assembler.add(
        querySnapshotChunkEndMessage(snapshotId: 1),
      );
      expect(assembled, isNotNull);
      expect(assembled!.documents, isEmpty);
      expect(assembled.documentChanges, isEmpty);
    });

    test('rejects chunk before start', () {
      final assembler = QuerySnapshotChunkAssembler();

      expect(
        () => assembler.add(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[
              document('projects/p/assets/a', 'A'),
            ],
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects mismatched snapshot id', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );

      expect(
        () => assembler.add(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 2,
            items: <InternalDocumentSnapshot>[
              document('projects/p/assets/a', 'A'),
            ],
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects overlapping start before previous snapshot ends', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );

      expect(
        () => assembler.add(
          querySnapshotChunkStartMessage(
            snapshotId: 2,
            metadata: metadata(),
            documentCount: 0,
            documentChangeCount: 0,
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects unchunked snapshot while chunked snapshot is in flight', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );

      expect(
        () => assembler.add(
          InternalQuerySnapshot(
            documents: <InternalDocumentSnapshot>[],
            documentChanges: <InternalDocumentChange>[],
            metadata: metadata(),
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects end when counts do not match', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 2,
          documentChangeCount: 0,
        ),
      );
      assembler.add(
        querySnapshotChunkDocumentsMessage(
          snapshotId: 1,
          items: <InternalDocumentSnapshot>[
            document('projects/p/assets/a', 'A'),
          ],
        ),
      );

      expect(
        () => assembler.add(querySnapshotChunkEndMessage(snapshotId: 1)),
        throwsStateError,
      );
      expect(assembler.hasPendingSnapshot, isFalse);
    });

    test('rejects chunks exceeding declared count', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );

      expect(
        () => assembler.add(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[
              document('projects/p/assets/a', 'A'),
              document('projects/p/assets/b', 'B'),
            ],
          ),
        ),
        throwsStateError,
      );
    });

    test('rejects unknown event types and unknown chunk kinds', () {
      final assembler = QuerySnapshotChunkAssembler();

      expect(() => assembler.add('unexpected'), throwsStateError);
      expect(
        () => assembler.add(<String, Object?>{'snapshotId': 1, 'kind': 0}),
        throwsStateError,
      );
      expect(
        () => assembler.add(<String, Object?>{
          'firestoreQuerySnapshotChunk': true,
          'snapshotId': 1,
          'kind': 99,
        }),
        throwsStateError,
      );
    });

    test('reset clears partial state so next snapshot succeeds', () {
      final assembler = QuerySnapshotChunkAssembler();
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: metadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );
      assembler.reset();

      expect(assembler.hasPendingSnapshot, isFalse);
      assembler.add(
        querySnapshotChunkStartMessage(
          snapshotId: 2,
          metadata: metadata(),
          documentCount: 0,
          documentChangeCount: 0,
        ),
      );
      final assembled = assembler.add(
        querySnapshotChunkEndMessage(snapshotId: 2),
      );
      expect(assembled, isNotNull);
    });
  });
}
