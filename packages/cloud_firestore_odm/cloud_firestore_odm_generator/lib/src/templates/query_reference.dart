// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';

import '../collection_data.dart';

class QueryTemplate {
  QueryTemplate(this.data);

  final CollectionData data;

  @override
  String toString() {
    return '''
abstract class ${data.queryReferenceInterfaceName} implements QueryReference<${data.type}, ${data.querySnapshotName}> {
  @override
  ${data.queryReferenceInterfaceName} limit(int limit);

  @override
  ${data.queryReferenceInterfaceName} limitToLast(int limit);

  /// Perform an order query based on a [FieldPath].
  ///
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  ///
  /// If possible, instead use the more explicit variant of order queries:
  ///
  /// **AVOID**:
  /// ```dart
  /// collection.orderByFieldPath(
  ///   FieldPath.fromString('title'),
  ///   startAt: 'title',
  /// );
  /// ```
  ///
  /// **PREFER**:
  /// ```dart
  /// collection.orderByTitle(startAt: 'title');
  /// ```
  ${data.queryReferenceInterfaceName} orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt,
    Object? startAfter,
    Object? endAt,
    Object? endBefore,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  });

  /// Perform a where query based on a [FieldPath].
  ///
  /// This method is considered unsafe as it does check that the field path
  /// maps to a valid property or that parameters such as [isEqualTo] receive
  /// a value of the correct type.
  ///
  /// If possible, instead use the more explicit variant of where queries:
  ///
  /// **AVOID**:
  /// ```dart
  /// collection.whereFieldPath(FieldPath.fromString('title'), isEqualTo: 'title');
  /// ```
  ///
  /// **PREFER**:
  /// ```dart
  /// collection.whereTitle(isEqualTo: 'title');
  /// ```
  ${data.queryReferenceInterfaceName} whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  });

  ${_where(data, isAbstract: true)}
  ${_orderByProto(data)}
}

class ${data.queryReferenceImplName}
    extends QueryReference<${data.type}, ${data.querySnapshotName}>
    implements ${data.queryReferenceInterfaceName} {
  ${data.queryReferenceImplName}(
    this._collection, {
    required Query<${data.type}> \$referenceWithoutCursor,
    \$QueryCursor \$queryCursor = const \$QueryCursor(),
  })  : super(
          \$referenceWithoutCursor: \$referenceWithoutCursor,
          \$queryCursor: \$queryCursor,
        );

  final CollectionReference<Object?> _collection;

  @override
  Stream<${data.querySnapshotName}> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(${data.querySnapshotName}._fromQuerySnapshot);
  }


  @override
  Future<${data.querySnapshotName}> get([GetOptions? options]) {
    return reference.get(options).then(${data.querySnapshotName}._fromQuerySnapshot);
  }

  @override
  ${data.queryReferenceInterfaceName} limit(int limit) {
    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.limit(limit),
      \$queryCursor: \$queryCursor,
    );
  }

  @override
  ${data.queryReferenceInterfaceName} limitToLast(int limit) {
    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.limitToLast(limit),
      \$queryCursor: \$queryCursor,
    );
  }

  ${data.queryReferenceInterfaceName} orderByFieldPath(
    FieldPath fieldPath, {
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  }) {
    final query = \$referenceWithoutCursor.orderBy(fieldPath, descending: descending);
    var queryCursor = \$queryCursor;

    if (startAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAt: const [],
        startAtDocumentSnapshot: startAtDocument.snapshot,
      );
    }
    if (startAfterDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAfter: const [],
        startAfterDocumentSnapshot: startAfterDocument.snapshot,
      );
    }
    if (endAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        endAt: const [],
        endAtDocumentSnapshot: endAtDocument.snapshot,
      );
    }
    if (endBeforeDocument != null) {
      queryCursor = queryCursor.copyWith(
        endBefore: const [],
        endBeforeDocumentSnapshot: endBeforeDocument.snapshot,
      );
    }

    if (startAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAt: [...queryCursor.startAt, startAt],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [...queryCursor.startAfter, startAfter],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, endAt],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [...queryCursor.endBefore, endBefore],
        endBeforeDocumentSnapshot: null,
      );
    }
    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: query,
      \$queryCursor: queryCursor,
    );
  }

  ${data.queryReferenceInterfaceName} whereFieldPath(
    FieldPath fieldPath, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.where(
        fieldPath,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull,
      ),
      \$queryCursor: \$queryCursor,
    );
  }

  ${_where(data)}
  ${_orderBy(data)}

  ${_equalAndHashCode(data)}
}
''';
  }

  String _orderByProto(CollectionData data) {
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      buffer.writeln(
        '''
  ${data.queryReferenceInterfaceName} orderBy$titledNamed({
    bool descending = false,
    ${field.type.getDisplayString(withNullability: true)} startAt,
    ${field.type.getDisplayString(withNullability: true)} startAfter,
    ${field.type.getDisplayString(withNullability: true)} endAt,
    ${field.type.getDisplayString(withNullability: true)} endBefore,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  });
''',
      );
    }

