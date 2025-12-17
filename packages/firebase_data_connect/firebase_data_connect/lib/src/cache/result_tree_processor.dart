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

    Map<String, dynamic> jsonData = serverResponse;
    if (serverResponse.containsKey('data')) {
      jsonData = serverResponse['data'];
    }
    final rootNode =
        _dehydrateNode(queryId, jsonData, cacheProvider, impactedQueryIds);

    return DehydrationResult(rootNode, impactedQueryIds);
  }

  EntityNode _dehydrateNode(String queryId, dynamic data,
      CacheProvider cacheProvider, Set<String> impactedQueryIds) {
    if (data is Map<String, dynamic>) {
      // data contains a unique entity id. we can normalize
      final guid = data[kGlobalIDKey] as String?;

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
        } else if (value is List) {
          final nodeList = <EntityNode>[];
          final scalarValueList = <dynamic>[];
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              nodeList.add(_dehydrateNode(
                  queryId, item, cacheProvider, impactedQueryIds));
            } else {
              // assuming scalar - we don't handle array of arrays
              scalarValueList.add(item);
            }
          }

          // we either do object lists or scalar lists stored with scalars
          // we don't handle mixed lists.
          if (nodeList.isNotEmpty) {
            nestedObjectLists[key] = nodeList;
          } else {
            serverValues[key] = scalarValueList;
          }
        } else {
          serverValues[key] = value;
        }
      }

      if (guid != null) {
        final existingEdo = cacheProvider.getEntityDataObject(guid);
        //existingEdo.referencedFrom.add(queryId);
        existingEdo.setServerValues(serverValues, queryId);
        cacheProvider.saveEntityDataObject(existingEdo);
        impactedQueryIds.addAll(existingEdo.referencedFrom);

        return EntityNode(
            entity: existingEdo,
            nestedObjects: nestedObjects,
            nestedObjectLists: nestedObjectLists);
      } else {
        return EntityNode(
            scalarValues: serverValues,
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
    final Map<String, dynamic> data = {};
    if (node.entity != null) {
      final edo = cacheProvider.getEntityDataObject(node.entity!.guid);
      data.addAll(edo.fields());
    }

    if (node.scalarValues != null) {
      if (node.scalarValues!.containsKey('value')) {
        return node.scalarValues!['value'];
      }
      return node.scalarValues;
    }
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
  }
}
