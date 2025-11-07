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


import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';
import 'package:firebase_data_connect/src/cache/in_memory_cache_provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {

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
    test('Test Cache set get', () async {
        Cache cache = Cache(InMemoryCacheProvider());

        Map<String, dynamic> jsonData = jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
        await cache.update('itemsSimple', ServerResponse(jsonData));

        Map<String, dynamic>? cachedData = await cache.get('itemsSimple', true);

        expect(jsonData['data'], cachedData);

    }); // test set get

    test ('Update shared EntityDataObject', () async {
        Cache cache = Cache(InMemoryCacheProvider());

        String queryOneId = 'itemsSimple';
        String queryTwoId = 'itemSimple';

        Map<String, dynamic> jsonDataOne = jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
        await cache.update(queryOneId, ServerResponse(jsonDataOne));

        Map<String, dynamic> jsonDataTwo = jsonDecode(simpleQueryTwoResponse) as Map<String, dynamic>;
        await cache.update(queryTwoId, ServerResponse(jsonDataTwo));

        Map<String, dynamic> jsonDataOneUpdate = jsonDecode(simpleQueryResponseUpdate) as Map<String, dynamic>;
        await cache.update(queryOneId, ServerResponse(jsonDataOneUpdate));
        // shared object should be updated.
        // now reload query two from cache and check object value. 
        // it should be updated

        Map<String, dynamic>? jsonDataTwoUpdated = await cache.get(queryTwoId, true);
        if (jsonDataTwoUpdated == null) {
          fail('No query two found in cache');
        }

        int price = jsonDataTwoUpdated['item']?['price'] as int;

        expect(price, 11);
    }); // test shared EDO

  }); // test group

} //main
