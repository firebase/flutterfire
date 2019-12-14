import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

class DocumentReferenceWeb extends DocumentReference {
  final web.Firestore firestoreWeb;  
  DocumentReferenceWeb(this.firestoreWeb,FirestorePlatform firestore, List<String> pathComponents)
      : super(firestore, pathComponents);

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) {
    return firestoreWeb.doc(path).set(data, web.SetOptions(merge: merge));
  }

  @override
  Future<void> updateData(Map<String, dynamic> data) {
    return firestoreWeb.doc(path).update(data: data);
  }

  @override
  Future<DocumentSnapshot> get({Source source = Source.serverAndCache}) async {
    return _fromWeb(await firestoreWeb.doc(path).get());
  }

  @override
  Future<void> delete() {
    return firestoreWeb.doc(path).delete();
  }

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    return firestoreWeb
        .doc(path)
        .onSnapshot
        .map((web.DocumentSnapshot webSnapshot) => _fromWeb(webSnapshot));
  }
  
  DocumentSnapshot _fromWeb(web.DocumentSnapshot webSnapshot) => DocumentSnapshot(
      webSnapshot.ref.path,
      webSnapshot.data(),
      SnapshotMetadata(
        webSnapshot.metadata.hasPendingWrites,
        webSnapshot.metadata.fromCache,
      ),
      this.firestore);
}
