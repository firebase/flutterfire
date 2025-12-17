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

import 'dart:convert';

import 'package:firebase_data_connect/src/cache/cache_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Type of storage to use for the cache
enum CacheStorage { persistent, memory }

const String kGlobalIDKey = 'cacheId';

/// Configuration for the cache
class CacheSettings {
  /// The type of storage to use (e.g., "persistent", "memory")
  final CacheStorage storage;

  /// The maximum size of the cache in bytes
  final int maxSizeBytes;

  /// Duration for which cache is used before revalidation with server
  final Duration maxAge;

  // Internal const constructor
  const CacheSettings._internal({
    required this.storage,
    required this.maxSizeBytes,
    required this.maxAge,
  });

  // Factory constructor to handle the logic
  factory CacheSettings({
    CacheStorage? storage,
    int? maxSizeBytes,
    Duration maxAge = Duration.zero,
  }) {
    return CacheSettings._internal(
      storage:
          storage ?? (kIsWeb ? CacheStorage.memory : CacheStorage.persistent),
      maxSizeBytes: maxSizeBytes ?? (kIsWeb ? 40000000 : 100000000),
      maxAge: maxAge,
    );
  }
}

/// Enum to control the fetch policy for a query
enum QueryFetchPolicy {
  /// Prefer the cache, but fetch from the server if the cached data is stale
  preferCache,

  /// Only fetch from the cache
  cacheOnly,

  /// Only fetch from the server
  serverOnly,
}

/// Represents a cached query result.
class ResultTree {
  /// The dehydrated query result, typically in a serialized format like JSON.
  final Map<String, dynamic> data;

  /// The time-to-live for the cached result, indicating how long it is considered "fresh".
  final Duration ttl;

  /// The timestamp when the result was cached.
  final DateTime cachedAt;

  /// The timestamp when the result was last accessed.
  DateTime lastAccessed;

  /// Checks if cached data is stale
  bool isStale() {
    return DateTime.now().difference(cachedAt) > ttl;
  }

  ResultTree(
      {required this.data,
      required this.ttl,
      required this.cachedAt,
      required this.lastAccessed});

  factory ResultTree.fromJson(Map<String, dynamic> json) => ResultTree(
        data: Map<String, dynamic>.from(json['data'] as Map),
        ttl: Duration(microseconds: json['ttl'] as int),
        cachedAt: DateTime.parse(json['cachedAt'] as String),
        lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      );

  Map<String, dynamic> toJson() => {
        'data': data,
        'ttl': ttl.inMicroseconds,
        'cachedAt': cachedAt.toIso8601String(),
        'lastAccessed': lastAccessed.toIso8601String(),
      };

  factory ResultTree.fromRawJson(String source) =>
      ResultTree.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// Target encoding mode
enum EncodingMode { hydrated, dehydrated }

/// Represents a normalized data entity.
class EntityDataObject {
  /// A globally unique identifier for the entity, provided by the server.
  final String guid;

  /// A dictionary of the scalar values of the entity.
  Map<String, dynamic> _serverValues = {};

  /// A set of identifiers for the `QueryRef`s that reference this EDO.
  Set<String> referencedFrom = {};

  void updateServerValue(String prop, dynamic value, String? requestor) {
    _serverValues[prop] = value;

    if (requestor != null) {
      referencedFrom.add(requestor);
    }
  }

  void setServerValues(Map<String, dynamic> values, String? requestor) {
    _serverValues = values;

    if (requestor != null) {
      referencedFrom.add(requestor);
    }
  }

  /// Dictionary of prop-values contained in this EDO
  Map<String, dynamic> fields() {
    return _serverValues;
  }

  EntityDataObject({required this.guid});

  factory EntityDataObject.fromRawJson(String source) =>
      EntityDataObject.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        kGlobalIDKey: guid,
        '_serverValues': _serverValues,
        'referencedFrom': referencedFrom.toList(),
      };

  factory EntityDataObject.fromJson(Map<String, dynamic> json) {
    EntityDataObject edo = EntityDataObject(
      guid: json[kGlobalIDKey] as String,
    );
    edo.setServerValues(
        Map<String, dynamic>.from(json['_serverValues'] as Map), null);

    List<dynamic>? rf = json['referencedFrom'];
    if (rf != null) {
      edo.referencedFrom = rf.cast<String>().toSet();
    }

    return edo;
  }
}

