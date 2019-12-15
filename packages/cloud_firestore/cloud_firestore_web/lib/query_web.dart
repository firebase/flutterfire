import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

class QueryWeb extends Query {
  final web.Firestore webFirestore;
  QueryWeb(
      this.webFirestore,
      {FirestorePlatform firestore,
      List<String> pathComponents,
      bool isCollectionGroup = false,
      Map<String, dynamic> parameters})
      : super(
            firestore: firestore,
            pathComponents: pathComponents,
            isCollectionGroup: isCollectionGroup,
            parameters: parameters);

  @override
  Query copyWithParameters(Map<String, dynamic> parameters) {
    return QueryWeb(
      webFirestore,
      firestore: firestore,
      isCollectionGroup: isCollectionGroup,
      pathComponents: pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(parameters)..addAll(parameters),
      ),
    );
  }
  
  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
//    Future<int> _handle;
//    // It's fine to let the StreamController be garbage collected once all the
//    // subscribers have cancelled; this analyzer warning is safe to ignore.
//    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    
  }
  
  @override
  Future<QuerySnapshot> getDocuments({Source source = Source.serverAndCache}) async {
  }
  
  QuerySnapshot _fromWeb(web.QuerySnapshot webSnapshot) {
    
  }
}
