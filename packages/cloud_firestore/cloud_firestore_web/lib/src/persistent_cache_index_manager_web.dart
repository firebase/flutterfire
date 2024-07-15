import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'package:cloud_firestore_web/src/interop/firestore.dart'
    as firestore_interop;

class PersistentCacheIndexManagerWeb
    extends PersistentCacheIndexManagerPlatform {
  PersistentCacheIndexManagerWeb(
    this.delegate,
  ) : super();

  final firestore_interop.Firestore delegate;
  @override
  Future<void> enableIndexAutoCreation() async {
    return delegate.persistenceCacheIndexManagerRequest(
      PersistenceCacheIndexManagerRequest.enableIndexAutoCreation,
    );
  }

  @override
  Future<void> disableIndexAutoCreation() async {
    return delegate.persistenceCacheIndexManagerRequest(
      PersistenceCacheIndexManagerRequest.disableIndexAutoCreation,
    );
  }

  @override
  Future<void> deleteAllIndexes() async {
    return delegate.persistenceCacheIndexManagerRequest(
      PersistenceCacheIndexManagerRequest.deleteAllIndexes,
    );
  }
}
