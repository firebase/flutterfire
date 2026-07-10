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
import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'cache_provider.dart';
import 'in_memory_cache_provider.dart'
    if (dart.library.io) 'sqlite_cache_provider.dart';

import '../common/common_library.dart';

import 'cache_data_types.dart';
import 'result_tree_processor.dart';

/// The central component of the caching system.
class Cache {
  final CacheSettings _settings;
  final FirebaseDataConnect dataConnect;
  final _impactedQueryController = StreamController<Set<String>>.broadcast();

  // Web / local provider (fallback)
  CacheProvider? _localCacheProvider;
  final ResultTreeProcessor _localResultTreeProcessor = ResultTreeProcessor();
  Future<bool>? _localProviderInitialization;

  // Non-web isolate handling
  Isolate? _isolate;
  SendPort? _toIsolatePort;
  Completer<SendPort>? _toIsolatePortCompleter;
  ReceivePort? _fromIsolatePort;
  final Map<int, Completer<dynamic>> _pendingRequests = {};

  int _requestIdCounter = 0;
  final Completer<void> _startupCompleter = Completer<void>();
  bool _startupCompleted = false;
  String? _currentIdentifier;
  bool _isolateFallbackMode = false;

  Future<void> get _initialized => _startupCompleter.future;

  factory Cache(CacheSettings settings, FirebaseDataConnect dataConnect) {
    Cache c = Cache._internal(settings, dataConnect);

    if (kIsWeb) {
      c._initializeLocalProvider();
    } else {
      c._startIsolate();
    }
    c._listenForAuthChanges();

    return c;
  }

  Cache._internal(this._settings, this.dataConnect);

  /// Stream of impacted query IDs.
  Stream<Set<String>> get impactedQueries => _impactedQueryController.stream;

  String _constructCacheIdentifier() {
    final rawPrefix =
        '${_settings.storage}-${dataConnect.app.options.projectId}-${dataConnect.app.name}-${dataConnect.connectorConfig.serviceId}-${dataConnect.connectorConfig.connector}-${dataConnect.connectorConfig.location}-${dataConnect.transport?.transportOptions.host}';
    final prefixSha = convertToSha256(rawPrefix);
    final rawSuffix = dataConnect.auth?.currentUser?.uid ?? 'anon';
    final suffixSha = convertToSha256(rawSuffix);

    return '$prefixSha-$suffixSha';
  }

  void _initializeLocalProvider() {
    String identifier = _constructCacheIdentifier();
    if (_localCacheProvider != null &&
        _localCacheProvider!.identifier() == identifier) {
      return;
    }

    bool memory = _settings.storage == CacheStorage.memory;
    _localCacheProvider = cacheImplementation(identifier, memory);

    _localProviderInitialization = _localCacheProvider?.initialize();
  }

  void _startIsolate() async {
    _toIsolatePortCompleter = Completer<SendPort>();
    _fromIsolatePort = ReceivePort();
    try {
      _isolate =
          await Isolate.spawn(_cacheIsolateEntry, _fromIsolatePort!.sendPort);

      _fromIsolatePort!.listen((message) {
        if (_toIsolatePort == null) {
          _toIsolatePort = message as SendPort;
          _toIsolatePortCompleter!.complete(_toIsolatePort!);
        } else {
          _handleIsolateMessage(message);
        }
      });

      _updateIsolateProvider().catchError((e) {
        developer.log('Failed to initialize isolate provider on startup: $e');
      });
    } catch (e, stackTrace) {
      developer.log(
          'Failed to spawn background cache Isolate: $e. Falling back to local mode.',
          error: e,
          stackTrace: stackTrace);
      // Fallback to local mode on failure
      _isolateFallbackMode = true;
      _toIsolatePortCompleter!.completeError(e);
      _localCacheProvider = null;
      _initializeLocalProvider();
      if (!_startupCompleted) {
        _startupCompleted = true;
        _startupCompleter.complete();
      }
    }
  }

