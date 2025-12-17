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
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'cache_provider.dart';
import 'in_memory_cache_provider.dart'
    if (dart.library.io) 'sqlite_cache_provider.dart';

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

  String _constructCacheIdentifier() {
    final rawIdentifier =
        '${_settings.storage}-${dataConnect.app.options.projectId}-${dataConnect.app.name}-${dataConnect.connectorConfig.serviceId}-${dataConnect.connectorConfig.connector}-${dataConnect.connectorConfig.location}-${dataConnect.auth?.currentUser?.uid ?? 'anon'}-${dataConnect.transport.transportOptions.host}';
    return convertToSha256(rawIdentifier);
  }

  void _initializeProvider() {
    String identifier = _constructCacheIdentifier();
    if (_cacheProvider != null && _cacheProvider?.identifier() == identifier) {
      return;
    }

    bool memory = _settings.storage == CacheStorage.memory;
    _cacheProvider = cacheImplementation(identifier, memory);

    providerInitialization = _cacheProvider?.initialize();
  }

  void _listenForAuthChanges() {
    if (dataConnect.auth == null) {
      developer.log(
          'Not listening for auth changes since no auth instance in data connect');
      return;
    }

    dataConnect.auth!.authStateChanges().listen((User? user) {
      _initializeProvider();
    });
  }

  /// Caches a server response.
  Future<void> update(String queryId, ServerResponse serverResponse) async {
    if (_cacheProvider == null) {
      developer.log('cache update: no provider available');
      return;
    }

    // we have a provider lets ensure its initialized
    if (await providerInitialization != true) {
      developer.log('CacheProvider not initialized. Cache not functional');
      return;
    }

    final dehydrationResult = await _resultTreeProcessor.dehydrate(
        queryId, serverResponse.data, _cacheProvider!);

    EntityNode rootNode = dehydrationResult.dehydratedTree;
    Map<String, dynamic> dehydratedMap =
        rootNode.toJson(mode: EncodingMode.dehydrated);

    // if we have server ttl, that overrides maxAge from cacheSettings
    Duration ttl =
        serverResponse.ttl != null ? serverResponse.ttl! : _settings.maxAge;
    final resultTree = ResultTree(
        data: dehydratedMap,
        ttl: ttl,
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now());

    _cacheProvider!.saveResultTree(queryId, resultTree);

    Set<String> impactedQueryIds = dehydrationResult.impactedQueryIds;
    impactedQueryIds.remove(queryId); // remove query being cached
    _impactedQueryController.add(impactedQueryIds);
  }

  /// Fetches a cached result.
  Future<Map<String, dynamic>?> get(String queryId, bool allowStale) async {
    if (_cacheProvider == null) {
      return null;
    }

    // we have a provider lets ensure its initialized
    if (await providerInitialization != true) {
      developer.log('CacheProvider not initialized. Cache not functional');
      return null;
    }

    final resultTree = _cacheProvider!.getResultTree(queryId);

    if (resultTree != null) {
      // Simple TTL check
      if (resultTree.isStale() && !allowStale) {
        developer.log('getCache result is stale and allowStale is false');
        return null;
      }

      resultTree.lastAccessed = DateTime.now();
      _cacheProvider!.saveResultTree(queryId, resultTree);

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
