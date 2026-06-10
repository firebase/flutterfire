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
import 'dart:convert';

import 'package:firebase_ai/src/live_api.dart';
import 'package:firebase_ai/src/live_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FakeWebSocketChannel implements WebSocketChannel {
  final StreamController _controller = StreamController();

  @override
  Stream get stream => _controller.stream;

  @override
  WebSocketSink get sink => throw UnimplementedError();

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
  });
}
