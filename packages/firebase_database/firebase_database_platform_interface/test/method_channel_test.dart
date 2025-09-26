// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database.dart';
import 'package:firebase_database_platform_interface/src/method_channel/method_channel_database_reference.dart';
import 'package:firebase_database_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pigeon/test_api.dart';
import 'test_common.dart';

class MockFirebaseDatabaseHostApi implements TestFirebaseDatabaseHostApi {
  final List<Map<String, dynamic>> log = <Map<String, dynamic>>[];

  @override
  Future<void> goOnline(pigeon.DatabasePigeonFirebaseApp app) async {
    log.add({'method': 'goOnline', 'app': app});
  }

  @override
  Future<void> goOffline(pigeon.DatabasePigeonFirebaseApp app) async {
    log.add({'method': 'goOffline', 'app': app});
  }

  @override
  Future<void> setPersistenceEnabled(
    pigeon.DatabasePigeonFirebaseApp app,
    bool enabled,
  ) async {
    log.add(
      {'method': 'setPersistenceEnabled', 'app': app, 'enabled': enabled},
    );
  }

  @override
  Future<void> setPersistenceCacheSizeBytes(
    pigeon.DatabasePigeonFirebaseApp app,
    int cacheSize,
  ) async {
    log.add({
      'method': 'setPersistenceCacheSizeBytes',
      'app': app,
      'cacheSize': cacheSize,
    });
  }

  @override
  Future<void> setLoggingEnabled(
    pigeon.DatabasePigeonFirebaseApp app,
    bool enabled,
  ) async {
    log.add({'method': 'setLoggingEnabled', 'app': app, 'enabled': enabled});
  }

  @override
  Future<void> useDatabaseEmulator(
    pigeon.DatabasePigeonFirebaseApp app,
    String host,
    int port,
  ) async {
    log.add({
      'method': 'useDatabaseEmulator',
      'app': app,
      'host': host,
      'port': port,
    });
  }

  @override
  Future<pigeon.DatabaseReferencePlatform> ref(
      pigeon.DatabasePigeonFirebaseApp app,
      // ignore: require_trailing_commas
      [String? path]) async {
    log.add({'method': 'ref', 'app': app, 'path': path});
    return pigeon.DatabaseReferencePlatform(
      path: path ?? '',
    );
  }

  @override
  Future<pigeon.DatabaseReferencePlatform> refFromURL(
    pigeon.DatabasePigeonFirebaseApp app,
    String url,
  ) async {
    log.add({'method': 'refFromURL', 'app': app, 'url': url});
    return pigeon.DatabaseReferencePlatform(
      path: '',
    );
  }

  @override
  Future<void> purgeOutstandingWrites(
    pigeon.DatabasePigeonFirebaseApp app,
  ) async {
    log.add({'method': 'purgeOutstandingWrites', 'app': app});
  }

  @override
  Future<void> databaseReferenceSet(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.DatabaseReferenceRequest request,
  ) async {
    log.add({'method': 'databaseReferenceSet', 'app': app, 'request': request});
  }

  @override
  Future<void> databaseReferenceSetWithPriority(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.DatabaseReferenceRequest request,
  ) async {
    log.add({
      'method': 'databaseReferenceSetWithPriority',
      'app': app,
      'request': request,
    });
  }

  @override
  Future<void> databaseReferenceUpdate(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.UpdateRequest request,
  ) async {
    log.add(
      {'method': 'databaseReferenceUpdate', 'app': app, 'request': request},
    );
  }

  @override
  Future<void> databaseReferenceSetPriority(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.DatabaseReferenceRequest request,
  ) async {
    log.add({
      'method': 'databaseReferenceSetPriority',
      'app': app,
      'request': request,
    });
  }

  @override
  Future<void> databaseReferenceRunTransaction(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.TransactionRequest request,
  ) async {
    log.add({
      'method': 'databaseReferenceRunTransaction',
      'app': app,
      'request': request,
    });
  }

  @override
  Future<Map<String, Object?>> databaseReferenceGetTransactionResult(
    pigeon.DatabasePigeonFirebaseApp app,
    int transactionKey,
  ) async {
    log.add({
      'method': 'databaseReferenceGetTransactionResult',
      'app': app,
      'transactionKey': transactionKey,
    });
    return {
      'error': null,
      'committed': true,
      'snapshot': {
        'key': 'fakeKey',
        'value': {'fakeKey': 'updated fakeValue'},
      },
      'childKeys': ['fakeKey'],
    };
  }

  @override
  Future<void> onDisconnectSet(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.DatabaseReferenceRequest request,
  ) async {
    log.add({'method': 'onDisconnectSet', 'app': app, 'request': request});
  }

  @override
  Future<void> onDisconnectSetWithPriority(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.DatabaseReferenceRequest request,
  ) async {
    log.add({
      'method': 'onDisconnectSetWithPriority',
      'app': app,
      'request': request,
    });
  }

