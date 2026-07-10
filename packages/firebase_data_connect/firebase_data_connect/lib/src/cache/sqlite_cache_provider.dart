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
  final String? customDbPath;
  bool _inTransaction = false;
  bool _dbOpened = false;
  final List<PreparedStatement> _openedStatements = [];

  @override
  Future<T> runInTransaction<T>(FutureOr<T> Function() action) async {
    if (_inTransaction) {
      return await action();
    }
    _db.execute('BEGIN TRANSACTION');
    _inTransaction = true;
    try {
      final result = await action();
      _db.execute('COMMIT');
      return result;
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    } finally {
      _inTransaction = false;
    }
  }

  late final PreparedStatement _selectEntityStmt;
  late final PreparedStatement _insertEntityStmt;
  late final PreparedStatement _selectResultStmt;
  late final PreparedStatement _insertResultStmt;

  final String entityDataTable = 'entity_data';
  final String resultTreeTable = 'query_results';

  SQLite3CacheProvider(this._identifier,
      {this.memory = false, this.customDbPath});

  @override
  Future<bool> initialize() async {
    try {
      if (memory) {
        _db = sqlite3.open(':memory:');
      } else {
        final String pathStr;
        if (customDbPath != null) {
          pathStr = join(customDbPath!, '$_identifier.db');
        } else {
          final dbPath = await getApplicationDocumentsDirectory();
          pathStr = join(dbPath.path, '$_identifier.db');
        }
        _db = sqlite3.open(pathStr);
      }
      _dbOpened = true;

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

      final selectEntityStmt = _db
          .prepare('SELECT data FROM $entityDataTable WHERE entity_guid = ?');
      _openedStatements.add(selectEntityStmt);
      _selectEntityStmt = selectEntityStmt;

      final insertEntityStmt = _db.prepare(
          'INSERT OR REPLACE INTO $entityDataTable (entity_guid, data) VALUES (?, ?)');
      _openedStatements.add(insertEntityStmt);
      _insertEntityStmt = insertEntityStmt;

      final selectResultStmt =
          _db.prepare('SELECT data FROM $resultTreeTable WHERE query_id = ?');
      _openedStatements.add(selectResultStmt);
      _selectResultStmt = selectResultStmt;

      final insertResultStmt = _db.prepare(
          'INSERT OR REPLACE INTO $resultTreeTable (query_id, last_accessed, data) VALUES (?, ?, ?)');
      _openedStatements.add(insertResultStmt);
      _insertResultStmt = insertResultStmt;

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
    final resultSet = _selectEntityStmt.select([guid]);
    if (resultSet.isEmpty) {
      // not found lets create an empty one
      EntityDataObject edo = EntityDataObject(guid: guid);
      return edo;
    }
    return EntityDataObject.fromRawJson(resultSet.first['data'] as String);
  }

  @override
  ResultTree? getResultTree(String queryId) {
    final resultSet = _selectResultStmt.select([queryId]);
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
    final needsTransaction = !_inTransaction;
    if (needsTransaction) {
      _db.execute('BEGIN TRANSACTION');
    }
    try {
      _insertEntityStmt.execute([edo.guid, rawJson]);
      if (needsTransaction) {
        _db.execute('COMMIT');
      }
    } catch (_) {
      if (needsTransaction) {
        _db.execute('ROLLBACK');
      }
      rethrow;
    }
  }

  @override
  void setResultTree(String queryId, ResultTree resultTree) {
    final needsTransaction = !_inTransaction;
    if (needsTransaction) {
      _db.execute('BEGIN TRANSACTION');
    }
    try {
      _insertResultStmt.execute([
        queryId,
        DateTime.now().millisecondsSinceEpoch / 1000.0,
        resultTree.toRawJson()
      ]);
      if (needsTransaction) {
        _db.execute('COMMIT');
      }
    } catch (_) {
      if (needsTransaction) {
        _db.execute('ROLLBACK');
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      for (final stmt in _openedStatements) {
        try {
          stmt.close();
        } catch (e) {
          developer.log('Error closing prepared statement: $e');
        }
      }
      _openedStatements.clear();

      if (_dbOpened) {
        _db.close();
      }
    } catch (e) {
      developer.log('Error disposing SQLite3 resources: $e');
    }
  }
}

CacheProvider cacheImplementation(String identifier, bool memory,
        {String? customDbPath}) =>
    SQLite3CacheProvider(identifier,
        memory: memory, customDbPath: customDbPath);
