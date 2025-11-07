
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

import 'dart:async';
import 'dart:convert';

import '../common/common_library.dart';

import 'cache_data_types.dart';
import 'cache_provider.dart';
import 'result_tree_processor.dart';

/// The central component of the caching system.
class Cache {
  final CacheProvider _cacheProvider;
  final ResultTreeProcessor _resultTreeProcessor = ResultTreeProcessor();
  final _impactedQueryController = StreamController<Set<String>>.broadcast();

  Cache(this._cacheProvider);

  /// Stream of impacted query IDs.
  Stream<Set<String>> get impactedQueries => _impactedQueryController.stream;

  /// Caches a server response.
  Future<void> update(String queryId, ServerResponse serverResponse) async {
    print("updateCache data for $queryId");

    final dehydrationResult = await _resultTreeProcessor.dehydrate(
        queryId, serverResponse.data, _cacheProvider);

        EntityNode rootNode = dehydrationResult.dehydratedTree;
        String dehydratedJson = jsonEncode(rootNode.toJson(mode: EncodingMode.dehydrated));
        print("cacheUpdate: dehydrateResult ${dehydratedJson}");

    Duration ttl = serverResponse.ttl != null ? serverResponse.ttl! : Duration(seconds: 10);
    final resultTree = ResultTree(
        data: rootNode.toJson(mode: EncodingMode.dehydrated), // Storing the original response for now
        ttl: ttl, // Default TTL
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now(),
        rootObject: dehydrationResult.dehydratedTree);

    print("updateCache - got resultTree $resultTree");

    _cacheProvider.saveResultTree(queryId, resultTree);
    print("updateCache - savedResultTree $queryId - $resultTree");

    _impactedQueryController.add(dehydrationResult.impactedQueryIds); 
  }

  /// Fetches a cached result.
  Future<Map<String, dynamic>?> get(String queryId, bool allowStale) async {
    print("getCache for $queryId");

    final resultTree = await _cacheProvider.getResultTree(queryId);
    print("getCache resultTree $resultTree");

    if (resultTree != null) {
      // Simple TTL check
      if (resultTree.isStale() && !allowStale) {
        print("getCache result is stale and allowStale is false");
        return null;
      }

      resultTree.lastAccessed = DateTime.now();
      _cacheProvider.saveResultTree(queryId, resultTree);
      print("getCache updated lastAccessed ${resultTree.data}");

      return resultTree.rootObject.toJson(); //default mode is hydrated
      //return _resultTreeProcessor.hydrate(resultTree.rootObject, _cacheProvider);
    }

    return null;
  }

  /// Invalidates the cache.
  Future<void> invalidate() async {
     _cacheProvider.clear();
  }

  void dispose() {
    _impactedQueryController.close();
  }
}
