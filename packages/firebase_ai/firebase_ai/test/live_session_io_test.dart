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

@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/src/live_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'create sends the provided headers with the native WebSocket handshake',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      final handshakeHeaders = Completer<HttpHeaders>();
      final setupMessage = Completer<String>();
      server.listen((request) async {
        handshakeHeaders.complete(request.headers);
        final socket = await WebSocketTransformer.upgrade(request);
        addTearDown(socket.close);
        socket.listen((message) {
          if (!setupMessage.isCompleted)
            setupMessage.complete(message as String);
        });
      });

      final session = await LiveSession.create(
        uri: 'ws://${server.address.host}:${server.port}/ws',
        headersProvider: () => {
          'X-Firebase-AppCheck': 'app-check-token',
          'Authorization': 'Firebase id-token',
        },
        modelString: 'projects/p/models/m',
      );
      addTearDown(session.close);

      final headers = await handshakeHeaders.future;
      expect(headers.value('X-Firebase-AppCheck'), 'app-check-token');
      expect(headers.value('Authorization'), 'Firebase id-token');

      final setup = json.decode(await setupMessage.future) as Map;
      expect((setup['setup'] as Map)['model'], 'projects/p/models/m');
    },
  );
}
