import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/document_reference_web.dart';
import 'package:firebase/firestore.dart' as web;

class CollectionReferenceWeb extends CollectionReference {
  final web.Firestore webFirestore;
  final List<String> _pathComponents;

  CollectionReferenceWeb(
      this.webFirestore, FirestorePlatform firestore, this._pathComponents)
      : super(firestore, _pathComponents);

  @override
  DocumentReference parent() {
    if (_pathComponents.length < 2) {
      return null;
    }
    return DocumentReferenceWeb(
      webFirestore,
      firestore,
      (List<String>.from(_pathComponents)..removeLast()),
    );
  }

  @override
  DocumentReference document([String path]) {
    List<String> childPath;
    if (path == null) {
      final String key = AutoIdGenerator.autoId();
      childPath = List<String>.from(_pathComponents)..add(key);
    } else {
      childPath = List<String>.from(_pathComponents)..addAll(path.split(('/')));
    }
    return DocumentReferenceWeb(
      webFirestore,
      firestore,
      childPath,
    );
  }

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }
}
