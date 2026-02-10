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

      int curVersion = _getDatabaseVersion();
      if (curVersion == 0) {
        _createTables();
      } else {
        int major = curVersion ~/ 1000000;
        if (major != 1) {
          developer.log(
              'Unsupported schema major version $major detected. Expected 1');
          return false;
        }
      }

      return true;
    } catch (e) {
      developer.log('Error initializing SQLiteProvider $e');
      return false;
    }
  }

  int _getDatabaseVersion() {
    final resultSet = _db.select('PRAGMA user_version;');
    return resultSet.first.columnAt(0) as int;
  }

  void _setDatabaseVersion(int version) {
    _db.execute('PRAGMA user_version = $version;');
  }

  void _createTables() {
    _db.execute('BEGIN TRANSACTION');
    try {
      _db.execute('''
        CREATE TABLE IF NOT EXISTS $resultTreeTable (
          query_id TEXT PRIMARY KEY NOT NULL,
          last_accessed REAL NOT NULL,
          data TEXT NOT NULL
        );
      ''');
      _db.execute('''
        CREATE TABLE IF NOT EXISTS $entityDataTable (
          entity_guid TEXT PRIMARY KEY NOT NULL,
          data TEXT NOT NULL
        );
      ''');
      _setDatabaseVersion(1000000); // 1.0.0
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  String identifier() {
    return _identifier;
  }

  @override
  void clear() {
    _db.execute('BEGIN TRANSACTION');
    try {
      _db.execute('DELETE FROM $resultTreeTable');
      _db.execute('DELETE FROM $entityDataTable');
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  EntityDataObject getEntityData(String guid) {
    final resultSet = _db.select(
      'SELECT data FROM $entityDataTable WHERE entity_guid = ?',
      [guid],
    );
    if (resultSet.isEmpty) {
      // not found lets create an empty one and save it.
      EntityDataObject edo = EntityDataObject(guid: guid);
      updateEntityData(edo);
      return edo;
    }
    return EntityDataObject.fromRawJson(resultSet.first['data'] as String);
  }

  @override
  ResultTree? getResultTree(String queryId) {
    final resultSet = _db.select(
      'SELECT data FROM $resultTreeTable WHERE query_id = ?',
      [queryId],
    );
    if (resultSet.isEmpty) {
      return null;
    }
    _updateLastAccessedTime(queryId);
    return ResultTree.fromRawJson(resultSet.first['data'] as String);
  }

  void _updateLastAccessedTime(String queryId) {
    _db.execute(
      'UPDATE $resultTreeTable SET last_accessed = ? WHERE query_id = ?',
      [DateTime.now().millisecondsSinceEpoch / 1000.0, queryId],
    );
  }

  @override
  void updateEntityData(EntityDataObject edo) {
    String rawJson = edo.toRawJson();
    _db.execute('BEGIN TRANSACTION');
    try {
      _db.execute(
        'INSERT OR REPLACE INTO $entityDataTable (entity_guid, data) VALUES (?, ?)',
        [edo.guid, rawJson],
      );
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  @override
  void setResultTree(String queryId, ResultTree resultTree) {
    _db.execute('BEGIN TRANSACTION');
    try {
      _db.execute(
        'INSERT OR REPLACE INTO $resultTreeTable (query_id, last_accessed, data) VALUES (?, ?, ?)',
        [
          queryId,
          DateTime.now().millisecondsSinceEpoch / 1000.0,
          resultTree.toRawJson()
        ],
      );
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }
}

CacheProvider cacheImplementation(String identifier, bool memory) =>
    SQLite3CacheProvider(identifier, memory: memory);
