// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [Firestore.instance].
class MethodChannelFirestore extends FirestorePlatform {
  final FirebaseApp app;

  MethodChannelFirestore({FirebaseApp app})
      : this.app = app ?? FirebaseApp.instance {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'QuerySnapshot') {
        final QuerySnapshot snapshot = QuerySnapshot._(call.arguments, this);
        _queryObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DocumentSnapshot') {
        final DocumentSnapshot snapshot = DocumentSnapshot(
          call.arguments['path'],
          _asStringKeyedMap(call.arguments['data']),
          SnapshotMetadata(call.arguments['metadata']['hasPendingWrites'],
              call.arguments['metadata']['isFromCache']),
          this,
        );
        _documentObservers[call.arguments['handle']].add(snapshot);
      } else if (call.method == 'DoTransaction') {
        final int transactionId = call.arguments['transactionId'];
        final Transaction transaction = Transaction(transactionId, this);
        final dynamic result =
            await _transactionHandlers[transactionId](transaction);
        await transaction._finish();
        return result;
      }
    });
    _initialized = true;
  }

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.

  static bool _initialized = false;

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  static final Map<int, StreamController<QuerySnapshot>> _queryObservers =
      <int, StreamController<QuerySnapshot>>{};

  static final Map<int, StreamController<DocumentSnapshot>> _documentObservers =
      <int, StreamController<DocumentSnapshot>>{};

  static final Map<int, TransactionHandler> _transactionHandlers =
      <int, TransactionHandler>{};
  static int _transactionHandlerId = 0;

  @override
  CollectionReference collection(String path) {
    assert(path != null);
    return CollectionReference(this, path.split('/'));
  }

  @override
  Query collectionGroup(String path) {
    assert(path != null);
    assert(!path.contains("/"), "Collection IDs must not contain '/'.");
    return Query(
      firestore: this,
      isCollectionGroup: true,
      pathComponents: path.split('/'),
    );
  }

  @override
  DocumentReference document(String path) {
    assert(path != null);
    return DocumentReference(this, path.split('/'));
  }

  @override
  WriteBatch batch() => WriteBatch(this);

  @override
  Future<Map<String, dynamic>> runTransaction(
      TransactionHandler transactionHandler,
      {Duration timeout = const Duration(seconds: 5)}) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds');
    final int transactionId = _transactionHandlerId++;
    _transactionHandlers[transactionId] = transactionHandler;
    final Map<String, dynamic> result = await channel
        .invokeMapMethod<String, dynamic>(
            'Firestore#runTransaction', <String, dynamic>{
      'app': app.name,
      'transactionId': transactionId,
      'transactionTimeout': timeout.inMilliseconds
    });
    return result ?? <String, dynamic>{};
  }

  @override
  Future<void> enablePersistence(bool enable) async {
    assert(enable != null);
    await channel
        .invokeMethod<void>('Firestore#enablePersistence', <String, dynamic>{
      'app': app.name,
      'enable': enable,
    });
  }

  @override
  Future<void> settings(
      {bool persistenceEnabled,
      String host,
      bool sslEnabled,
      int cacheSizeBytes}) async {
    await channel.invokeMethod<void>('Firestore#settings', <String, dynamic>{
      'app': app.name,
      'persistenceEnabled': persistenceEnabled,
      'host': host,
      'sslEnabled': sslEnabled,
      'cacheSizeBytes': cacheSizeBytes,
    });
  }
  
  @override
  String appName() => app.name;
}
