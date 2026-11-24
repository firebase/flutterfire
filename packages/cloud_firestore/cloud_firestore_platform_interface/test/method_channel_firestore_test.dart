// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/query_snapshot_chunk_assembler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'pigeon/test_api.dart';

class _MockFirebaseFirestoreHostApi extends Mock
    implements TestFirebaseFirestoreHostApi {
  final Completer<void> storeResultCalled = Completer<void>();
  final Completer<void> releaseStoreResult = Completer<void>();
  final Completer<String> snapshotObserverId = Completer<String>();
  final Completer<String> snapshotsInSyncObserverId = Completer<String>();
  final List<Completer<String>> queuedSnapshotObserverIds =
      <Completer<String>>[];

  Future<String> _nextSnapshotObserverId() {
    if (queuedSnapshotObserverIds.isNotEmpty) {
      return queuedSnapshotObserverIds.removeAt(0).future;
    }
    return snapshotObserverId.future;
  }

  @override
  Future<String> documentReferenceSnapshot(
    FirestorePigeonFirebaseApp app,
    DocumentReferenceRequest parameters,
    bool includeMetadataChanges,
    ListenSource source,
  ) => _nextSnapshotObserverId();

  @override
  Future<String> snapshotsInSyncSetup(FirestorePigeonFirebaseApp app) =>
      snapshotsInSyncObserverId.future;

  @override
  Future<InternalQuerySnapshot> namedQueryGet(
    FirestorePigeonFirebaseApp app,
    String name,
    InternalGetOptions options,
  ) async {
    final metadata = InternalSnapshotMetadata(
      hasPendingWrites: false,
      isFromCache: true,
    );
    return InternalQuerySnapshot(
      documents: [
        InternalDocumentSnapshot(
          path: 'foo/bar',
          data: {'value': 1},
          metadata: metadata,
        ),
      ],
      documentChanges: [],
      metadata: metadata,
    );
  }

  @override
  Future<String> querySnapshot(
    FirestorePigeonFirebaseApp app,
    String path,
    bool isCollectionGroup,
    InternalQueryParameters parameters,
    InternalGetOptions options,
    bool includeMetadataChanges,
    ListenSource source,
  ) => _nextSnapshotObserverId();

  @override
  Future<String> transactionCreate(
    FirestorePigeonFirebaseApp app,
    int timeout,
    int maxAttempts,
  ) async {
    return 'transaction-id';
  }

  @override
  Future<void> transactionStoreResult(
    String transactionId,
    InternalTransactionResult resultType,
    List<InternalTransactionCommand?>? commands,
  ) async {
    storeResultCalled.complete();
    await releaseStoreResult.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const transactionId = 'transaction-id';
  const channelName =
      'plugins.flutter.io/firebase_firestore/transaction/$transactionId';
  const codec = StandardMethodCodec(PigeonCodec());

  late TestDefaultBinaryMessenger messenger;
  late _MockFirebaseFirestoreHostApi hostApi;
  late Completer<void> eventChannelListened;
  late FirebaseApp app;

  setUpAll(() async {
    app = await Firebase.initializeApp(
      name: 'test-app',
      options: const FirebaseOptions(
        apiKey: 'api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
    );
  });

  setUp(() {
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    hostApi = _MockFirebaseFirestoreHostApi();
    eventChannelListened = Completer<void>();

    TestFirebaseFirestoreHostApi.setUp(hostApi);
    messenger.setMockMessageHandler(channelName, (ByteData? message) async {
      if (!eventChannelListened.isCompleted) {
        eventChannelListened.complete();
      }
      return codec.encodeSuccessEnvelope(null);
    });
  });

  tearDown(() {
    TestFirebaseFirestoreHostApi.setUp(null);
    messenger.setMockMessageHandler(channelName, null);
  });

  test('does not complete the transaction future twice when native reports an '
      'error while storing a failure', () async {
    final firestore = MethodChannelFirebaseFirestore(
      app: app,
      databaseId: '(default)',
    );

    final transactionFuture = firestore.runTransaction<void>(
      (_) => throw StateError('handler failed'),
    );

    await eventChannelListened.future;
    unawaited(
      messenger.handlePlatformMessage(
        channelName,
        codec.encodeSuccessEnvelope(<String, Object?>{'appName': 'test-app'}),
        (_) {},
      ),
    );
    await hostApi.storeResultCalled.future;

    unawaited(
      messenger.handlePlatformMessage(
        channelName,
        codec.encodeSuccessEnvelope(<String, Object?>{
          'error': <String, Object?>{
            'code': 'deadline-exceeded',
            'message': 'Transaction timed out',
          },
        }),
        (_) {},
      ),
    );

    await expectLater(
      transactionFuture,
      throwsA(
        isA<FirebaseException>().having(
          (error) => error.code,
          'code',
          'deadline-exceeded',
        ),
      ),
    );

    hostApi.releaseStoreResult.complete();
    await Future<void>.delayed(Duration.zero);
  });

  group('snapshot listener cancelled while it registers', () {
    const observerId = 'observer-id';
    const channels = <String>[
      'plugins.flutter.io/firebase_firestore/document/$observerId',
      'plugins.flutter.io/firebase_firestore/query/$observerId',
    ];
    late List<String> eventChannelCalls;

    setUp(() {
      eventChannelCalls = <String>[];
      for (final channel in channels) {
        messenger.setMockMessageHandler(channel, (ByteData? message) async {
          eventChannelCalls.add(codec.decodeMethodCall(message).method);
          return codec.encodeSuccessEnvelope(null);
        });
      }
    });

    tearDown(() {
      for (final channel in channels) {
        messenger.setMockMessageHandler(channel, null);
      }
    });

    Future<void> expectNoNativeListen(Stream<Object?> stream) async {
      await stream.listen((_) {}).cancel();
      hostApi.snapshotObserverId.complete(observerId);
      await pumpEventQueue();
      expect(eventChannelCalls, isEmpty);
    }

    late MethodChannelFirebaseFirestore firestore;

    setUp(() {
      firestore = MethodChannelFirebaseFirestore(
        app: app,
        databaseId: '(default)',
      );
    });

    test(
      'DocumentReference.snapshots() does not attach a native listener',
      () async {
        await expectNoNativeListen(
          firestore
              .doc('foo/bar')
              .snapshots(listenSource: ListenSource.defaultSource),
        );
      },
    );

    test('Query.snapshots() does not attach a native listener', () async {
      await expectNoNativeListen(
        firestore
            .collection('foo')
            .snapshots(listenSource: ListenSource.defaultSource),
      );
    });

    test('a listener that is not cancelled still attaches', () async {
      final subscription = firestore
          .doc('foo/bar')
          .snapshots(listenSource: ListenSource.defaultSource)
          .listen((_) {});
      hostApi.snapshotObserverId.complete(observerId);
      await pumpEventQueue();
      expect(eventChannelCalls, <String>['listen']);
      await subscription.cancel();
      await pumpEventQueue();
      expect(eventChannelCalls, <String>['listen', 'cancel']);
    });

    test(
      'two listeners on the same stream share one native listener',
      () async {
        final stream = firestore
            .doc('foo/bar')
            .snapshots(listenSource: ListenSource.defaultSource);
        final first = stream.listen((_) {});
        final second = stream.listen((_) {});
        hostApi.snapshotObserverId.complete(observerId);
        await pumpEventQueue();
        expect(eventChannelCalls, <String>['listen']);
        await first.cancel();
        await pumpEventQueue();
        expect(eventChannelCalls, <String>['listen']);
        await second.cancel();
        await pumpEventQueue();
        expect(eventChannelCalls, <String>['listen', 'cancel']);
      },
    );

    test('re-listen while the first pigeon call is still pending attaches only '
        'the second listener', () async {
      const firstObserverId = 'observer-id-1';
      const secondObserverId = 'observer-id-2';

      final firstObserver = Completer<String>();
      final secondObserver = Completer<String>();
      hostApi.queuedSnapshotObserverIds
        ..add(firstObserver)
        ..add(secondObserver);

      final relistenChannels = <String, List<String>>{
        'plugins.flutter.io/firebase_firestore/document/$firstObserverId':
            <String>[],
        'plugins.flutter.io/firebase_firestore/document/$secondObserverId':
            <String>[],
      };
      relistenChannels.forEach((channel, calls) {
        messenger.setMockMessageHandler(channel, (ByteData? message) async {
          calls.add(codec.decodeMethodCall(message).method);
          return codec.encodeSuccessEnvelope(null);
        });
      });
      addTearDown(() {
        for (final channel in relistenChannels.keys) {
          messenger.setMockMessageHandler(channel, null);
        }
      });

      final stream = firestore
          .doc('foo/bar')
          .snapshots(listenSource: ListenSource.defaultSource);

      await stream.listen((_) {}).cancel();
      final secondSubscription = stream.listen((_) {});

      firstObserver.complete(firstObserverId);
      await pumpEventQueue();
      secondObserver.complete(secondObserverId);
      await pumpEventQueue();

      expect(
        relistenChannels['plugins.flutter.io/firebase_firestore/document/$firstObserverId'],
        isEmpty,
      );
      expect(
        relistenChannels['plugins.flutter.io/firebase_firestore/document/$secondObserverId'],
        <String>['listen'],
      );

      await secondSubscription.cancel();
    });

    test('snapshotsInSync() does not attach a native listener when cancelled '
        'before setup completes', () async {
      const syncObserverId = 'sync-observer-id';
      const syncChannel =
          'plugins.flutter.io/firebase_firestore/snapshotsInSync/$syncObserverId';
      final syncChannelCalls = <String>[];
      messenger.setMockMessageHandler(syncChannel, (ByteData? message) async {
        syncChannelCalls.add(codec.decodeMethodCall(message).method);
        return codec.encodeSuccessEnvelope(null);
      });
      addTearDown(() => messenger.setMockMessageHandler(syncChannel, null));

      await firestore.snapshotsInSync().listen((_) {}).cancel();
      hostApi.snapshotsInSyncObserverId.complete(syncObserverId);
      await pumpEventQueue();

      expect(syncChannelCalls, isEmpty);
    });
  });

  test('namedQueryGet binds the snapshot to the calling instance', () async {
    final firestore = MethodChannelFirebaseFirestore(
      app: app,
      databaseId: 'named-query-db',
    );

    final snapshot = await firestore.namedQueryGet('named-query');

    final reference = snapshot.docs.single.reference;
    expect(reference.firestore.app.name, 'test-app');
    expect(reference.firestore.databaseId, 'named-query-db');
  });

  group('Query.snapshots() chunked delivery', () {
    const observerId = 'chunked-observer-id';
    const queryChannel =
        'plugins.flutter.io/firebase_firestore/query/$observerId';

    late MethodChannelFirebaseFirestore firestore;
    late List<MethodCall> eventChannelCalls;

    setUp(() {
      firestore = MethodChannelFirebaseFirestore(
        app: app,
        databaseId: '(default)',
      );
      eventChannelCalls = <MethodCall>[];
      messenger.setMockMessageHandler(queryChannel, (ByteData? message) async {
        eventChannelCalls.add(codec.decodeMethodCall(message));
        return codec.encodeSuccessEnvelope(null);
      });
    });

    tearDown(() {
      messenger.setMockMessageHandler(queryChannel, null);
    });

    Future<void> pushEvent(Object? event) {
      return messenger.handlePlatformMessage(
        queryChannel,
        codec.encodeSuccessEnvelope(event),
        (_) {},
      );
    }

    Future<void> pushError(String code, String message) {
      return messenger.handlePlatformMessage(
        queryChannel,
        codec.encodeErrorEnvelope(code: code, message: message),
        (_) {},
      );
    }

    InternalSnapshotMetadata snapshotMetadata() =>
        InternalSnapshotMetadata(hasPendingWrites: false, isFromCache: false);

    InternalDocumentSnapshot docSnapshot(String path, String title) =>
        InternalDocumentSnapshot(
          path: path,
          data: <String, Object?>{'title': title},
          metadata: snapshotMetadata(),
        );

    test(
      'advertises chunking support and reassembles chunked snapshots atomically',
      () async {
        final received = <QuerySnapshotPlatform>[];
        final subscription = firestore
            .collection('assets')
            .snapshots(listenSource: ListenSource.defaultSource)
            .listen(received.add);

        hostApi.snapshotObserverId.complete(observerId);
        await pumpEventQueue();

        expect(eventChannelCalls, hasLength(1));
        expect(eventChannelCalls.single.method, 'listen');
        expect(
          eventChannelCalls.single.arguments,
          equals(querySnapshotChunkListenArguments),
        );

        final docA = docSnapshot('assets/a', 'A');
        final docB = docSnapshot('assets/b', 'B');
        final changeA = InternalDocumentChange(
          type: DocumentChangeType.added,
          document: docA,
          oldIndex: -1,
          newIndex: 0,
        );
        final changeB = InternalDocumentChange(
          type: DocumentChangeType.added,
          document: docB,
          oldIndex: -1,
          newIndex: 1,
        );

        await pushEvent(
          querySnapshotChunkStartMessage(
            snapshotId: 1,
            metadata: snapshotMetadata(),
            documentCount: 2,
            documentChangeCount: 2,
          ),
        );
        await pushEvent(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[docA],
          ),
        );
        await pushEvent(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 1,
            items: <InternalDocumentSnapshot>[docB],
          ),
        );
        await pushEvent(
          querySnapshotChunkDocumentChangesMessage(
            snapshotId: 1,
            items: <InternalDocumentChange>[changeA],
          ),
        );
        await pumpEventQueue();
        expect(received, isEmpty);

        await pushEvent(
          querySnapshotChunkDocumentChangesMessage(
            snapshotId: 1,
            items: <InternalDocumentChange>[changeB],
          ),
        );
        await pushEvent(querySnapshotChunkEndMessage(snapshotId: 1));
        await pumpEventQueue();

        expect(received, hasLength(1));
        expect(received.single.docs.map((d) => d.id), <String>['a', 'b']);
        expect(received.single.docChanges.map((c) => c.document.id), <String>[
          'a',
          'b',
        ]);

        await subscription.cancel();
      },
    );

    test('resets partial chunk state after a native stream error so subsequent '
        'snapshots assemble cleanly', () async {
      final received = <QuerySnapshotPlatform>[];
      final errors = <Object>[];
      final subscription = firestore
          .collection('assets')
          .snapshots(listenSource: ListenSource.defaultSource)
          .listen(received.add, onError: errors.add);

      hostApi.snapshotObserverId.complete(observerId);
      await pumpEventQueue();

      await pushEvent(
        querySnapshotChunkStartMessage(
          snapshotId: 1,
          metadata: snapshotMetadata(),
          documentCount: 1,
          documentChangeCount: 0,
        ),
      );
      await pushError('unavailable', 'transient error');
      await pushEvent(
        querySnapshotChunkStartMessage(
          snapshotId: 2,
          metadata: snapshotMetadata(),
          documentCount: 0,
          documentChangeCount: 0,
        ),
      );
      await pushEvent(querySnapshotChunkEndMessage(snapshotId: 2));
      await pumpEventQueue();

      expect(errors, hasLength(1));
      expect(received, hasLength(1));
      expect(received.single.docs, isEmpty);

      await subscription.cancel();
    });

    test(
      'cancels the native stream on protocol corruption without flooding errors '
      'for trailing chunks',
      () async {
        final received = <QuerySnapshotPlatform>[];
        final errors = <Object>[];
        final subscription = firestore
            .collection('assets')
            .snapshots(listenSource: ListenSource.defaultSource)
            .listen(received.add, onError: errors.add);

        hostApi.snapshotObserverId.complete(observerId);
        await pumpEventQueue();

        final docA = docSnapshot('assets/a', 'A');
        await pushEvent(
          querySnapshotChunkStartMessage(
            snapshotId: 1,
            metadata: snapshotMetadata(),
            documentCount: 1,
            documentChangeCount: 1,
          ),
        );
        await pushEvent(
          querySnapshotChunkDocumentsMessage(
            snapshotId: 999,
            items: <InternalDocumentSnapshot>[docA],
          ),
        );
        await pumpEventQueue();

        await pushEvent(
          querySnapshotChunkDocumentChangesMessage(
            snapshotId: 1,
            items: <InternalDocumentChange>[
              InternalDocumentChange(
                type: DocumentChangeType.added,
                document: docA,
                oldIndex: -1,
                newIndex: 0,
              ),
            ],
          ),
        );
        await pushEvent(querySnapshotChunkEndMessage(snapshotId: 1));
        await pumpEventQueue();

        expect(received, isEmpty);
        expect(errors, hasLength(1));
        expect(errors.single, isA<StateError>());
        expect(eventChannelCalls.map((call) => call.method), <String>[
          'listen',
          'cancel',
        ]);

        await subscription.cancel();
      },
    );
  });
}
