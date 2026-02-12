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

/// An interface that defines the contract for the underlying storage mechanism.
///
/// This allows for different storage implementations to be used (e.g., in-memory, SQLite, IndexedDB).
abstract class CacheProvider {
  /// Identifier for this provider
  String identifier();

  /// Initialize the provider async
  Future<bool> initialize();

  /// Stores a `ResultTree` object.
  void saveResultTree(String queryId, ResultTree resultTree);

  /// Retrieves a `ResultTree` object.
  ResultTree? getResultTree(String queryId);

  /// Stores an `EntityDataObject` object.
  void saveEntityDataObject(EntityDataObject edo);

  /// Retrieves an `EntityDataObject` object.
  EntityDataObject getEntityDataObject(String guid);

  /// Manages the cache size and eviction policies.
  void manageCacheSize();

  /// Clears all data from the cache.
  void clear();
}