/// A tree-like data structure that represents the dehydrated or hydrated query result.
class EntityNode {
  /// A reference to an `EntityDataObject`.
  final EntityDataObject? entity;

  /// A dictionary of scalar values (if the node does not represent a normalized entity).
  final Map<String, dynamic>? scalarValues;
  static const String scalarsKey = 'scalars';

  /// A dictionary of references to other `EntityNode`s (for nested objects).
  final Map<String, EntityNode>? nestedObjects;
  static const String objectsKey = 'objects';

  /// A dictionary of lists of other `EntityNode`s (for arrays of objects).
  final Map<String, List<EntityNode>>? nestedObjectLists;
  static const String listsKey = 'lists';

  EntityNode(
      {this.entity,
      this.scalarValues,
      this.nestedObjects,
      this.nestedObjectLists});

  factory EntityNode.fromJson(
      Map<String, dynamic> json, CacheProvider cacheProvider) {
    EntityDataObject? entity;
    if (json[kGlobalIDKey] != null) {
      entity = cacheProvider.getEntityDataObject(json[kGlobalIDKey]);
    }

    Map<String, dynamic>? scalars;
    if (json[scalarsKey] != null) {
      scalars = json[scalarsKey];
    }

    Map<String, EntityNode>? objects;
    if (json[objectsKey] != null) {
      Map<String, dynamic> srcObjMap = json[objectsKey] as Map<String, dynamic>;
      objects = {};
      srcObjMap.forEach((key, value) {
        Map<String, dynamic> objValue = value as Map<String, dynamic>;
        EntityNode node = EntityNode.fromJson(objValue, cacheProvider);
        objects?[key] = node;
      });
    }

    Map<String, List<EntityNode>>? objLists;
    if (json[listsKey] != null) {
      Map<String, dynamic> srcListMap = json[listsKey] as Map<String, dynamic>;
      objLists = {};
      srcListMap.forEach((key, value) {
        List<EntityNode> enodeList = [];
        List<dynamic> jsonList = value as List<dynamic>;
        jsonList.forEach((jsonObj) {
          Map<String, dynamic> jmap = jsonObj as Map<String, dynamic>;
          EntityNode en = EntityNode.fromJson(jmap, cacheProvider);
          enodeList.add(en);
        });
        objLists?[key] = enodeList;
      });
    }
    return EntityNode(
        entity: entity,
        scalarValues: scalars,
        nestedObjects: objects,
        nestedObjectLists: objLists);
  }

  Map<String, dynamic> toJson({EncodingMode mode = EncodingMode.hydrated}) {
    Map<String, dynamic> jsonData = {};
    if (mode == EncodingMode.hydrated) {
      if (entity != null) {
        jsonData.addAll(entity!.fields());
      }

      if (scalarValues != null) {
        jsonData.addAll(scalarValues!);
      }

      if (nestedObjects != null) {
        nestedObjects!.forEach((key, edo) {
          jsonData[key] = edo.toJson(mode: mode);
        });
      }

      if (nestedObjectLists != null) {
        nestedObjectLists!.forEach((key, edoList) {
          List<Map<String, dynamic>> jsonList = [];
          edoList.forEach((edo) {
            jsonList.add(edo.toJson(mode: mode));
          });
          jsonData[key] = jsonList;
        });
      }
    } // if hydrated
    else if (mode == EncodingMode.dehydrated) {
      // encode the guid so we can extract the EntityDataObject
      if (entity != null) {
        jsonData[kGlobalIDKey] = entity!.guid;
      }

      if (scalarValues != null) {
        jsonData[scalarsKey] = scalarValues;
      }

      if (nestedObjects != null) {
        Map<String, dynamic> nestedObjectsJson = {};
        nestedObjects!.forEach((key, edo) {
          nestedObjectsJson[key] = edo.toJson(mode: mode);
        });
        jsonData[objectsKey] = nestedObjectsJson;
      }

      if (nestedObjectLists != null) {
        Map<String, dynamic> nestedObjectListsJson = {};
        nestedObjectLists!.forEach((key, edoList) {
          List<Map<String, dynamic>> jsonList = [];
          edoList.forEach((edo) {
            jsonList.add(edo.toJson(mode: mode));
          });
          nestedObjectListsJson[key] = jsonList;
        });
        jsonData[listsKey] = nestedObjectListsJson;
      }
    }
    return jsonData;
  }
}
