import '../collection_generator.dart';
import 'template.dart';

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
  Future<${data.documentSnapshotName}> transactionGet(Transaction transaction) {
    return transaction.get(reference).then((snapshot) {
      return ${data.documentSnapshotName}._(
        snapshot,
        snapshot.data(),
      );
    });
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
        if (field.updatable)
          '${field.type.getDisplayString(withNullability: true)} ${field.name},'
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
      for (final field in data.updatableFields)
        'Object? ${field.name} = _sentinel,'
    ];

    // TODO support nested objects
    final json = [
      for (final field in data.updatableFields)
        """
        if (${field.name} != _sentinel)
          '${field.name}': ${field.name} as ${field.type},
        """
    ];

    return '''
Future<void> update({${parameters.join()}}) async {
  final json = {${json.join()}};

  return reference.update(json);
}

void transactionUpdate(Transaction transaction, {${parameters.join()}}) {
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