  @override
  Future<void> onDisconnectUpdate(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.UpdateRequest request,
  ) async {
    log.add({'method': 'onDisconnectUpdate', 'app': app, 'request': request});
  }

  @override
  Future<void> onDisconnectCancel(
    pigeon.DatabasePigeonFirebaseApp app,
    String path,
  ) async {
    log.add({'method': 'onDisconnectCancel', 'app': app, 'path': path});
  }

  @override
  Future<String> queryObserve(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.QueryRequest request,
  ) async {
    log.add({'method': 'queryObserve', 'app': app, 'request': request});
    return 'mock/path';
  }

  @override
  Future<void> queryKeepSynced(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.QueryRequest request,
  ) async {
    log.add({'method': 'queryKeepSynced', 'app': app, 'request': request});
  }

  @override
  Future<Map<String, Object?>> queryGet(
    pigeon.DatabasePigeonFirebaseApp app,
    pigeon.QueryRequest request,
  ) async {
    log.add({'method': 'queryGet', 'app': app, 'request': request});
    return {
      'value': 'test-value',
      'key': 'test-key',
    };
  }
}

void main() {
  initializeMethodChannel();
  late FirebaseApp app;
  late MockFirebaseDatabaseHostApi mockApi;

  setUpAll(() async {
    app = await Firebase.initializeApp(
      name: 'testApp',
      options: const FirebaseOptions(
        appId: '1:1234567890:ios:42424242424242',
        apiKey: '123',
        projectId: '123',
        messagingSenderId: '1234567890',
      ),
    );

    mockApi = MockFirebaseDatabaseHostApi();
    TestFirebaseDatabaseHostApi.setUp(mockApi);
  });

  group('MethodChannelDatabase', () {
    const eventChannel = MethodChannel('mock/path');

    const String databaseURL = 'https://fake-database-url2.firebaseio.com';
    late MethodChannelDatabase database;

    setUp(() async {
      database = MethodChannelDatabase(app: app, databaseURL: databaseURL);
      mockApi.log.clear();
    });

    test('setting database instance options', () async {
      database.setLoggingEnabled(true);
      database.setPersistenceCacheSizeBytes(10000);
      database.setPersistenceEnabled(true);
      database.useDatabaseEmulator('localhost', 1234);
      // Options are only sent on subsequent calls to Pigeon.
      await database.goOnline();
      expect(
        mockApi.log,
        <Matcher>[
          containsPair('method', 'setLoggingEnabled'),
          containsPair('method', 'setPersistenceCacheSizeBytes'),
          containsPair('method', 'setPersistenceEnabled'),
          containsPair('method', 'useDatabaseEmulator'),
          containsPair('method', 'goOnline'),
        ],
      );
    });

    test('goOnline', () async {
      await database.goOnline();
      expect(
        mockApi.log,
        <Matcher>[
          containsPair('method', 'goOnline'),
        ],
      );
    });

    test('goOffline', () async {
      await database.goOffline();
      expect(
        mockApi.log,
        <Matcher>[
          containsPair('method', 'goOffline'),
        ],
      );
    });

    test('purgeOutstandingWrites', () async {
      await database.purgeOutstandingWrites();
      expect(
        mockApi.log,
        <Matcher>[
          containsPair('method', 'purgeOutstandingWrites'),
        ],
      );
    });

    group('$MethodChannelDatabaseReference', () {
      test('set & setWithPriority', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        final dynamic serverValue = <String, dynamic>{
          'qux': ServerValue.increment(8),
        };
        const int priority = 42;
        await database.ref('foo').set(value);
        await database.ref('bar').setWithPriority(value, priority);
        await database.ref('bar').setWithPriority(value, null);
        await database.ref('baz').set(serverValue);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'databaseReferenceSet'),
            containsPair('method', 'databaseReferenceSetWithPriority'),
            containsPair('method', 'databaseReferenceSetWithPriority'),
            containsPair('method', 'databaseReferenceSet'),
          ],
        );
      });
      test('update', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        await database.ref('foo').update(value);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'databaseReferenceUpdate'),
          ],
        );
      });

      test('setPriority', () async {
        const int priority = 42;
        await database.ref('foo').setPriority(priority);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'databaseReferenceSetPriority'),
          ],
        );
      });

      test('runTransaction', () async {
        final ref = database.ref('foo');

        final result = await ref.runTransaction((value) {
          return Transaction.success(<String, Object?>{
            ...value! as Map,
            'fakeKey': 'updated ${(value as Map)['fakeKey']}',
          });
        });

        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'databaseReferenceRunTransaction'),
            containsPair('method', 'databaseReferenceGetTransactionResult'),
          ],
        );

        expect(result.committed, equals(true));

        expect(
          result.snapshot.value,
          equals(<String, dynamic>{'fakeKey': 'updated fakeValue'}),
        );
      });
    });

    group('MethodChannelOnDisconnect', () {
      test('set', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        const int priority = 42;
        final DatabaseReferencePlatform ref = database.ref();
        await ref.child('foo').onDisconnect().set(value);
        await ref.child('bar').onDisconnect().setWithPriority(value, priority);
        await ref
            .child('psi')
            .onDisconnect()
            .setWithPriority(value, 'priority');
        await ref.child('por').onDisconnect().setWithPriority(value, value);
        await ref.child('por').onDisconnect().setWithPriority(value, null);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'onDisconnectSet'),
            containsPair('method', 'onDisconnectSetWithPriority'),
            containsPair('method', 'onDisconnectSetWithPriority'),
            containsPair('method', 'onDisconnectSetWithPriority'),
            containsPair('method', 'onDisconnectSetWithPriority'),
          ],
        );
      });
      test('update', () async {
        final dynamic value = <String, dynamic>{'hello': 'world'};
        await database.ref('foo').onDisconnect().update(value);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'onDisconnectUpdate'),
          ],
        );
      });
      test('cancel', () async {
        await database.ref('foo').onDisconnect().cancel();
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'onDisconnectCancel'),
          ],
        );
      });
      test('remove', () async {
        await database.ref('foo').onDisconnect().remove();
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'onDisconnectSet'),
          ],
        );
      });
    });

    group('MethodChannelQuery', () {
      test('keepSynced, simple query', () async {
        const String path = 'foo';
        final QueryPlatform query = database.ref(path);
        await query.keepSynced(QueryModifiers([]), true);
        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'queryKeepSynced'),
          ],
        );
      });
      test('observing error events', () async {
        const String errorCode = 'some-error';

        final QueryPlatform query = database.ref('some/path');

        Future<void> simulateError(String errorMessage) async {
          await TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .handlePlatformMessage(
            eventChannel.name,
            eventChannel.codec.encodeErrorEnvelope(
              code: errorCode,
              message: errorMessage,
              details: {
                'code': errorCode,
                'message': errorMessage,
              },
            ),
            (_) {},
          );
        }

        final errors = AsyncQueue<FirebaseException>();

        final subscription = query
            .onValue(QueryModifiers([]))
            .listen((_) {}, onError: errors.add);
        await Future<void>.delayed(Duration.zero);

        await simulateError('Bad foo');
        await simulateError('Bad bar');

        final FirebaseException error1 = await errors.remove();
        final FirebaseException error2 = await errors.remove();

        await subscription.cancel();

        expect(
          error1.toString(),
          startsWith('[firebase_database/some-error] Bad foo'),
        );

        expect(error1.code, errorCode);
        expect(error1.message, 'Bad foo');

        expect(error2.code, errorCode);
        expect(error2.message, 'Bad bar');
      });

      test('observing value events', () async {
        const String path = 'foo';
        final QueryPlatform query = database.ref(path);

        Future<void> simulateEvent(Map<String, dynamic> event) async {
          await TestDefaultBinaryMessengerBinding
              .instance.defaultBinaryMessenger
              .handlePlatformMessage(
            eventChannel.name,
            eventChannel.codec.encodeSuccessEnvelope(event),
            (_) {},
          );
        }

        Map<String, dynamic> createValueEvent(dynamic value) {
          return {
            'eventType': 'value',
            'snapshot': {
              'value': value,
              'key': path.split('/').last,
            },
          };
        }

        final AsyncQueue<DatabaseEventPlatform> events =
            AsyncQueue<DatabaseEventPlatform>();

        // Subscribe and allow subscription to complete.
        final subscription =
            query.onValue(QueryModifiers([])).listen(events.add);
        await Future<void>.delayed(Duration.zero);

        await simulateEvent(createValueEvent(1));
        await simulateEvent(createValueEvent(2));

        final DatabaseEventPlatform event1 = await events.remove();
        final DatabaseEventPlatform event2 = await events.remove();

        expect(event1.snapshot.key, path);
        expect(event1.snapshot.value, 1);
        expect(event2.snapshot.key, path);
        expect(event2.snapshot.value, 2);

        // Cancel subscription and allow cancellation to complete.
        await subscription.cancel();
        await Future.delayed(Duration.zero);

        expect(
          mockApi.log,
          <Matcher>[
            containsPair('method', 'queryObserve'),
          ],
        );
      });
    });
  });
}

/// Queue whose remove operation is asynchronous, awaiting a corresponding add.
class AsyncQueue<T> {
  Map<int, Completer<T>> _completers = <int, Completer<T>>{};
  int _nextToRemove = 0;
  int _nextToAdd = 0;

  void add(T element) {
    _completer(_nextToAdd++).complete(element);
  }

  Future<T> remove() {
    return _completer(_nextToRemove++).future;
  }

  Completer<T> _completer(int index) {
    if (_completers.containsKey(index)) {
      return _completers.remove(index)!;
    } else {
      return _completers[index] = Completer<T>();
    }
  }
}
