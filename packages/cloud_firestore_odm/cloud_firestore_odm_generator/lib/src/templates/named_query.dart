import '../collection_generator.dart';
import '../named_query_data.dart';

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
  Future<${data.querySnapshotName}> ${data.namedQueryGetName}({
    GetOptions options = const GetOptions(),
  }) async {
    final snapshot = await namedQueryWithConverterGet(
      r'${data.queryName}',
      fromFirestore: ${data.collectionReferenceInterfaceName}.fromFirestore,
      toFirestore: ${data.collectionReferenceInterfaceName}.toFirestore,
      options: options,
    );
    return ${data.querySnapshotName}._fromQuerySnapshot(snapshot);
  }
}
''';
  }
}
