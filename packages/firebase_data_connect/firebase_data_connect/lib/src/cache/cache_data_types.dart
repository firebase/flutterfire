
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

/// Type of storage to use for the cache
enum CacheStorage {
  persistent, 
  memory
}

const String GlobalIDKey = 'cacheId';

/// Configuration for the cache
class CacheSettings {
  /// The type of storage to use (e.g., "persistent", "ephemeral")
  final CacheStorage storage;

  /// The maximum size of the cache in bytes
  final int maxSizeBytes;

  const CacheSettings({this.storage = CacheStorage.memory, this.maxSizeBytes = 100000000});
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

  /// A reference to the root `EntityNode` of the dehydrated tree.
  final EntityNode rootObject;

  /// Checks if cached data is stale
  bool isStale() {
    if (DateTime.now().difference(cachedAt) > ttl) {
      return true; // stale
    } else {
      return false;
    } 
  }


  ResultTree(
      {required this.data,
      required this.ttl,
      required this.cachedAt,
      required this.lastAccessed,
      required this.rootObject});
}

/// Target encoding mode
enum EncodingMode {
  hydrated,
  dehydrated
}

/// Represents a normalized data entity.
class EntityDataObject {
  /// A globally unique identifier for the entity, provided by the server.
  final String guid;

  /// A dictionary of the scalar values of the entity.
  Map<String, dynamic> _serverValues = {};

  /// A set of identifiers for the `QueryRef`s that reference this EDO.
  final Set<String> referencedFrom = {};

  void updateServerValue(String prop, dynamic value) {
    _serverValues[prop] = value;
  }

  void setServerValues(Map<String, dynamic> values) {
    _serverValues = values;
  }

  /// Dictionary of prop-values contained in this EDO
  Map<String, dynamic> fields() {
    return _serverValues;
  }

  EntityDataObject(
      {required this.guid});
}

/// A tree-like data structure that represents the dehydrated or hydrated query result.
class EntityNode {
  /// A reference to an `EntityDataObject`.
  final EntityDataObject? entity;

  /// A dictionary of scalar values (if the node does not represent a normalized entity).
  final Map<String, dynamic>? scalarValues;

  /// A dictionary of references to other `EntityNode`s (for nested objects).
  final Map<String, EntityNode>? nestedObjects;

  /// A dictionary of lists of other `EntityNode`s (for arrays of objects).
  final Map<String, List<EntityNode>>? nestedObjectLists;

  EntityNode(
      {this.entity,
      this.scalarValues,
      this.nestedObjects,
      this.nestedObjectLists});

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
          edoList.forEach((edo){
            jsonList.add(edo.toJson(mode: mode));
          });
          jsonData[key] = jsonList;
        });
      }

    } // if hydrated 
    else if (mode == EncodingMode.dehydrated) {
      // encode the guid so we can extract the EntityDataObject
      if (entity != null) {
        jsonData[GlobalIDKey] = entity!.guid;
      }

      if (scalarValues != null) {
        jsonData['scalars'] = scalarValues;
      }

      if (nestedObjects != null) {
        List<Map<String, dynamic>> nestedObjectsJson = [];
        nestedObjects!.forEach((key, edo){
          Map<String, dynamic> obj = {};
          obj[key] = edo.toJson(mode: mode);
          nestedObjectsJson.add(obj);
        }); 
        jsonData['objects'] = nestedObjectsJson;
      }

      if (nestedObjectLists != null) {
        List<Map<String, dynamic>> nestedObjectListsJson = [];
        nestedObjectLists!.forEach((key, edoList){
          List<Map<String, dynamic>> jsonList = [];
          edoList.forEach((edo){
            jsonList.add(edo.toJson(mode: mode));
          });
          nestedObjectListsJson.add({key: jsonList});
        });
        jsonData['lists'] = nestedObjectListsJson;
      }

    }
    return jsonData;
  }
}