  Future<void> _updateIsolateProvider() async {
    final identifier = _constructCacheIdentifier();
    if (_currentIdentifier == identifier) {
      return;
    }
    _currentIdentifier = identifier;

    final completer = Completer<void>();

    SendPort? toIsolatePort;
    try {
      toIsolatePort = await _toIsolatePortCompleter?.future;
    } catch (_) {}

    if (toIsolatePort == null || _isolateFallbackMode) {
      _localCacheProvider = null;
      _initializeLocalProvider();
      return;
    }

    String? dbPath;
    if (_settings.storage == CacheStorage.persistent) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        dbPath = appDir.path;
      } catch (e) {
        developer.log(
            'Failed to get application documents directory for background cache: $e');
      }
    }

    final isMemory = _settings.storage == CacheStorage.memory;

    final requestId = _requestIdCounter++;
    _pendingRequests[requestId] = completer;

    toIsolatePort.send({
      'op': 'init',
      'requestId': requestId,
      'identifier': identifier,
      'isMemory': isMemory,
      'dbPath': dbPath,
    });

    return completer.future;
  }

  void _listenForAuthChanges() {
    if (dataConnect.auth == null) {
      developer.log(
          'Not listening for auth changes since no auth instance in data connect');
      return;
    }

    dataConnect.auth!.authStateChanges().listen((User? user) {
      if (kIsWeb || _isolateFallbackMode) {
        _initializeLocalProvider();
      } else {
        _updateIsolateProvider().catchError((e) {
          developer.log('Failed to update isolate provider on auth change: $e');
        });
      }
    });
  }

  void _handleIsolateMessage(dynamic message) {
    if (message is! Map) return;

    final op = message['op'] as String?;
    final requestId = message['requestId'] as int?;

    if (op == 'initAck') {
      final completer = _pendingRequests.remove(requestId);
      final success = message['success'] as bool? ?? false;
      if (completer != null) {
        if (success) {
          completer.complete();
        } else {
          completer.completeError(StateError(
              'CacheProvider failed to initialize in background isolate.'));
        }
      }
      if (!_startupCompleted) {
        _startupCompleted = true;
        if (success) {
          _startupCompleter.complete();
        } else {
          _startupCompleter
              .completeError(StateError('CacheProvider failed to initialize.'));
        }
      }
    } else if (op == 'updateResponse') {
      final completer = _pendingRequests.remove(requestId);
      if (completer != null) {
        completer.complete();
      }
      final impacted = message['impactedQueryIds'] as List<dynamic>?;
      if (impacted != null) {
        _impactedQueryController.add(impacted.cast<String>().toSet());
      }
    } else if (op == 'resultTreeResponse') {
      final completer = _pendingRequests.remove(requestId);
      if (completer != null) {
        final data = message['data'] as Map<String, dynamic>?;
        completer.complete(data);
      }
    }
  }

  /// Caches a server response.
  Future<void> update(String queryId, ServerResponse serverResponse) async {
    if (kIsWeb || _isolateFallbackMode) {
      if (_localCacheProvider == null) {
        developer.log('cache update: no provider available');
        return;
      }

      // we have a provider lets ensure its initialized
      if (await _localProviderInitialization != true) {
        developer.log('CacheProvider not initialized. Cache not functional');
        return;
      }

      final impactedQueryIds = await dehydrateAndUpdateCache(
        queryId: queryId,
        data: serverResponse.data,
        extensions: serverResponse.extensions,
        maxAge: serverResponse.ttl ?? _settings.maxAge,
        provider: _localCacheProvider!,
        processor: _localResultTreeProcessor,
      );
      _impactedQueryController.add(impactedQueryIds);
    } else {
      await _initialized;
      final requestId = _requestIdCounter++;
      final completer = Completer<void>();
      _pendingRequests[requestId] = completer;

      _toIsolatePort!.send({
        'op': 'update',
        'requestId': requestId,
        'queryId': queryId,
        'data': serverResponse.data,
        'ttl': (serverResponse.ttl ?? _settings.maxAge).inMicroseconds,
        'extensions': serverResponse.extensions,
      });

      return completer.future;
    }
  }

  /// Fetches a cached result.
  Future<Map<String, dynamic>?> resultTree(
      String queryId, bool allowStale) async {
    if (kIsWeb || _isolateFallbackMode) {
      if (_localCacheProvider == null) {
        return null;
      }

      // we have a provider lets ensure its initialized
      if (await _localProviderInitialization != true) {
        developer.log('CacheProvider not initialized. Cache not functional');
        return null;
      }

      return fetchAndHydrateCache(
        queryId: queryId,
        allowStale: allowStale,
        provider: _localCacheProvider!,
        processor: _localResultTreeProcessor,
      );
    } else {
      await _initialized;
      final requestId = _requestIdCounter++;
      final completer = Completer<Map<String, dynamic>?>();
      _pendingRequests[requestId] = completer;

      _toIsolatePort!.send({
        'op': 'resultTree',
        'requestId': requestId,
        'queryId': queryId,
        'allowStale': allowStale,
      });

      return completer.future;
    }
  }

  void dispose() {
    _impactedQueryController.close();
    if (_isolate != null) {
      if (_toIsolatePort != null) {
        _toIsolatePort!.send({'op': 'dispose'});
      }
      _fromIsolatePort?.close();
      _isolate = null;
    }
    _localCacheProvider?.dispose();
  }
}

