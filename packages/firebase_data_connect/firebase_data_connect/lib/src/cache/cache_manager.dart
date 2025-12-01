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
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect/src/cache/in_memory_cache_provider.dart';
import 'package:firebase_data_connect/src/cache/sqlite_cache_provider.dart';
import 'package:flutter/foundation.dart';

import '../common/common_library.dart';

import 'cache_data_types.dart';
import 'result_tree_processor.dart';

/// The central component of the caching system.
class Cache {
  CacheSettings _settings;
  CacheProvider? _cacheProvider;
  FirebaseDataConnect dataConnect;
  final ResultTreeProcessor _resultTreeProcessor = ResultTreeProcessor();
  final _impactedQueryController = StreamController<Set<String>>.broadcast();
  Future<bool>? providerInitialization;

  factory Cache(CacheSettings settings, FirebaseDataConnect dataConnect) {
    Cache c = Cache._internal(settings, dataConnect);
     
    c._initializeProvider();
    c._listenForAuthChanges();
    
    return c;
  }

  Cache._internal(this._settings, this.dataConnect);

  /// Stream of impacted query IDs.
  Stream<Set<String>> get impactedQueries => _impactedQueryController.stream;

  String _contructCacheIdentifier() {
    return '${_settings.storage}-${dataConnect.app.options.projectId}-${dataConnect.app.name}-${dataConnect.connectorConfig.serviceId}-${dataConnect.connectorConfig.connector}-${dataConnect.connectorConfig.location}-${FirebaseAuth.instanceFor(app: dataConnect.app).currentUser?.uid}-${dataConnect.transport.transportOptions.host}';
  }

  void _initializeProvider() {
    String identifier = _contructCacheIdentifier();
    if (_cacheProvider != null && _cacheProvider?.identifier() == identifier) {
      return;
    }

    if (kIsWeb) {
      // change this once we support persistence for web
      _cacheProvider = InMemoryCacheProvider(identifier);
      providerInitialization = _cacheProvider?.initialize();
      return;
    }

    switch (_settings.storage) {
      case CacheStorage.memory:
        _cacheProvider = SQLite3CacheProvider(identifier, memory: true);
      case CacheStorage.persistent:
        _cacheProvider = SQLite3CacheProvider(identifier);
    }
    providerInitialization = _cacheProvider?.initialize();
  }

  void _listenForAuthChanges() {
    FirebaseAuth.instanceFor(app: dataConnect.app)
        .authStateChanges()
        .listen((User? user) {
      _initializeProvider();
    });
  }

  /// Caches a server response.
  Future<void> update(String queryId, ServerResponse serverResponse) async {
    print("updateCache data for $queryId");

    if (_cacheProvider == null) {
      return;
    }

    // we have a provider lets ensure its initialized
    bool? initialized = await providerInitialization;
    if (initialized == null || initialized == false) {
      developer.log('CacheProvider not initialized. Cache not functional');
      return;
    }

    final dehydrationResult = await _resultTreeProcessor.dehydrate(
        queryId, serverResponse.data, _cacheProvider!);

    EntityNode rootNode = dehydrationResult.dehydratedTree;
    String dehydratedJson =
        jsonEncode(rootNode.toJson(mode: EncodingMode.dehydrated));
    print("cacheUpdate: dehydrateResult ${dehydratedJson}");

    Duration ttl = serverResponse.ttl != null
        ? serverResponse.ttl!
        : Duration(seconds: 10);
    final resultTree = ResultTree(
        data: rootNode.toJson(
            mode: EncodingMode
                .dehydrated), // Storing the original response for now
        ttl: ttl, // Default TTL
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now());

    print("updateCache - got resultTree $resultTree");

    _cacheProvider!.saveResultTree(queryId, resultTree);
    print("updateCache - savedResultTree $queryId - $resultTree");

    _impactedQueryController.add(dehydrationResult.impactedQueryIds);
  }

  /// Fetches a cached result.
  Future<Map<String, dynamic>?> get(String queryId, bool allowStale) async {
    print("getCache for $queryId");

    if (_cacheProvider == null) {
      return null;
    }

    // we have a provider lets ensure its initialized
    bool? initialized = await providerInitialization;
    if (initialized == null || initialized == false) {
      developer.log('CacheProvider not initialized. Cache not functional');
      return null;
    }

    final resultTree = _cacheProvider!.getResultTree(queryId);
    print("getCache resultTree $resultTree");

    if (resultTree != null) {
      // Simple TTL check
      if (resultTree.isStale() && !allowStale) {
        print("getCache result is stale and allowStale is false");
        return null;
      }

      resultTree.lastAccessed = DateTime.now();
      _cacheProvider!.saveResultTree(queryId, resultTree);
      print("getCache updated lastAccessed ${resultTree.data}");

      EntityNode rootNode =
          EntityNode.fromJson(resultTree.data, _cacheProvider!);
      Map<String, dynamic> hydratedJson =
          rootNode.toJson(); //default mode for toJson is hydrate
      return hydratedJson;
    }

    return null;
  }

  /// Invalidates the cache.
  Future<void> invalidate() async {
    _cacheProvider?.clear();
  }

  void dispose() {
    _impactedQueryController.close();
  }
}
