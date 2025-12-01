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

import '../common/common_library.dart';
import 'cache_data_types.dart';
import 'cache_provider.dart';

import 'dart:convert';

class DehydrationResult {
  final EntityNode dehydratedTree;
  final Set<String> impactedQueryIds;

  DehydrationResult(this.dehydratedTree, this.impactedQueryIds);
}

/// Responsible for the "dehydration" and "hydration" processes.
class ResultTreeProcessor {
  /// Takes a server response, traverses the data, creates or updates `EntityDataObject`s,
  /// and builds a dehydrated `EntityNode` tree.
  Future<DehydrationResult> dehydrate(String queryId,
      Map<String, dynamic> serverResponse, CacheProvider cacheProvider) async {
    final impactedQueryIds = <String>{};

    print("dehydrate: ${jsonEncode(serverResponse)}");

    Map<String, dynamic> jsonData = serverResponse;
    if (serverResponse.containsKey('data')) {
      jsonData = serverResponse['data'];
    }
    final rootNode =
        _dehydrateNode(queryId, jsonData, cacheProvider, impactedQueryIds);

    //debug only

    print(
        "dehydrated rootNode ${jsonEncode(rootNode.toJson(mode: EncodingMode.dehydrated))}");

    return DehydrationResult(rootNode, impactedQueryIds);
  }

  EntityNode _dehydrateNode(String queryId, dynamic data,
      CacheProvider cacheProvider, Set<String> impactedQueryIds) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey(GlobalIDKey)) {
        final guid = data[GlobalIDKey] as String;
        print("dehydrate - obj with globalId ${guid}");

        final serverValues = <String, dynamic>{};
        final nestedObjects = <String, EntityNode>{};
        final nestedObjectLists = <String, List<EntityNode>>{};

        for (final entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is Map<String, dynamic>) {
            EntityNode en =
                _dehydrateNode(queryId, value, cacheProvider, impactedQueryIds);
            nestedObjects[key] = en;
            if (en != null) {
              print(
                  'dehydrate - got nestedObject EN for key ${key} ${en!.scalarValues?.length} ${en!.nestedObjectLists?.length} ${en!.nestedObjects?.length}');
            } else {
              print("dehydrate - EntityNode is null");
            }
          } else if (value is List) {
            final nodeList = <EntityNode>[];
            for (final item in value) {
              nodeList.add(_dehydrateNode(
                  queryId, item, cacheProvider, impactedQueryIds));
            }
            nestedObjectLists[key] = nodeList;
          } else {
            serverValues[key] = value;
          }
        }

        final existingEdo = cacheProvider.getEntityDataObject(guid);
        existingEdo.referencedFrom.add(queryId);
        impactedQueryIds.addAll(existingEdo.referencedFrom);
        existingEdo.setServerValues(serverValues);
        cacheProvider.saveEntityDataObject(existingEdo);

        print(
            "dehydrate - returning EN ${existingEdo.guid} with EDO ${existingEdo}");
        return EntityNode(
            entity: existingEdo,
            nestedObjects: nestedObjects,
            nestedObjectLists: nestedObjectLists);
      } else {
        // GlobalID check
        print("dehydrate - no globalID ${data}");
        final scalarValues = <String, dynamic>{};
        final nestedObjects = <String, EntityNode>{};
        final nestedObjectLists = <String, List<EntityNode>>{};

        for (final entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          if (value is Map<String, dynamic>) {
            nestedObjects[key] =
                _dehydrateNode(queryId, value, cacheProvider, impactedQueryIds);
          } else if (value is List) {
            print("dehydrate - listValue for key ${key} count ${value.length}");
            final nodeList = <EntityNode>[];
            for (final item in value) {
              nodeList.add(_dehydrateNode(
                  queryId, item, cacheProvider, impactedQueryIds));
            }
            nestedObjectLists[key] = nodeList;
            print(
                "dehydrate - added to lists ${key} ${nodeList.length} ${jsonEncode(nodeList)}");
          } else {
            scalarValues[key] = value;
          }
        }
        print(
            "dehydrate - returning an EN with scalaraValues ${scalarValues.length} nestedObjectLists ${nestedObjectLists.length} nestedObjects ${nestedObjects.length}");

        return EntityNode(
            scalarValues: scalarValues,
            nestedObjects: nestedObjects,
            nestedObjectLists: nestedObjectLists);
      }
    } else {
      throw DataConnectError(DataConnectErrorCode.codecFailed,
          'Unexpected object type while caching');
    }
  }

  /// Takes a dehydrated `EntityNode` tree, fetches the corresponding `EntityDataObject`s
  /// from the `CacheProvider`, and reconstructs the original data structure.
  Future<Map<String, dynamic>> hydrate(
      EntityNode dehydratedTree, CacheProvider cacheProvider) async {
    return await _hydrateNode(dehydratedTree, cacheProvider)
        as Map<String, dynamic>;
  }

  Future<dynamic> _hydrateNode(
      EntityNode node, CacheProvider cacheProvider) async {
    if (node.entity != null) {
      final edo = cacheProvider.getEntityDataObject(node.entity!.guid);
      final data = Map<String, dynamic>.from(edo.fields());

      if (node.nestedObjects != null) {
        for (final entry in node.nestedObjects!.entries) {
          data[entry.key] = await _hydrateNode(entry.value, cacheProvider);
        }
      }

      if (node.nestedObjectLists != null) {
        for (final entry in node.nestedObjectLists!.entries) {
          final list = <dynamic>[];
          for (final item in entry.value) {
            list.add(await _hydrateNode(item, cacheProvider));
          }
          data[entry.key] = list;
        }
      }

      return data;
    } else if (node.scalarValues != null) {
      if (node.scalarValues!.containsKey('value')) {
        return node.scalarValues!['value'];
      }
      return node.scalarValues;
    } else if (node.nestedObjects != null) {
      final data = <String, dynamic>{};
      for (final entry in node.nestedObjects!.entries) {
        data[entry.key] = await _hydrateNode(entry.value, cacheProvider);
      }
      return data;
    } else if (node.nestedObjectLists != null &&
        node.nestedObjectLists!.containsKey('list')) {
      final list = <dynamic>[];
      for (final item in node.nestedObjectLists!['list']!) {
        list.add(await _hydrateNode(item, cacheProvider));
      }
      return list;
    } else {
      return {};
    }
  }
}
