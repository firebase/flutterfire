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

import 'package:firebase_data_connect/src/cache/cache_provider.dart';
import 'package:firebase_data_connect/src/cache/cache_data_types.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'dart:developer' as developer;

class SQLite3CacheProvider implements CacheProvider {
  late final Database _db;
  final String _identifier;
  final bool memory;

  final String entityDataTable = 'entity_data';
  final String resultTreeTable = 'query_results';

  SQLite3CacheProvider(this._identifier, {this.memory = false});

  @override
  Future<bool> initialize() async {
    try {
      if (memory) {
        _db = sqlite3.open(':memory:');
      } else {
        final dbPath = await getApplicationDocumentsDirectory();
        final path = join(dbPath.path, '$_identifier.db');
        _db = sqlite3.open(path);
      }
      _createTables();
      return true;
    } catch (e) {
      developer.log('Error initializing SQLiteProvider $e');
      return false;
    }
  }

  void _createTables() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $resultTreeTable (
        query_id TEXT PRIMARY KEY,
        result_tree TEXT
      );
    ''');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $entityDataTable (
        guid TEXT PRIMARY KEY,
        entity_data_object TEXT
      );
    ''');
  }

  @override
  String identifier() {
    return _identifier;
  }

  @override
  void clear() {
    _db.execute('DELETE FROM $resultTreeTable');
    _db.execute('DELETE FROM $entityDataTable');
  }

  @override
  EntityDataObject getEntityDataObject(String guid) {
    final resultSet = _db.select(
      'SELECT entity_data_object FROM $entityDataTable WHERE guid = ?',
      [guid],
    );
    if (resultSet.isEmpty) {
      // not found lets create an empty one.
      EntityDataObject edo = EntityDataObject(guid: guid);
      return edo;
    }
    return EntityDataObject.fromRawJson(
        resultSet.first['entity_data_object'] as String);
  }

  @override
  ResultTree? getResultTree(String queryId) {
    final resultSet = _db.select(
      'SELECT result_tree FROM $resultTreeTable WHERE query_id = ?',
      [queryId],
    );
    if (resultSet.isEmpty) {
      return null;
    }
    return ResultTree.fromRawJson(resultSet.first['result_tree'] as String);
  }

  @override
  void manageCacheSize() {
    // TODO: implement manageCacheSize
  }

  @override
  void saveEntityDataObject(EntityDataObject edo) {
    String rawJson = edo.toRawJson();
    _db.execute(
      'INSERT OR REPLACE INTO $entityDataTable (guid, entity_data_object) VALUES (?, ?)',
      [edo.guid, rawJson],
    );
  }

  @override
  void saveResultTree(String queryId, ResultTree resultTree) {
    _db.execute(
      'INSERT OR REPLACE INTO $resultTreeTable (query_id, result_tree) VALUES (?, ?)',
      [queryId, resultTree.toRawJson()],
    );
  }
}

CacheProvider cacheImplementation(String identifier, bool memory) =>
    SQLite3CacheProvider(identifier, memory: memory);
