// Copyright 2025 Google LLC
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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/cache/cache_data_types.dart';
import 'package:firebase_data_connect/src/cache/in_memory_cache_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../core/ref_test.dart';
@GenerateNiceMocks([MockSpec<FirebaseApp>(), MockSpec<ConnectorConfig>()])
import '../firebase_data_connect_test.mocks.dart';

class MockTransportOptions extends Mock implements TransportOptions {}

class MockDataConnectTransport extends Mock implements DataConnectTransport {}

void main() {
  late MockFirebaseApp mockApp;
  late MockFirebaseAuth mockAuth;
  late MockConnectorConfig mockConnectorConfig;
  late FirebaseDataConnect dataConnect;

  const String entityObject = '''
    {"desc":"itemDesc1","name":"itemOne", "cacheId":"123","price":4}
  ''';

  const String simpleQueryResponse = '''
    {"data": {"items":[
    
    {"desc":"itemDesc1","name":"itemOne", "cacheId":"123","price":4},
    {"desc":"itemDesc2","name":"itemTwo", "cacheId":"345","price":7}
    
    ]}}
  ''';

  // query that updates the price for cacheId 123 to 11
  const String simpleQueryResponseUpdate = '''
    {"data": {"items":[
    
    {"desc":"itemDesc1","name":"itemOne", "cacheId":"123","price":11},
    {"desc":"itemDesc2","name":"itemTwo", "cacheId":"345","price":7}
    
    ]}}
  ''';

  // query two has same object as query one so should refer to same Entity.
  const String simpleQueryTwoResponse = '''
    {"data": {
    "item": { "desc":"itemDesc1","name":"itemOne", "cacheId":"123","price":4 }
    }}
  ''';

  group('Cache Provider Tests', () {
    setUp(() async {
      mockApp = MockFirebaseApp();
      //mockAuth = MockFirebaseAuth();
      mockConnectorConfig = MockConnectorConfig();

      when(mockApp.options).thenReturn(
        const FirebaseOptions(
          apiKey: 'fake_api_key',
          appId: 'fake_app_id',
          messagingSenderId: 'fake_messaging_sender_id',
          projectId: 'fake_project_id',
        ),
      );
      when(mockConnectorConfig.location).thenReturn('us-central1');
      when(mockConnectorConfig.connector).thenReturn('connector');
      when(mockConnectorConfig.serviceId).thenReturn('serviceId');

      dataConnect = FirebaseDataConnect(
          app: mockApp,
          connectorConfig: mockConnectorConfig,
          cacheSettings: const CacheSettings(storage: CacheStorage.memory));
      dataConnect.checkTransport();
      dataConnect.checkAndInitializeCache();
    });

    test('Test Cache set get', () async {
      if (dataConnect.cacheManager == null) {
        fail('No cache available');
      }

      Cache cache = dataConnect.cacheManager!;

      Map<String, dynamic> jsonData =
          jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
      await cache.update('itemsSimple', ServerResponse(jsonData));

      Map<String, dynamic>? cachedData = await cache.get('itemsSimple', true);

      expect(jsonData['data'], cachedData);
    }); // test set get

    test('EntityDataObject set get', () async {
      CacheProvider cp = InMemoryCacheProvider('inmemprov');
      if (!kIsWeb) {
        cp = SQLite3CacheProvider('testDb', memory: true);
      }
      await cp.initialize();

      EntityDataObject edo = EntityDataObject(guid: '1234');
      edo.updateServerValue('name', 'test');
      edo.updateServerValue('desc', 'testDesc');

      cp.saveEntityDataObject(edo);
      EntityDataObject edo2 = cp.getEntityDataObject('1234');

      expect(edo.fields().length, edo2.fields().length);
      expect(edo.fields()['name'], edo2.fields()['name']);
    });

    test('Update shared EntityDataObject', () async {
      if (dataConnect.cacheManager == null) {
        fail('No cache available');
      }
      Cache cache = dataConnect.cacheManager!;

      String queryOneId = 'itemsSimple';
      String queryTwoId = 'itemSimple';

      Map<String, dynamic> jsonDataOne =
          jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
      await cache.update(queryOneId, ServerResponse(jsonDataOne));

      Map<String, dynamic> jsonDataTwo =
          jsonDecode(simpleQueryTwoResponse) as Map<String, dynamic>;
      await cache.update(queryTwoId, ServerResponse(jsonDataTwo));

      Map<String, dynamic> jsonDataOneUpdate =
          jsonDecode(simpleQueryResponseUpdate) as Map<String, dynamic>;
      await cache.update(queryOneId, ServerResponse(jsonDataOneUpdate));
      // shared object should be updated.
      // now reload query two from cache and check object value.
      // it should be updated

      Map<String, dynamic>? jsonDataTwoUpdated =
          await cache.get(queryTwoId, true);
      if (jsonDataTwoUpdated == null) {
        fail('No query two found in cache');
      }

      int price = jsonDataTwoUpdated['item']?['price'] as int;

      expect(price, 11);
    }); // test shared EDO

    test('SQLiteProvider EntityDataObject persist', () async {
      CacheProvider cp = InMemoryCacheProvider('inmemprov');
      if (!kIsWeb) {
        cp = SQLite3CacheProvider('testDb', memory: true);  
      }
      await cp.initialize();

      String oid = '1234';
      EntityDataObject edo = cp.getEntityDataObject(oid);

      String testValue = 'testValue';
      String testProp = 'testProp';

      edo.updateServerValue(testProp, testValue);

      cp.saveEntityDataObject(edo);

      EntityDataObject edo2 = cp.getEntityDataObject(oid);
      String value = edo2.fields()[testProp];

      expect(testValue, value);
    });
  }); // test group
} //main
