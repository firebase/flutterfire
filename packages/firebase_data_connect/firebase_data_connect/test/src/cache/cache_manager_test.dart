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
import 'package:firebase_data_connect/src/core/ref.dart';
import 'package:firebase_data_connect/src/network/rest_library.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/cache/cache_data_types.dart';
import 'package:firebase_data_connect/src/cache/cache.dart';
import 'package:firebase_data_connect/src/cache/cache_provider.dart';
import 'package:firebase_data_connect/src/cache/in_memory_cache_provider.dart';
import 'package:firebase_data_connect/src/cache/sqlite_cache_provider.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FirebaseApp>(), MockSpec<ConnectorConfig>()])
import '../firebase_data_connect_test.mocks.dart';
import '../network/rest_transport_test.mocks.dart';

class MockTransportOptions extends Mock implements TransportOptions {}

class MockDataConnectTransport extends Mock implements DataConnectTransport {}

void main() {
  late MockFirebaseApp mockApp;
  late MockConnectorConfig mockConnectorConfig;
  late FirebaseDataConnect dataConnect;
  late MockClient mockHttpClient;
  late RestTransport transport;
  const Duration maxAgeSeconds = Duration(milliseconds: 200);

  const String simpleQueryResponse = '''
    {"data": {"items":[
    
    {"desc":"itemDesc1","name":"itemOne","price":4},
    {"desc":"itemDesc2","name":"itemTwo","price":7}
    
    ]}}
  ''';

  final Map<String, dynamic> simpleQueryExtensions = {
    'dataConnect': [
      {
        'path': ['items'],
        'entityIds': ['123', '345']
      }
    ]
  };

  // query that updates the price for cacheId 123 to 11
  const String simpleQueryResponseUpdate = '''
    {"data": {"items":[
    
    {"desc":"itemDesc1","name":"itemOne","price":11},
    {"desc":"itemDesc2","name":"itemTwo","price":7}
    
    ]}}
  ''';

  // query two has same object as query one so should refer to same Entity.
  const String simpleQueryTwoResponse = '''
    {"data": {
    "item": { "desc":"itemDesc1","name":"itemOne","price":4 }
    }}
  ''';

  final Map<String, dynamic> simpleQueryTwoExtensions = {
    'dataConnect': [
      {
        'path': ['item'],
        'entityId': '123'
      }
    ]
  };

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
      when(mockConnectorConfig.location).thenReturn('testLocation');
      when(mockConnectorConfig.connector).thenReturn('testConnector');
      when(mockConnectorConfig.serviceId).thenReturn('testService');

      mockHttpClient = MockClient();
      transport = RestTransport(
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
      transport.setHttp(mockHttpClient);

      dataConnect = FirebaseDataConnect(
          app: mockApp,
          connectorConfig: mockConnectorConfig,
          cacheSettings: CacheSettings(
              storage: CacheStorage.memory, maxAge: maxAgeSeconds));
      dataConnect.transport = transport;
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
      await cache.update('itemsSimple',
          ServerResponse(jsonData, extensions: simpleQueryExtensions));

      Map<String, dynamic>? cachedData =
          await cache.resultTree('itemsSimple', true);

      expect(jsonData['data'], cachedData);
    }); // test set get

    test('EntityDataObject set get', () async {
      CacheProvider cp = InMemoryCacheProvider('inmemprov');
      if (!kIsWeb) {
        cp = SQLite3CacheProvider('testDb', memory: true);
      }
      await cp.initialize();

      EntityDataObject edo = EntityDataObject(guid: '1234');
      edo.updateServerValue('name', 'test', null);
      edo.updateServerValue('desc', 'testDesc', null);

      cp.updateEntityData(edo);
      EntityDataObject edo2 = cp.getEntityData('1234');

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
      await cache.update(queryOneId,
          ServerResponse(jsonDataOne, extensions: simpleQueryExtensions));

      Map<String, dynamic> jsonDataTwo =
          jsonDecode(simpleQueryTwoResponse) as Map<String, dynamic>;
      await cache.update(queryTwoId,
          ServerResponse(jsonDataTwo, extensions: simpleQueryTwoExtensions));

      Map<String, dynamic> jsonDataOneUpdate =
          jsonDecode(simpleQueryResponseUpdate) as Map<String, dynamic>;
      await cache.update(queryOneId,
          ServerResponse(jsonDataOneUpdate, extensions: simpleQueryExtensions));
      // shared object should be updated.
      // now reload query two from cache and check object value.
      // it should be updated

      Map<String, dynamic>? jsonDataTwoUpdated =
          await cache.resultTree(queryTwoId, true);
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
      EntityDataObject edo = cp.getEntityData(oid);

      String testValue = 'testValue';
      String testProp = 'testProp';

      edo.updateServerValue(testProp, testValue, null);

      cp.updateEntityData(edo);

      EntityDataObject edo2 = cp.getEntityData(oid);
      String value = edo2.fields()[testProp];

      expect(testValue, value);
    });

    test('maxAge conformance', () async {
      final deserializer = (String data) => 'Deserialized Data';
      final mockResponseSuccess = http.Response('{"success": true}', 200);

      if (dataConnect.cacheManager == null) {
        fail('No cacheManager available');
      }

      Cache cache = dataConnect.cacheManager!;

      Map<String, dynamic> jsonData =
          jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
      await cache.update('itemsSimple',
          ServerResponse(jsonData, extensions: simpleQueryExtensions));

      QueryRef ref = QueryRef(
        dataConnect,
        'operation',
        transport,
        deserializer,
        QueryManager(dataConnect),
        emptySerializer,
        null,
      );
      when(
        mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => mockResponseSuccess);

      QueryResult result = await ref.execute();
      expect(result.source, DataSource.server);

      // call execute immediately. Should be within maxAge so source should be cache
      QueryResult result2 = await ref.execute();
      expect(result2.source, DataSource.cache);

      // now lets add delay beyond maxAge and result source should be server
      await Future.delayed(
          Duration(milliseconds: maxAgeSeconds.inMilliseconds + 100), () async {
        QueryResult resultDelayed = await ref.execute();
        expect(resultDelayed.source, DataSource.server);
      });
    });

    test('Test AnyValue Caching', () async {
      if (dataConnect.cacheManager == null) {
        fail('No cache available');
      }

      Cache cache = dataConnect.cacheManager!;

      const String anyValueSingleData = '''
      {"data": {"anyValueItem":
        { "name": "AnyItem B",
          "blob": {"values":["A", 45, {"embedKey": "embedVal"}, ["A", "AA"]]}
        }
      }}
      ''';

      final Map<String, dynamic> anyValueSingleExt = {
        'dataConnect': [
          {
            'path': ['anyValueItem'],
            'entityId': 'AnyValueItemSingle_ID'
          }
        ]
      };

      Map<String, dynamic> jsonData =
          jsonDecode(anyValueSingleData) as Map<String, dynamic>;

      await cache.update('queryAnyValue',
          ServerResponse(jsonData, extensions: anyValueSingleExt));

      Map<String, dynamic>? cachedData =
          await cache.resultTree('queryAnyValue', true);

      expect(cachedData?['anyValueItem']?['name'], 'AnyItem B');
      List<dynamic> values = cachedData?['anyValueItem']?['blob']?['values'];
      expect(values.length, 4);
      expect(values[0], 'A');
      expect(values[1], 45);
      expect(values[2], {'embedKey': 'embedVal'});
      expect(values[3], ['A', 'AA']);
    });
  }); // test group
} //main
