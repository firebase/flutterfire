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
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseDataConnect extends Mock implements FirebaseDataConnect {}

/// Minimal in-memory transport that records subscribe/cancel and lets a test
/// push events into whichever stream is currently listened to.
class FakeStreamTransport implements DataConnectTransport {
  FakeStreamTransport(
    this.transportOptions,
    this.options,
    this.appId,
    this.sdkType,
    this.appCheck,
  );

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
  ) async => ServerResponse(<String, dynamic>{});

  @override
  Future<ServerResponse> invokeMutation<Data, Variables>(
    String operationId,
    String queryName,
    Deserializer<Data> deserializer,
    Serializer<Variables>? serializer,
    Variables? vars,
    String? token,
  ) async => ServerResponse(<String, dynamic>{});
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
    test(
      'two subscribe() calls on the same ref open exactly one server stream',
      () async {
        final ref = buildRef();

        // Exactly the shape of the `should be able to gracefully cancel` e2e
        // test: two listeners for the same query, back to back, which
        // `FirebaseDataConnect.query()` resolves to the *same* cached QueryRef.
        final a = ref.subscribe().listen((_) {});
        final b = ref.subscribe().listen((_) {});

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          transport.subscribeCount,
          1,
          reason:
              'the second subscriber must multiplex onto the existing '
              'server stream, not open a second one that nothing can cancel',
        );

        await a.cancel();
        await b.cancel();

        // Everything the ref opened must be cancelled once all subscribers go.
        expect(
          transport.liveSubscriptions,
          0,
          reason: 'no server stream may outlive its last subscriber',
        );
      },
    );
  });

  group('QueryRef re-subscribe after cancel', () {
    test(
      'a query is re-subscribable after a double-subscribe generation',
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
            buildRef().subscribe(),
            () => transport.emit({'movies': []}),
          ),
          isTrue,
          reason:
              'a later subscription to the same query must still receive '
              'a first event',
        );
      },
    );

    test(
      're-subscribing the same ref after a plain cancel gets a first event',
      () async {
        final ref = buildRef();

        expect(
          await firstEventArrives(
            ref.subscribe(),
            () => transport.emit({'movies': []}),
          ),
          isTrue,
          reason: 'first subscription should receive an event',
        );

        expect(
          await firstEventArrives(
            ref.subscribe(),
            () => transport.emit({'movies': []}),
          ),
          isTrue,
          reason:
              're-subscribing the same QueryRef must restart the '
              'server stream and deliver a first event',
        );
      },
    );

    test('a listener attached while the previous cancel is still pending is not '
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

      expect(
        gotEvent,
        isTrue,
        reason:
            'the second subscriber must not be stranded on a '
            'controller whose server stream was torn down',
      );
    });

    test(
      'cancelling from inside the event handler still allows re-subscribe',
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
            ref.subscribe(),
            () => transport.emit({'movies': []}),
          ),
          isTrue,
          reason:
              're-subscribing after a deferred cancel must restart the '
              'server stream',
        );
      },
    );
  });
}