    return buffer.toString();
  }

  String _orderBy(CollectionData data) {
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      buffer.writeln(
        '''
  ${data.queryReferenceInterfaceName} orderBy$titledNamed({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    ${data.documentSnapshotName}? startAtDocument,
    ${data.documentSnapshotName}? endAtDocument,
    ${data.documentSnapshotName}? endBeforeDocument,
    ${data.documentSnapshotName}? startAfterDocument,
  }) {
    final query = \$referenceWithoutCursor.orderBy(${field.field}, descending: descending);
    var queryCursor = \$queryCursor;

    if (startAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAt: const [],
        startAtDocumentSnapshot: startAtDocument.snapshot,
      );
    }
    if (startAfterDocument != null) {
      queryCursor = queryCursor.copyWith(
        startAfter: const [],
        startAfterDocumentSnapshot: startAfterDocument.snapshot,
      );
    }
    if (endAtDocument != null) {
      queryCursor = queryCursor.copyWith(
        endAt: const [],
        endAtDocumentSnapshot: endAtDocument.snapshot,
      );
    }
    if (endBeforeDocument != null) {
      queryCursor = queryCursor.copyWith(
        endBefore: const [],
        endBeforeDocumentSnapshot: endBeforeDocument.snapshot,
      );
    }

    if (startAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAt: [...queryCursor.startAt, startAt],
        startAtDocumentSnapshot: null,
      );
    }
    if (startAfter != _sentinel) {
      queryCursor = queryCursor.copyWith(
        startAfter: [...queryCursor.startAfter, startAfter],
        startAfterDocumentSnapshot: null,
      );
    }
    if (endAt != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endAt: [...queryCursor.endAt, endAt],
        endAtDocumentSnapshot: null,
      );
    }
    if (endBefore != _sentinel) {
      queryCursor = queryCursor.copyWith(
        endBefore: [...queryCursor.endBefore, endBefore],
        endBeforeDocumentSnapshot: null,
      );
    }

    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: query,
      \$queryCursor: queryCursor,
    );
  }
''',
      );
    }

    return buffer.toString();
  }

  String _where(CollectionData data, {bool isAbstract = false}) {
    // TODO handle JsonSerializable case change and JsonKey(name: ...)
    final buffer = StringBuffer();

    for (final field in data.queryableFields) {
      final _isEnum = field.type.element?.kind == ElementKind.ENUM;
      var _isEnumList = false;
      var _isEnumListMap = false;
      var _isEnumMap = false;

      if (field.type.isDartCoreList) {
        final _typeArguments = (field.type as InterfaceType).typeArguments;
        for (final subType in _typeArguments) {
          if (subType.isDartCoreMap) {
            // We have something like this: Map<CastType, String>
            // TODO: Need to get the subtypes of subtype. In this case CastTYpe
            // and then test it to see if it is an Enum

            final _mapTypeArguments = (subType as InterfaceType).typeArguments;
            for (final subSubType in _mapTypeArguments) {
              if (subSubType.element?.kind == ElementKind.ENUM) {
                _isEnumListMap = true;
              }
              // _isEnumListMap = subSubType.element?.kind == ElementKind.ENUM;
            }
          } else if (subType.element?.kind == ElementKind.ENUM) {
            _isEnumList = true;
          }
        }
      } else if (field.type.isDartCoreMap) {
        final _mapTypeArguments = (field.type as InterfaceType).typeArguments;
        for (final subSubType in _mapTypeArguments) {
          if (subSubType.element?.kind == ElementKind.ENUM) {
            _isEnumMap = true;
          }
        }
      }

      final titledNamed = field.name.replaceFirstMapped(
        RegExp('[a-zA-Z]'),
        (match) => match.group(0)!.toUpperCase(),
      );

      final nullableType =
          field.type.nullabilitySuffix == NullabilitySuffix.question
              ? '${field.type}'
              : '${field.type}?';

      final operators = {
        'isEqualTo': nullableType,
        'isNotEqualTo': nullableType,
        'isLessThan': nullableType,
        'isLessThanOrEqualTo': nullableType,
        'isGreaterThan': nullableType,
        'isGreaterThanOrEqualTo': nullableType,
        'isNull': 'bool?',
        if (field.type.isDartCoreList) ...{
          'arrayContains': data.libraryElement.typeProvider
              .asNullable((field.type as InterfaceType).typeArguments.first),
          'arrayContainsAny': nullableType,
        } else ...{
          'whereIn': 'List<${field.type}>?',
          'whereNotIn': 'List<${field.type}>?',
        }
      };

      final prototype =
          operators.entries.map((e) => '${e.value} ${e.key},').join();

      // final parameters = operators.keys.map((e) => '$e: $e').join(',');
      final parameters = operators.keys.map((e) {
        if (_isEnumList) {
          if (e == 'arrayContains') {
            return '$e: $e?.name';
          } else if (e == 'isNull') {
            return '$e: $e';
          } else {
            return '$e: _enumConvertList($e)';
          }
        } else if (_isEnumListMap) {
          if (e == 'arrayContains') {
            return '$e: _enumConvertMap($e)';
          } else if (e == 'isNull') {
            return '$e: $e';
          } else {
            return '$e: _enumConvertListMap($e)';
          }
        } else if (_isEnum) {
          if (e == 'whereIn') {
            return '$e: _whereInList';
          } else if (e == 'whereNotIn') {
            return '$e: _whereNotInList';
          } else if (e == 'isNull') {
            return '$e: isNull';
          } else {
            return '$e: $e?.name';
          }
        } else if (_isEnumMap) {
          // TODO fully support a Map of Enums
          return '$e: $e?.name';
        } else {
          return '$e: $e';
        }
      }).join(',');

      // TODO support whereX(isEqual: null);
      // TODO handle JsonSerializable case change and JsonKey(name: ...)

      if (isAbstract) {
        buffer.writeln(
          '${data.queryReferenceInterfaceName} where$titledNamed({$prototype});',
        );
      } else if (_isEnumList) {
        buffer.writeln(
          '''
  ${data.queryReferenceInterfaceName} where$titledNamed({$prototype}) {

    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.where(${field.field}, $parameters),
      \$queryCursor: \$queryCursor,
    );
    // return ${data.queryReferenceImplName}(
    //   reference.where('${field.name}', $parameters,),
    //   _collection,
    // );
  }
''',
        );
      } else if (_isEnumListMap) {
        buffer.writeln(
          '''
  ${data.queryReferenceInterfaceName} where$titledNamed({$prototype}) {
    List<Map<String, String>>? _enumConvertListMap($nullableType enumListMap) {
      if (enumListMap == null) {
        return null;
      }
      List<Map<String, String>>? _tmpEnumListMap;

      for (var e in enumListMap) {
        e.forEach((k,v) {
          // TODO: Test for an enum key or enum value
          // var _k = (k is Enum) ? k.name : k;
          // var _v = (v is Enum) ? v.name : v;
          var _k = k.name;
          var _v = v;
          _tmpEnumListMap?.add({_k: _v});
        });
      };
      return _tmpEnumListMap;
    }

    Map<String, String>? _enumConvertMap(${data.libraryElement.typeProvider.asNullable((field.type as InterfaceType).typeArguments.first)} enumMap) {

      Map<String, String>? _tmpEnumMap;
      enumMap?.forEach((k,v) {
        _tmpEnumMap?.update(k.name, (oldVal) => v);
      });
      return _tmpEnumMap;
    }

    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.where(${field.field}, $parameters),
      \$queryCursor: \$queryCursor,
    );
    // return ${data.queryReferenceImplName}(
    //   reference.where('${field.name}', $parameters,),
    //   _collection,
    // );
  }
''',
        );
      } else if (_isEnum) {
        buffer.writeln(
          '''
  ${data.queryReferenceInterfaceName} where$titledNamed({$prototype}) {
    List<String>? _whereInList;
    whereIn?.forEach((e) { _whereInList?.add(e.name); });
    List<String>? _whereNotInList;
    whereNotIn?.forEach((e) { _whereNotInList?.add(e.name); });

    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.where(${field.field}, $parameters),
      \$queryCursor: \$queryCursor,
    );
    // return ${data.queryReferenceImplName}(
    //   reference.where('${field.name}', $parameters,),
    //   _collection,
    // );
  }
''',
        );
      } else {
        buffer.writeln(
          '''
  ${data.queryReferenceInterfaceName} where$titledNamed({$prototype}) {
    return ${data.queryReferenceImplName}(
      _collection,
      \$referenceWithoutCursor: \$referenceWithoutCursor.where(${field.field}, $parameters),
      \$queryCursor: \$queryCursor,
    );
  }
''',
        );
      }
    }

    return buffer.toString();
  }

  String _equalAndHashCode(CollectionData data) {
    final propertyNames = [
      'runtimeType',
      'reference',
    ];

    return '''
  @override
  bool operator ==(Object other) {
    return other is ${data.queryReferenceImplName}
      && ${propertyNames.map((p) => 'other.$p == $p').join(' && ')};
  }

  @override
  int get hashCode => Object.hash(${propertyNames.join(', ')});
''';
  }
}

extension on TypeProvider {
  DartType asNullable(DartType type) {
    final typeSystem = nullType.element.library.typeSystem;
    if (typeSystem.isNullable(type)) return type;

    return typeSystem.leastUpperBound(type, nullType);
  }
}
