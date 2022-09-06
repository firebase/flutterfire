import '../collection_generator.dart';
import 'template.dart';

class QuerySnapshotTemplate extends Template<CollectionData> {
  @override
  String generate(CollectionData data) {
    return '''
class ${data.querySnapshotName} extends FirestoreQuerySnapshot<${data.type}, ${data.queryDocumentSnapshotName}> {
  ${data.querySnapshotName}._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<${data.type}> snapshot;

  @override
  final List<${data.queryDocumentSnapshotName}> docs;

  @override
  final List<FirestoreDocumentChange<${data.documentSnapshotName}>> docChanges;
}
''';
  }
}
