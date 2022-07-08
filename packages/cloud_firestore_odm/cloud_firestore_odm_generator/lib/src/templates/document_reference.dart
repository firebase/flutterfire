import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';

import '../collection_generator.dart';
import 'template.dart';

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
            if (subSubType.element2?.kind == ElementKind.ENUM) {
              _isEnumListMap = true;
            }
            // _isEnumListMap = subSubType.element2?.kind == ElementKind.ENUM;
          }
        } else if (subType.element2?.kind == ElementKind.ENUM) {
          _isEnumList = true;
        }
      }
    } else if (field.type.isDartCoreMap) {
      final _mapTypeArguments = (field.type as InterfaceType).typeArguments;
      for (final subSubType in _mapTypeArguments) {
        if (subSubType.element2?.kind == ElementKind.ENUM) {
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

class DocumentReferenceTemplate extends Template<CollectionData> {
  @override
  String generate(CollectionData data) {
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

  Future<void> set(${data.type} value);
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
    return reference.snapshots().map((snapshot) {
      return ${data.documentSnapshotName}._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<${data.documentSnapshotName}> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return ${data.documentSnapshotName}._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  ${_update(data)}

  Future<void> set(${data.type} value) {
    return reference.set(value);
  }

  ${_equalAndHashCode(data)}
}
''';
  }

  String _updatePrototype(CollectionData data) {
    if (data.updatableFields.isEmpty) return '';

    final parameters = [
      for (final field in data.updatableFields)
        if (field.updatable)
          '${field.type.getDisplayString(withNullability: true)} ${field.name},'
    ];

    return 'Future<void> update({${parameters.join()}});';
  }

  String _update(CollectionData data) {
    if (data.updatableFields.isEmpty) return '';

    final parameters = [
      for (final field in data.updatableFields)
        'Object? ${field.name} = _sentinel,'
    ];

    // TODO support nested objects
    var json = <String>[];

    for (final field in data.updatableFields) {
      if (FieldEnum(field).isEnumList) {
        json.add(
          '''
          if (${field.name} != _sentinel)
            "${field.name}": _enumConvertList(${field.name} as ${field.type}),
          ''',
        );
      } else if (FieldEnum(field).isEnumListMap) {
        json.add(
          '''
          if (${field.name} != _sentinel)
            "${field.name}": _enumConvertListMap(${field.name} as ${field.type}),
          ''',
        );
      } else {
        json.add(
          '''
          if (${field.name} != _sentinel)
            "${field.name}": ${field.name} as ${field.type},
          ''',
        );
      }
    }

    return '''
Future<void> update({${parameters.join()}}) async {
  final json = {${json.join()}};

  return reference.update(json);
}''';
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
