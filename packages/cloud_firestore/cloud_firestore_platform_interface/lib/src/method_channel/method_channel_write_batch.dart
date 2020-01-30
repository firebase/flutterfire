// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
class WriteBatch extends WriteBatchPlatform {
  /// Create an instance of [WriteBatch]
  WriteBatch(this._firestore)
      : _handle = MethodChannelFirestore.channel.invokeMethod<dynamic>(
            'WriteBatch#create',
            <String, dynamic>{'app': _firestore.app.name}),
        super();

  final FirestorePlatform _firestore;
  Future<dynamic> _handle;
  final List<Future<dynamic>> _actions = <Future<dynamic>>[];

  @override
  Future<void> commit() async {
    _assertNotCommitted();

    _committed = true;
    await Future.wait<dynamic>(_actions);
    await MethodChannelFirestore.channel.invokeMethod<void>(
        'WriteBatch#commit', <String, dynamic>{'handle': await _handle});
  }

  @override
  void delete(DocumentReferencePlatform document) {
    _assertNotCommitted();

    _handle.then((dynamic handle) {
      _actions.add(
        MethodChannelFirestore.channel.invokeMethod<void>(
          'WriteBatch#delete',
          <String, dynamic>{
            'app': _firestore.app.name,
            'handle': handle,
            'path': document.path,
          },
        ),
      );
    });
  }

  @override
  void setData(DocumentReferencePlatform document, Map<String, dynamic> data,
      {bool merge = false}) {
    _assertNotCommitted();

    _handle.then((dynamic handle) {
      _actions.add(
        MethodChannelFirestore.channel.invokeMethod<void>(
          'WriteBatch#setData',
          <String, dynamic>{
            'app': _firestore.app.name,
            'handle': handle,
            'path': document.path,
            'data': FieldValuePlatform.serverDelegates(data),
            'options': <String, bool>{'merge': merge},
          },
        ),
      );
    });
  }

  @override
  void updateData(DocumentReferencePlatform document, Map<String, dynamic> data) {
    _assertNotCommitted();

    _handle.then((dynamic handle) {
      _actions.add(
        MethodChannelFirestore.channel.invokeMethod<void>(
          'WriteBatch#updateData',
          <String, dynamic>{
            'app': _firestore.app.name,
            'handle': handle,
            'path': document.path,
            'data': FieldValuePlatform.serverDelegates(data)
          },
        ),
      );
    });
  }

  void _assertNotCommitted() {
    if (_committed) {
      throw StateError(
          'This batch has already been committed and can no longer be changed.');
    }
  }
}
