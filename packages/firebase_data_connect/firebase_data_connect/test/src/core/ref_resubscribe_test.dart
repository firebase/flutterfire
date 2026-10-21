// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/cache/cache.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../network/websocket_transport_test.mocks.dart';

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

/// Cache that keeps the last server response per query in memory.
class FakeCache extends Fake implements Cache {
  final Map<String, Map<String, dynamic>> _results = {};

  @override
  Future<void> update(String queryId, ServerResponse serverResponse) async {
    _results[queryId] = serverResponse.data;
  }

  @override
  Future<Map<String, dynamic>?> resultTree(
          String queryId, bool allowStale) async =>
      _results[queryId];
}

/// Minimal in-memory transport that records subscribe/cancel and lets a test
/// push events into whichever stream is currently listened to.
class FakeStreamTransport implements DataConnectTransport {
  FakeStreamTransport(this.transportOptions, this.options, this.appId,
      this.sdkType, this.appCheck);

  @override
  FirebaseAppCheck? appCheck;
  @override
  DataConnectOptions options;
  @override
  TransportOptions transportOptions;
  @override
  CallerSDKType sdkType;
  @override
  String appId;

  final List<String> log = <String>[];
  int subscribeCount = 0;
  final Set<StreamController<ServerResponse>> _live =
      <StreamController<ServerResponse>>{};

  /// Server streams that are still subscribed. Anything left here once every
  /// caller has cancelled is an orphan the ref layer can no longer reach — in
  /// the real WebSocket transport that pins `_activeSubscriptions`, so every
  /// later subscribe to the query multiplexes onto it and gets no first event.
  int get liveSubscriptions => _live.length;

  /// Pushes an event to every currently subscribed stream.
  void emit(Map<String, dynamic> data) {
    for (final c in _live.toList()) {
      if (!c.isClosed) c.add(ServerResponse(data));
    }
  }

  @override
  Stream<ServerResponse> invokeStreamQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) {
    late StreamController<ServerResponse> controller;
    controller = StreamController<ServerResponse>(
      onListen: () {
        subscribeCount++;
        _live.add(controller);
        log.add('subscribe');
      },
      onCancel: () {
        log.add('cancel');
        _live.remove(controller);
      },
    );
    return controller.stream;
  }

  @override
  Future<ServerResponse> invokeQuery<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serialize,
    Variables? vars,
    String? token,
  ) async =>
      ServerResponse(<String, dynamic>{});

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) async =>
      ServerResponse(<String, dynamic>{});
}

