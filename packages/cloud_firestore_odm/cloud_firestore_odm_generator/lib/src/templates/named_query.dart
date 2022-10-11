import '../collection_generator.dart';

class NamedQueryTemplate {
  NamedQueryTemplate(this.data, this.globalData);

  final NamedQueryData data;
  final GlobalData globalData;

  @override
  String toString() {
    return '''
/// Adds [${data.namedQueryGetName}] to [FirebaseFirestore].
extension ${data.namedQueryExtensionName} on FirebaseFirestore {
  /// Performs [FirebaseFirestore.namedQueryGet] and decode the result into
  /// a [${data.type}] snashot.
  Future<${data.querySnapshotName}> ${data.namedQueryGetName}() async {
    final snapshot = await namedQueryGet(r'${data.queryName}');
    return ${data.querySnapshotName}._fromQuerySnapshot(snapshot);
  }
}
''';
  }
}
