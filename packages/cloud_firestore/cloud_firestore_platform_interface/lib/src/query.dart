// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// Represents a query over the data at a particular location.
class QueryPlatform extends Query{
  QueryPlatform(
      {@required FirestorePlatform firestore,
      @required List<String> pathComponents,
      bool isCollectionGroup = false,
      Map<String, dynamic> parameters})
      :super(firestore: firestore, pathComponents: pathComponents, isCollectionGroup: isCollectionGroup, parameters: parameters);


  Query copyWithParameters(Map<String, dynamic> parameters) {
    return QueryPlatform(
      firestore: firestore,
      isCollectionGroup: isCollectionGroup,
      pathComponents: pathComponents,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(parameters)..addAll(parameters),
      ),
    );
  }
  
  // TODO(jackson): Reduce code duplication with [DocumentReference]
  @override
  Stream<QuerySnapshot> snapshots({bool includeMetadataChanges = false}) {
    assert(includeMetadataChanges != null);
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<QuerySnapshot> controller; // ignore: close_sinks
    controller = StreamController<QuerySnapshot>.broadcast(
      onListen: () {
        _handle = MethodChannelFirestore.channel.invokeMethod<int>(
          'Query#addSnapshotListener',
          <String, dynamic>{
            'app': firestore.appName(),
            'path': path,
            'isCollectionGroup': isCollectionGroup,
            'parameters': parameters,
            'includeMetadataChanges': includeMetadataChanges,
          },
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          MethodChannelFirestore._queryObservers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await MethodChannelFirestore.channel.invokeMethod<void>(
            'removeListener',
            <String, dynamic>{'handle': handle},
          );
          MethodChannelFirestore._queryObservers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// Fetch the documents for this query
  Future<QuerySnapshot> getDocuments(
      {Source source = Source.serverAndCache}) async {
    assert(source != null);
    final Map<dynamic, dynamic> data =
        await MethodChannelFirestore.channel.invokeMapMethod<String, dynamic>(
      'Query#getDocuments',
      <String, dynamic>{
        'app': firestore.appName(),
        'path': path,
        'isCollectionGroup': isCollectionGroup,
        'parameters': parameters,
        'source': _getSourceString(source),
      },
    );
    return QuerySnapshot(data, firestore);
  }
}