void main() {
  late MockFirebaseDataConnect dataConnect;
  late FakeStreamTransport transport;
  late QueryManager queryManager;

  String deserializer(String data) => data;

  setUp(() {
    dataConnect = MockFirebaseDataConnect();
    when(dataConnect.auth).thenReturn(null);
    when(dataConnect.cacheManager).thenReturn(null);
    transport = FakeStreamTransport(
      TransportOptions('testhost', 443, true),
      DataConnectOptions(
        'testProject',
        'testLocation',
        'testConnector',
        'testService',
      ),
      'testAppId',
      CallerSDKType.core,
      null,
    );
    queryManager = QueryManager(dataConnect);
  });

  QueryRef<String, String?> buildRef() => QueryRef<String, String?>(
        dataConnect,
        'listMovies',
        transport,
        deserializer,
        queryManager,
        emptySerializer,
        null,
      );

  /// Waits for a first event on [stream], returning false if it never arrives.
  Future<bool> firstEventArrives(
    Stream<QueryResult<String, String?>> stream,
    void Function() pump,
  ) async {
    final received = Completer<void>();
    final sub = stream.listen((_) {
      if (!received.isCompleted) received.complete();
    });
    // Let subscribe() run its microtask and reach the transport.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    pump();
    try {
      await received.future.timeout(const Duration(milliseconds: 300));
      return true;
    } on TimeoutException {
      return false;
    } finally {
      await sub.cancel();
    }
  }

  group('QueryRef double subscribe', () {
    test('two subscribe() calls on the same ref open exactly one server stream',
        () async {
      final ref = buildRef();

      // Exactly the shape of the `should be able to gracefully cancel` e2e
      // test: two listeners for the same query, back to back, which
      // `FirebaseDataConnect.query()` resolves to the *same* cached QueryRef.
      final a = ref.subscribe().listen((_) {});
      final b = ref.subscribe().listen((_) {});

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.subscribeCount, 1,
          reason: 'the second subscriber must multiplex onto the existing '
              'server stream, not open a second one that nothing can cancel');

      await a.cancel();
      await b.cancel();

      // Everything the ref opened must be cancelled once all subscribers go.
      expect(transport.liveSubscriptions, 0,
          reason: 'no server stream may outlive its last subscriber');
    });
  });

  group('QueryRef re-subscribe after cancel', () {
    test('a query is re-subscribable after a double-subscribe generation',
        () async {
      final ref = buildRef();

      // Generation 1: two listeners, then both cancelled.
      final a = ref.subscribe().listen((_) {});
      final b = ref.subscribe().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
      transport.emit({'movies': []});
      await a.cancel();
      await b.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Generation 2: a fresh ref, exactly as `query()` hands out once
      // trackedQueries has been cleaned.
      expect(
        await firstEventArrives(
            buildRef().subscribe(), () => transport.emit({'movies': []})),
        isTrue,
        reason: 'a later subscription to the same query must still receive '
            'a first event',
      );
    });

    test('re-subscribing the same ref after a plain cancel gets a first event',
        () async {
      final ref = buildRef();

      expect(
        await firstEventArrives(
            ref.subscribe(), () => transport.emit({'movies': []})),
        isTrue,
        reason: 'first subscription should receive an event',
      );

      expect(
        await firstEventArrives(
            ref.subscribe(), () => transport.emit({'movies': []})),
        isTrue,
        reason: 're-subscribing the same QueryRef must restart the '
            'server stream and deliver a first event',
      );
    });

    test(
        'a listener attached while the previous cancel is still pending is not '
        'stranded', () async {
      final ref = buildRef();

      // First subscriber, established and receiving events.
      final firstReady = Completer<void>();
      final first = ref.subscribe().listen((_) {
        if (!firstReady.isCompleted) firstReady.complete();
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'movies': []});
      await firstReady.future.timeout(const Duration(seconds: 1));

      // Cancel WITHOUT awaiting and immediately re-subscribe in the same turn.
      // This is the shape the e2e suite hits: `_onAllSubscribersCancelled()`
      // tears the server stream down out-of-band while a new listener is
      // already attaching to the very same (reused) broadcast controller.
      unawaited(first.cancel());

      final secondReady = Completer<void>();
      final second = ref.subscribe().listen((_) {
        if (!secondReady.isCompleted) secondReady.complete();
      });

      await Future<void>.delayed(const Duration(milliseconds: 50));
      transport.emit({'movies': []});

      var gotEvent = true;
      try {
        await secondReady.future.timeout(const Duration(milliseconds: 300));
      } on TimeoutException {
        gotEvent = false;
      }
      await second.cancel();

      expect(gotEvent, isTrue,
          reason: 'the second subscriber must not be stranded on a '
              'controller whose server stream was torn down');
    });

    test('cancelling from inside the event handler still allows re-subscribe',
        () async {
      final ref = buildRef();

      // Cancelling from within delivery makes the broadcast controller defer
      // onCancel until the firing loop finishes.
      late StreamSubscription<QueryResult<String, String?>> first;
      final delivered = Completer<void>();
      first = ref.subscribe().listen((_) {
        unawaited(first.cancel());
        if (!delivered.isCompleted) delivered.complete();
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'movies': []});
      await delivered.future.timeout(const Duration(seconds: 1));

      expect(
        await firstEventArrives(
            ref.subscribe(), () => transport.emit({'movies': []})),
        isTrue,
        reason: 're-subscribing after a deferred cancel must restart the '
            'server stream',
      );
    });
  });

  group('QueryRef late subscriber', () {
    test('a subscriber joining a live query gets the last result', () async {
      final ref = buildRef();
      final a = <String>[];
      final b = <String>[];

      final subA = ref.subscribe().listen((r) => a.add(r.data));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'v': 1});
      transport.emit({'v': 2});
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // A second screen subscribes while the first one is still mounted. The
      // server won't push again until the data changes.
      final subB = ref.subscribe().listen((r) => b.add(r.data));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(b, ['{"v":2}'],
          reason: 'the new subscriber must get the latest result right away');
      expect(a, ['{"v":1}', '{"v":2}'],
          reason: 'the existing subscriber must not get it a second time');
      expect(transport.subscribeCount, 1);

      transport.emit({'v': 3});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(a, ['{"v":1}', '{"v":2}', '{"v":3}']);
      expect(b, ['{"v":2}', '{"v":3}']);

      await subA.cancel();
      await subB.cancel();
    });

    test('subscribers of a restarted server stream get no stale result',
        () async {
      final ref = buildRef();

      final first = ref.subscribe().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'v': 1});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await first.cancel();

      final second = <String>[];
      final third = <String>[];
      final subSecond = ref.subscribe().listen((r) => second.add(r.data));
      // Let subscribe() start the new server stream, then join it while it is
      // still starting up.
      await Future.microtask(() {});
      final subThird = ref.subscribe().listen((r) => third.add(r.data));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(second, isEmpty,
          reason: 'the result of a server stream that was torn down is stale');
      expect(third, isEmpty,
          reason: 'the result of a server stream that was torn down is stale');

      transport.emit({'v': 2});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(second, ['{"v":2}']);
      expect(third, ['{"v":2}']);

      await subSecond.cancel();
      await subThird.cancel();
    });

    test(
        'a late subscriber after a user switch gets no result of the previous '
        'user', () async {
      final auth = MockFirebaseAuth();
      final userA = MockUser();
      final userB = MockUser();
      when(userA.uid).thenReturn('uid-a');
      when(userB.uid).thenReturn('uid-b');
      when(userA.getIdToken()).thenAnswer((_) async => 'token-a');
      when(userB.getIdToken()).thenAnswer((_) async => 'token-b');
      when(auth.currentUser).thenReturn(userA);
      when(dataConnect.auth).thenReturn(auth);
      final ref = buildRef();

      final subA = ref.subscribe().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'user': 'a'});
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // User B signs in. The WebSocket transport keeps the server stream open
      // and only resubscribes it as B after a reconnect delay, so A's result is
      // still the last one this ref has seen.
      when(auth.currentUser).thenReturn(userB);

      final b = <QueryResult<String, String?>>[];
      final subB = ref.subscribe().listen(b.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(b, isEmpty,
          reason: "a subscriber must not get the previous user's result");

      transport.emit({'user': 'b'});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(b.map((r) => r.data), ['{"user":"b"}']);

      // B's own result is replayed again to B's later subscribers.
      final c = <String>[];
      final subC = ref.subscribe().listen((r) => c.add(r.data));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c, ['{"user":"b"}']);

      await subA.cancel();
      await subB.cancel();
      await subC.cancel();
    });

    test('with a cache, a late subscriber gets the cached result only',
        () async {
      when(dataConnect.cacheManager).thenReturn(FakeCache());
      final ref = buildRef();
      final b = <QueryResult<String, String?>>[];

      final subA = ref.subscribe().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      transport.emit({'v': 1});
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final subB = ref.subscribe().listen(b.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(b.map((r) => r.source), [DataSource.cache]);
      expect(b.single.data, '{"v":1}');

      await subA.cancel();
      await subB.cancel();
    });
  });
}