/// Entry point function for the background isolate.
void _cacheIsolateEntry(SendPort mainSendPort) async {
  final isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);

  CacheProvider? cacheProvider;
  final ResultTreeProcessor resultTreeProcessor = ResultTreeProcessor();
  Future<bool>? providerInitialization;

  await for (final message in isolateReceivePort) {
    if (message is! Map) continue;

    final op = message['op'] as String?;
    final requestId = message['requestId'] as int?;

    final provider = cacheProvider;

    switch (op) {
      case 'init':
        final identifier = message['identifier'] as String;
        final isMemory = message['isMemory'] as bool;
        final dbPath = message['dbPath'] as String?;

        if (provider != null && provider.identifier() == identifier) {
          mainSendPort.send({
            'op': 'initAck',
            'requestId': requestId,
            'success': true,
          });
          break;
        }

        if (provider != null) {
          await provider.dispose();
        }

        cacheProvider =
            cacheImplementation(identifier, isMemory, customDbPath: dbPath);
        providerInitialization = cacheProvider.initialize();

        final success = await providerInitialization;
        mainSendPort.send({
          'op': 'initAck',
          'requestId': requestId,
          'success': success,
        });
        break;

      case 'update':
        if (provider == null) {
          developer.log('cache update in isolate: no provider available');
          mainSendPort.send({
            'op': 'updateResponse',
            'requestId': requestId,
            'impactedQueryIds': <String>[],
          });
          break;
        }

        if (await providerInitialization != true) {
          developer.log('CacheProvider in isolate not initialized.');
          mainSendPort.send({
            'op': 'updateResponse',
            'requestId': requestId,
            'impactedQueryIds': <String>[],
          });
          break;
        }

        final queryId = message['queryId'] as String;
        final data = message['data'] as Map<String, dynamic>;
        final ttlMicroseconds = message['ttl'] as int?;
        final extensions = message['extensions'] as Map<String, dynamic>?;

        final maxAge = ttlMicroseconds != null
            ? Duration(microseconds: ttlMicroseconds)
            : Duration.zero;

        final impactedQueryIds = await dehydrateAndUpdateCache(
          queryId: queryId,
          data: data,
          extensions: extensions,
          maxAge: maxAge,
          provider: provider,
          processor: resultTreeProcessor,
        );

        mainSendPort.send({
          'op': 'updateResponse',
          'requestId': requestId,
          'impactedQueryIds': impactedQueryIds.toList(),
        });
        break;

      case 'resultTree':
        if (provider == null) {
          mainSendPort.send({
            'op': 'resultTreeResponse',
            'requestId': requestId,
            'data': null,
          });
          break;
        }

        if (await providerInitialization != true) {
          developer.log('CacheProvider in isolate not initialized.');
          mainSendPort.send({
            'op': 'resultTreeResponse',
            'requestId': requestId,
            'data': null,
          });
          break;
        }

        final queryId = message['queryId'] as String;
        final allowStale = message['allowStale'] as bool;

        final hydratedJson = await fetchAndHydrateCache(
          queryId: queryId,
          allowStale: allowStale,
          provider: provider,
          processor: resultTreeProcessor,
        );

        mainSendPort.send({
          'op': 'resultTreeResponse',
          'requestId': requestId,
          'data': hydratedJson,
        });
        break;

      case 'dispose':
        if (provider != null) {
          await provider.dispose();
        }
        isolateReceivePort.close();
        break;
    }
  }
}

/// Core dehydration and caching logic shared between proxy cache and background isolate.
Future<Set<String>> dehydrateAndUpdateCache({
  required String queryId,
  required Map<String, dynamic> data,
  required Map<String, dynamic>? extensions,
  required Duration maxAge,
  required CacheProvider provider,
  required ResultTreeProcessor processor,
}) async {
  return provider.runInTransaction(() async {
    final Map<DataConnectPath, PathMetadata> paths = extensions != null
        ? ExtensionResponse.fromJson(extensions).flattenPathMetadata()
        : {};

    final dehydrationResult =
        await processor.dehydrateResults(queryId, data, provider, paths);

    EntityNode rootNode = dehydrationResult.dehydratedTree;
    Map<String, dynamic> dehydratedMap =
        rootNode.toJson(mode: EncodingMode.dehydrated);

    Duration ttl = extensions != null && extensions['ttl'] != null
        ? Duration(seconds: extensions['ttl'] as int)
        : maxAge;

    final resultTree = ResultTree(
        data: dehydratedMap,
        ttl: ttl,
        cachedAt: DateTime.now(),
        lastAccessed: DateTime.now());

    provider.setResultTree(queryId, resultTree);

    Set<String> impactedQueryIds = dehydrationResult.impactedQueryIds;
    impactedQueryIds.remove(queryId); // remove query being cached
    return impactedQueryIds;
  });
}

/// Core fetching and hydration logic shared between proxy cache and background isolate.
Future<Map<String, dynamic>?> fetchAndHydrateCache({
  required String queryId,
  required bool allowStale,
  required CacheProvider provider,
  required ResultTreeProcessor processor,
}) async {
  final resultTree = provider.getResultTree(queryId);

  if (resultTree != null) {
    if (resultTree.isStale() && !allowStale) {
      developer.log('getCache result is stale and allowStale is false');
      return null;
    }

    resultTree.lastAccessed = DateTime.now();
    provider.setResultTree(queryId, resultTree);

    EntityNode rootNode = EntityNode.fromJson(resultTree.data, provider);

    Map<String, dynamic> hydratedJson =
        await processor.hydrateResults(rootNode, provider);

    return hydratedJson;
  }

  return null;
}
