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

import 'cache_data_types.dart';
import 'cache_provider.dart';

/// An in-memory implementation of the `CacheProvider`.
/// This is used for the web platform
class InMemoryCacheProvider implements CacheProvider {
  final Map<String, ResultTree> _resultTrees = {};
  final Map<String, EntityDataObject> _edos = {};

  final String cacheIdentifier;

  InMemoryCacheProvider(this.cacheIdentifier);

  @override
  String identifier() {
    return cacheIdentifier;
  }

  @override
  Future<bool> initialize() async {
    // nothing to be intialized
    return true;
  }

  @override
  void setResultTree(String queryId, ResultTree resultTree) {
    _resultTrees[queryId] = resultTree;
  }

  @override
  ResultTree? getResultTree(String queryId) {
    return _resultTrees[queryId];
  }

  @override
  void updateEntityData(EntityDataObject edo) {
    _edos[edo.guid] = edo;
  }

  @override
  EntityDataObject getEntityData(String guid) {
    return _edos.putIfAbsent(guid, () => EntityDataObject(guid: guid));
  }

  @override
  void clear() {
    _resultTrees.clear();
    _edos.clear();
  }
}

CacheProvider cacheImplementation(String identifier, bool memory) =>
    InMemoryCacheProvider(identifier);
