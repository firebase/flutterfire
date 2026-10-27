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

@TestOn('browser')
library;

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/cache/cache.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../src/firebase_data_connect_test.mocks.dart';

void main() {
  late FirebaseDataConnect dataConnect;

  setUp(() {
    final mockApp = MockFirebaseApp();
    when(mockApp.options).thenReturn(
      const FirebaseOptions(
        apiKey: 'fake_api_key',
        appId: 'fake_app_id',
        messagingSenderId: 'fake_messaging_sender_id',
        projectId: 'fake_project_id',
      ),
    );
    final mockConnectorConfig = MockConnectorConfig();
    when(mockConnectorConfig.location).thenReturn('testLocation');
    when(mockConnectorConfig.connector).thenReturn('testConnector');
    when(mockConnectorConfig.serviceId).thenReturn('testService');

    dataConnect = FirebaseDataConnect(
      app: mockApp,
      connectorConfig: mockConnectorConfig,
    );
  });

  // The background isolate and its database directory are native-only: on
  // the web, the cache stays on the main thread whatever the storage.
  for (final storage in CacheStorage.values) {
    test('Test Cache set get with $storage', () async {
      final cache = Cache(CacheSettings(storage: storage), dataConnect);
      addTearDown(cache.dispose);

      final jsonData = jsonDecode('''
        {"data": {"items": [
          {"desc": "itemDesc1", "name": "itemOne", "price": 4},
          {"desc": "itemDesc2", "name": "itemTwo", "price": 7}
        ]}}
      ''') as Map<String, dynamic>;
      await cache.update(
        'itemsSimple',
        ServerResponse(jsonData, extensions: {
          'dataConnect': [
            {
              'path': ['items'],
              'entityIds': ['123', '345'],
            }
          ]
        }),
      );

      expect(await cache.resultTree('itemsSimple', true), jsonData['data']);
    });
  }
}
