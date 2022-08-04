import '../collection_generator.dart';
import 'template.dart';

class QueryDocumentSnapshotTemplate extends Template<CollectionData> {
  @override
  String generate(CollectionData data) {
    return '''
class ${data.queryDocumentSnapshotName} extends FirestoreQueryDocumentSnapshot<${data.type}> implements ${data.documentSnapshotName} {
  ${data.queryDocumentSnapshotName}._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<${data.type}> snapshot;

  @override
  ${data.documentReferenceName} get reference {
    return ${data.documentReferenceName}(snapshot.reference);
  }

  @override
  final ${data.type} data;
}
''';
  }
}
