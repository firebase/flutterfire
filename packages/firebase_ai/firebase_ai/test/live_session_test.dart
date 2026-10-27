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

// ignore_for_file: close_sinks

import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/src/live_api.dart';
import 'package:firebase_ai/src/live_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FakeWebSocketSink implements WebSocketSink {
  final List<dynamic> sentMessages = [];

  @override
  void add(dynamic data) {
    sentMessages.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) async {}

  @override
  Future close([int? closeCode, String? closeReason]) async {}

  @override
  Future get done => Future.value();
}

class FakeWebSocketChannel implements WebSocketChannel {
  final StreamController _controller = StreamController();
  final FakeWebSocketSink _sink = FakeWebSocketSink();

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => _sink;

  List<dynamic> get sentMessages => _sink.sentMessages;

  void emit(dynamic message) => _controller.add(message);

  void close() => _controller.close();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => Future.value();

  @override
  String? get protocol => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LiveSession Tests', () {
    test('processes String messages from WebSocket on Web', () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      const jsonMessage = '{"setupComplete": {}}';

      final completer = Completer<bool>();
      final subscription = session.receive().listen((response) {
        if (response.message is LiveServerSetupComplete) {
          completer.complete(true);
        }
      });

      fakeWs.emit(jsonMessage);

      final result = await completer.future.timeout(const Duration(seconds: 5));
      expect(result, isTrue);

      await subscription.cancel();
      fakeWs.close();
    });

    test('processes List<int> messages from WebSocket', () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      const jsonMessage = '{"setupComplete": {}}';
      final bytes = utf8.encode(jsonMessage);

      final completer = Completer<bool>();
      final subscription = session.receive().listen((response) {
        if (response.message is LiveServerSetupComplete) {
          completer.complete(true);
        }
      });

      fakeWs.emit(bytes);

      final result = await completer.future.timeout(const Duration(seconds: 5));
      expect(result, isTrue);

      await subscription.cancel();
      fakeWs.close();
    });

    test('receive stays open across a voiceActivity frame', () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      final messages = <LiveServerMessage>[];
      final errors = <Object>[];
      var done = false;
      final completer = Completer<void>();
      final subscription = session.receive().listen(
        (response) {
          messages.add(response.message);
          if (messages.length == 2 && !completer.isCompleted) {
            completer.complete();
          }
        },
        onError: errors.add,
        onDone: () => done = true,
      );

      fakeWs.emit(jsonEncode({
        'voiceActivity': {
          'type': 'ACTIVITY_START',
          'audioOffset': '2.520s',
        },
      }));
      fakeWs.emit('{"setupComplete": {}}');

      await completer.future.timeout(const Duration(seconds: 5));
      expect(
        messages[0],
        isNot(anyOf(
          isA<LiveServerContent>(),
          isA<LiveServerToolCall>(),
          isA<LiveServerToolCallCancellation>(),
          isA<LiveServerSetupComplete>(),
          isA<GoingAwayNotice>(),
          isA<SessionResumptionUpdate>(),
        )),
      );
      expect(messages[1], isA<LiveServerSetupComplete>());
      expect(errors, isEmpty);
      expect(done, isFalse);

      await subscription.cancel();
      fakeWs.close();
    });

    test('receive stays open after an unrecognized frame', () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      final errors = <Object>[];
      var done = false;
      final completer = Completer<LiveServerMessage>();
      final subscription = session.receive().listen(
        (response) {
          if (response.message is LiveServerSetupComplete &&
              !completer.isCompleted) {
            completer.complete(response.message);
          }
        },
        onError: (Object error) {
          errors.add(error);
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        onDone: () {
          done = true;
          if (!completer.isCompleted) {
            completer.completeError(StateError('receive closed'));
          }
        },
      );

      fakeWs.emit('{"unknown": {}}');
      fakeWs.emit('{"setupComplete": {}}');

      final message =
          await completer.future.timeout(const Duration(seconds: 5));
      expect(message, isA<LiveServerSetupComplete>());
      expect(errors, isEmpty);
      expect(done, isFalse);

      await subscription.cancel();
      fakeWs.close();
    });

    test('sendStartActivityRealtime sends correct activity_start message',
        () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      await session.sendStartActivityRealtime();

      expect(fakeWs.sentMessages.length, 1);
      final jsonPayload = json.decode(fakeWs.sentMessages.first as String);
      expect(jsonPayload, {
        'realtime_input': {
          'activity_start': {},
        },
      });
    });

    test('sendStopActivityRealtime sends correct activity_end message',
        () async {
      final fakeWs = FakeWebSocketChannel();
      final session = LiveSession.forTesting(fakeWs);

      await session.sendStopActivityRealtime();

      expect(fakeWs.sentMessages.length, 1);
      final jsonPayload = json.decode(fakeWs.sentMessages.first as String);
      expect(jsonPayload, {
        'realtime_input': {
          'activity_end': {},
        },
      });
    });
  });

  group('LiveSession connection headers', () {
    test('create fetches headers from the provider for the first connection',
        () async {
      final connections = <Map<String, String>>[];
      final channels = <FakeWebSocketChannel>[];
      var providerCalls = 0;

      final session = await LiveSession.create(
        uri: 'wss://example.com/ws',
        headersProvider: () async {
          providerCalls++;
          return {'X-Firebase-AppCheck': 'token-$providerCalls'};
        },
        modelString: 'projects/p/models/m',
        connector: (uri, headers) {
          connections.add(Map.of(headers));
          final channel = FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
      );

      expect(providerCalls, 1);
      expect(connections, [
        {'X-Firebase-AppCheck': 'token-1'},
      ]);
      expect(channels.single.sentMessages, hasLength(1));

      await session.close();
    });

    test('resumeSession re-fetches headers instead of reusing stale tokens',
        () async {
      final connections = <Map<String, String>>[];
      final channels = <FakeWebSocketChannel>[];
      var providerCalls = 0;

      final session = await LiveSession.create(
        uri: 'wss://example.com/ws',
        // Simulates limited-use App Check tokens / refreshed Auth ID tokens:
        // every call returns a distinct value.
        headersProvider: () async {
          providerCalls++;
          return {
            'X-Firebase-AppCheck': 'app-check-$providerCalls',
            'Authorization': 'Firebase id-token-$providerCalls',
          };
        },
        modelString: 'projects/p/models/m',
        connector: (uri, headers) {
          connections.add(Map.of(headers));
          final channel = FakeWebSocketChannel();
          channels.add(channel);
          return channel;
        },
      );

      await session.resumeSession(
        sessionResumption: SessionResumptionConfig.resume('resume-handle'),
      );

      expect(providerCalls, 2);
      expect(connections, hasLength(2));
      expect(connections[0]['X-Firebase-AppCheck'], 'app-check-1');
      expect(connections[1]['X-Firebase-AppCheck'], 'app-check-2');
      expect(connections[1]['Authorization'], 'Firebase id-token-2');

      // The resumed connection still sends the setup message with the handle.
      final resumedSetup =
          json.decode(channels[1].sentMessages.single as String) as Map;
      expect(
        (resumedSetup['setup'] as Map)['session_resumption'],
        {'handle': 'resume-handle'},
      );

      await session.close();
    });

    test('resumeSession surfaces header provider failures', () async {
      var providerCalls = 0;

      final session = await LiveSession.create(
        uri: 'wss://example.com/ws',
        headersProvider: () async {
          providerCalls++;
          if (providerCalls > 1) {
            throw StateError('App Check unavailable');
          }
          return const {'X-Firebase-AppCheck': 'app-check-1'};
        },
        modelString: 'projects/p/models/m',
        connector: (uri, headers) => FakeWebSocketChannel(),
      );

      await expectLater(session.resumeSession(), throwsStateError);
      expect(providerCalls, 2);
    });
  });
}
