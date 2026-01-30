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

import 'package:firebase_data_connect/src/cache/cache_data_types.dart';
import 'package:firebase_data_connect/src/cache/result_tree_processor.dart';
import 'package:firebase_data_connect/src/common/common_library.dart';

import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:firebase_data_connect/src/cache/in_memory_cache_provider.dart';

void main() {
  const String simpleQueryResponse = '''
    {"data": {"items":[
    
    {"desc":"itemDesc1","name":"itemOne","price":4},
    {"desc":"itemDesc2","name":"itemTwo","price":7}
    
    ]}}
  ''';

  final Map<DataConnectPath, PathMetadata> simpleQueryPaths = {
    DataConnectPath([DataConnectFieldPathSegment('items'), DataConnectListIndexPathSegment(0)]):
        PathMetadata(
            path: DataConnectPath([DataConnectFieldPathSegment('items'), DataConnectListIndexPathSegment(0)]),
            entityId: '123'),
    DataConnectPath([DataConnectFieldPathSegment('items'), DataConnectListIndexPathSegment(1)]):
        PathMetadata(
            path: DataConnectPath([DataConnectFieldPathSegment('items'), DataConnectListIndexPathSegment(1)]),
            entityId: '345'),
  };

  // query two has same object as query one so should refer to same Entity.
  const String simpleQueryResponseTwo = '''
    {"data": {
    "item": { "desc":"itemDesc1","name":"itemOne","price":4 }
    }}
  ''';

  final Map<DataConnectPath, PathMetadata> simpleQueryTwoPaths = {
    DataConnectPath([DataConnectFieldPathSegment('item')]): PathMetadata(
        path: DataConnectPath([DataConnectFieldPathSegment('item')]),
        entityId: '123'),
  };

  group('CacheProviderTests', () {
    // Dehydrate two queries sharing a single object.
    // Confirm that same EntityDataObject is present in both the dehydrated queries
    test('Test Dehydration - compare common GlobalIDs', () async {
      ResultTreeProcessor rp = ResultTreeProcessor();
      InMemoryCacheProvider cp = InMemoryCacheProvider('inmemprovider');

      Map<String, dynamic> jsonData =
          jsonDecode(simpleQueryResponse) as Map<String, dynamic>;
      DehydrationResult result =
          await rp.dehydrate('itemsSimple', jsonData['data'], cp, simpleQueryPaths);
      expect(result.dehydratedTree.nestedObjectLists?.length, 1);
      expect(result.dehydratedTree.nestedObjectLists?['items']?.length, 2);
      expect(result.dehydratedTree.nestedObjectLists?['items']?.first.entity,
          isNotNull);

      Map<String, dynamic> jsonDataTwo =
          jsonDecode(simpleQueryResponseTwo) as Map<String, dynamic>;
      DehydrationResult resultTwo =
          await rp.dehydrate('itemsSimpleTwo', jsonDataTwo['data'], cp, simpleQueryTwoPaths);

      List<String>? guids = result.dehydratedTree.nestedObjectLists?['items']
          ?.map((item) => item.entity?.guid)
          .where((guid) => guid != null)
          .cast<String>()
          .toList();
      if (guids == null) {
        fail('DehydratedTree has no GlobalIDs');
      }

      String? guidTwo =
          resultTwo.dehydratedTree.nestedObjects?['item']?.entity?.guid;
      if (guidTwo == null) {
        fail('Second DehydratedTree has no GlobalID');
      }

      bool containsGuid = guids.contains(guidTwo);
      expect(containsGuid, isTrue);
    });
  }); //test group
} //main
