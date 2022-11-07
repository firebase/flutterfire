// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../collection_data.dart';
import '../collection_generator.dart';

class FieldEnum {
  FieldEnum(this.field) {
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
  }

  QueryingField field;
  var _isEnumList = false;
  var _isEnumListMap = false;
  var _isEnumMap = false;

  bool get isEnumList => _isEnumList;
  bool get isEnumListMap => _isEnumListMap;
  bool get isEnumMap => _isEnumMap;
}

class DocumentReferenceTemplate {
  DocumentReferenceTemplate(this.data);

  final CollectionData data;

  @override
  String toString() {
    return '''
abstract class ${data.documentReferenceName} extends FirestoreDocumentReference<${data.type}, ${data.documentSnapshotName}> {
  factory ${data.documentReferenceName}(DocumentReference<${data.type}> reference) = _\$${data.documentReferenceName};

  DocumentReference<${data.type}> get reference;

  ${_parent(data)}

  ${_subCollections(data)}

  @override
  Stream<${data.documentSnapshotName}> snapshots();

  @override
  Future<${data.documentSnapshotName}> get([GetOptions? options]);

  @override
  Future<void> delete();

  ${_updatePrototype(data)}
}

class _\$${data.documentReferenceName}
      extends FirestoreDocumentReference<${data.type}, ${data.documentSnapshotName}>
      implements ${data.documentReferenceName} {
  _\$${data.documentReferenceName}(this.reference);

  @override
  final DocumentReference<${data.type}> reference;

  ${_parent(data)}

  ${_subCollections(data)}

  @override
  Stream<${data.documentSnapshotName}> snapshots() {
    return reference.snapshots().map(${data.documentSnapshotName}._);
  }

  @override
  Future<${data.documentSnapshotName}> get([GetOptions? options]) {
    return reference.get(options).then(${data.documentSnapshotName}._);
  }

  @override
  Future<${data.documentSnapshotName}> transactionGet(Transaction transaction) {
    return transaction.get(reference).then(${data.documentSnapshotName}._);
  }

  ${_update(data)}

  ${_equalAndHashCode(data)}
}
''';
  }

  String _updatePrototype(CollectionData data) {
    if (data.updatableFields.isEmpty) return '';

    final parameters = [
      for (final field in data.updatableFields)
        if (field.updatable) ...[
          '${field.type.getDisplayString(withNullability: true)} ${field.name},',
          'FieldValue ${field.name}FieldValue,'
        ]
    ];

    return '''
/// Updates data on the document. Data will be merged with any existing
/// document data.
///
/// If no document exists yet, the update will fail.
Future<void> update({${parameters.join()}});

/// Updates fields in the current document using the transaction API.
///
/// The update will fail if applied to a document that does not exist.
void transactionUpdate(Transaction transaction, {${parameters.join()}});
''';
  }

  String _update(CollectionData data) {
    if (data.updatableFields.isEmpty) return '';

    final parameters = [
      for (final field in data.updatableFields) ...[
        'Object? ${field.name} = _sentinel,',
        'FieldValue? ${field.name}FieldValue,',
      ]
    ];

    // TODO support nested objects
    final json = <String>[];

    for (final field in data.updatableFields) {
      if (FieldEnum(field).isEnumList) {
        json.add(
          """
          if (${field.name} != _sentinel)
            '${field.name}': _enumConvertList(${field.name} as ${field.type}),
          """,
        );
      } else if (FieldEnum(field).isEnumListMap) {
        json.add(
          """
          if (${field.name} != _sentinel)
            '${field.name}': _enumConvertListMap(${field.name} as ${field.type}),
          """,
        );
      } else {
        json.add(
          """
          if (${field.name} != _sentinel)
            '${field.name}': ${field.name} as ${field.type},
          """,
        );
      }
    }

    final asserts = [
      for (final field in data.updatableFields)
        '''
        assert(
          ${field.name} == _sentinel || ${field.name}FieldValue == null,
          "Cannot specify both ${field.name} and ${field.name}FieldValue",
        );''',
    ].join();

    return '''
Future<void> update({${parameters.join()}}) async {
  $asserts
  final json = {${json.join()}};

  return reference.update(json);
}

void transactionUpdate(Transaction transaction, {${parameters.join()}}) {
  $asserts
  final json = {${json.join()}};

  transaction.update(reference, json);
}
''';
  }

  String _parent(CollectionData data) {
    final doc =
        '/// A reference to the [${data.collectionReferenceInterfaceName}] containing this document.';
    if (data.parent == null) {
      return '''
  $doc
  ${data.collectionReferenceInterfaceName} get parent {
    return ${data.collectionReferenceImplName}(reference.firestore);
  }
''';
    }

    final parent = data.parent!;
    return '''
  $doc
  ${data.collectionReferenceInterfaceName} get parent {
    return ${data.collectionReferenceImplName}(
      reference.parent.parent!.withConverter<${parent.type}>(
        fromFirestore: ${parent.collectionReferenceInterfaceName}.fromFirestore,
        toFirestore: ${parent.collectionReferenceInterfaceName}.toFirestore,
      ),
    );
  }
''';
  }

  String _subCollections(CollectionData data) {
    final buffer = StringBuffer();

    for (final child in data.children) {
      buffer.writeln(
        '''
  late final ${child.collectionReferenceInterfaceName} ${child.collectionName} = ${child.collectionReferenceImplName}(
    reference,
  );
''',
      );
    }

    return buffer.toString();
  }

  String _equalAndHashCode(CollectionData data) {
    final propertyNames = [
      'runtimeType',
      'parent',
      'id',
    ];

    return '''
  @override
  bool operator ==(Object other) {
    return other is ${data.documentReferenceName}
      && ${propertyNames.map((p) => 'other.$p == $p').join(' && ')};
  }

  @override
  int get hashCode => Object.hash(${propertyNames.join(',')});
''';
  }
}
