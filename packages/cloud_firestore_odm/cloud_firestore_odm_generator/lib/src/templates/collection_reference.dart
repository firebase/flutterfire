// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../collection_data.dart';

class CollectionReferenceTemplate {
  CollectionReferenceTemplate(this.data);

  final CollectionData data;

  @override
  String toString() {
    final idKey = data.idKey;

    String fromFirestoreBody;
    String toFirestoreBody;
    if (idKey != null) {
      fromFirestoreBody =
          'return ${data.fromJson("{'$idKey': snapshot.id, ...?snapshot.data()}")};';
      toFirestoreBody =
          "return {...${data.toJson('value')}}..remove('$idKey');";
    } else {
      fromFirestoreBody = 'return ${data.fromJson('snapshot.data()!')};';
      toFirestoreBody = 'return ${data.toJson('value')};';
    }

    return '''
/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class ${data.collectionReferenceInterfaceName}
      implements
        ${data.queryReferenceInterfaceName},
        FirestoreCollectionReference<${data.type}, ${data.querySnapshotName}> {
  ${data.parent != null ? _subCollectionConstructors(data, asbtract: true) : _rootCollectionConstructors(data, abstract: true)}

  static ${data.type} fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    $fromFirestoreBody
  }
 
  static Map<String, Object?> toFirestore(
    ${data.type} value,
    SetOptions? options,
  ) {
    $toFirestoreBody
  }

  @override
  CollectionReference<${data.type}> get reference;

${_parentProperty(data, abstract: true)}

  @override
  ${data.documentReferenceName} doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<${data.documentReferenceName}> add(${data.type} value);
}

class ${data.collectionReferenceImplName}
      extends ${data.queryReferenceImplName}
      implements ${data.collectionReferenceInterfaceName} {
  ${data.parent != null ? _subCollectionConstructors(data) : _rootCollectionConstructors(data)}


${_parentProperty(data)}

  String get path => reference.path;

  @override
  CollectionReference<${data.type}> get reference => super.reference as CollectionReference<${data.type}>;

  @override
  ${data.documentReferenceName} doc([String? id]) {
    assert(
      id == null || id.split('/').length == 1,
      'The document ID cannot be from a different collection',
    );
    return ${data.documentReferenceName}(
      reference.doc(id),
    );
  }

  @override
  Future<${data.documentReferenceName}> add(${data.type} value) {
    return reference
      .add(value)
      .then((ref) => ${data.documentReferenceName}(ref));
  }

  ${_equalAndHashCode(data)}
}
''';
  }

  String _equalAndHashCode(CollectionData data) {
    final propertyNames = [
      'runtimeType',
      'reference',
    ];

    return '''
  @override
  bool operator ==(Object other) {
    return other is ${data.collectionReferenceImplName}
      && ${propertyNames.map((p) => 'other.$p == $p').join(' && ')};
  }

  @override
  int get hashCode => Object.hash(${propertyNames.join(', ')});
''';
  }

  String _parentProperty(CollectionData data, {bool abstract = false}) {
    if (data.parent == null) return '';

    if (abstract) {
      return '''
    /// A reference to the containing [${data.parent!.documentReferenceName}] if this is a subcollection.
    ${data.parent!.documentReferenceName} get parent;
''';
    }

    return '''
    @override
    final ${data.parent!.documentReferenceName} parent;
''';
  }

  String _subCollectionConstructors(
    CollectionData data, {
    bool asbtract = false,
  }) {
    final parent = data.parent!;

    final pathSplit = data.path.split('/');
    var path = '';
    var nextParent = 'parent';
    for (var i = pathSplit.length - 1; i >= 0; i--) {
      if (pathSplit[i] == '*') {
        path = '\${$nextParent.id}$path';
        nextParent = 'parent.$nextParent';
      }
    }

    if (asbtract) {
      return '''
        factory ${data.collectionReferenceInterfaceName}(
          DocumentReference<${parent.type}> parent,
        ) = ${data.collectionReferenceImplName};''';
    }

    return '''
  factory ${data.collectionReferenceImplName}(
    DocumentReference<${parent.type}> parent,
  ) {
    return ${data.collectionReferenceImplName}._(
      ${parent.documentReferenceName}(parent),
      parent
        .collection('${pathSplit.last}')
        .withConverter(
          fromFirestore: ${data.collectionReferenceInterfaceName}.fromFirestore,
          toFirestore: ${data.collectionReferenceInterfaceName}.toFirestore,
        ),
    );
  }

  ${data.collectionReferenceImplName}._(
    this.parent,
    CollectionReference<${data.type}> reference,
  ) : super(reference, \$referenceWithoutCursor: reference);
''';
  }

  String _rootCollectionConstructors(
    CollectionData data, {
    bool abstract = false,
  }) {
    if (abstract) {
      return '''
factory ${data.collectionReferenceInterfaceName}([
  FirebaseFirestore? firestore,
]) = ${data.collectionReferenceImplName};''';
    }

    return '''
  factory ${data.collectionReferenceImplName}([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return ${data.collectionReferenceImplName}._(
      firestore
        .collection('${data.path}')
        .withConverter(
          fromFirestore: ${data.collectionReferenceInterfaceName}.fromFirestore,
          toFirestore: ${data.collectionReferenceInterfaceName}.toFirestore,
        ),
    );
  }

  ${data.collectionReferenceImplName}._(
    CollectionReference<${data.type}> reference,
  ) : super(reference, \$referenceWithoutCursor: reference);
''';
  }
}
