// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:_flutterfire_internals/_flutterfire_internals.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/internal/pointer.dart';
import 'package:flutter/services.dart';

import 'method_channel_firestore.dart';
import 'utils/exception.dart';

/// An implementation of [DocumentReferencePlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelDocumentReference extends DocumentReferencePlatform {
  late Pointer _pointer;

  /// Creates a [DocumentReferencePlatform] that is implemented using [MethodChannel].
  MethodChannelDocumentReference(
    FirebaseFirestorePlatform firestore,
    String path,
    this.pigeonApp,
  ) : super(firestore, path) {
    _pointer = Pointer(path);
  }

  final FirestorePigeonFirebaseApp pigeonApp;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    try {
      await MethodChannelFirebaseFirestore.pigeonChannel.documentReferenceSet(
        pigeonApp,
        DocumentReferenceRequest(
          path: _pointer.path,
          data: data,
          option: PigeonDocumentOption(
            merge: options?.merge,
            mergeFields:
                options?.mergeFields?.map((e) => e.components).toList(),
          ),
        ),
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> update(Map<FieldPath, dynamic> data) async {
    try {
      await MethodChannelFirebaseFirestore.pigeonChannel
          .documentReferenceUpdate(
        pigeonApp,
        DocumentReferenceRequest(
          path: _pointer.path,
          data: data,
        ),
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<DocumentSnapshotPlatform> get(
      [GetOptions options = const GetOptions()]) async {
    try {
      final result = await MethodChannelFirebaseFirestore.pigeonChannel
          .documentReferenceGet(
        pigeonApp,
        DocumentReferenceRequest(
          path: _pointer.path,
          source: options.source,
          serverTimestampBehavior: options.serverTimestampBehavior,
        ),
      );

      return DocumentSnapshotPlatform(
        firestore,
        _pointer.path,
        result.data,
        result.metadata,
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> delete() async {
    try {
      await MethodChannelFirebaseFirestore.pigeonChannel
          .documentReferenceDelete(
        pigeonApp,
        DocumentReferenceRequest(
          path: _pointer.path,
        ),
      );
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Stream<DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    ServerTimestampBehavior serverTimestampBehavior =
        ServerTimestampBehavior.none,
  }) {
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    late StreamController<DocumentSnapshotPlatform>
        controller; // ignore: close_sinks

    StreamSubscription<dynamic>? snapshotStreamSubscription;
    controller = StreamController<DocumentSnapshotPlatform>.broadcast(
      onListen: () async {
        final observerId = await MethodChannelFirebaseFirestore.pigeonChannel
            .documentReferenceSnapshot(
                pigeonApp,
                DocumentReferenceRequest(
                  path: _pointer.path,
                  serverTimestampBehavior: serverTimestampBehavior,
                ),
                includeMetadataChanges);
        snapshotStreamSubscription =
            MethodChannelFirebaseFirestore.documentSnapshotChannel(observerId)
                .receiveGuardedBroadcastStream(
          onError: convertPlatformException,
        )
                .listen(
          (snapshot) {
            final PigeonDocumentSnapshot result =
                PigeonDocumentSnapshot.decode(snapshot);
            controller.add(
              DocumentSnapshotPlatform(
                firestore,
                result.path,
                result.data,
                result.metadata,
              ),
            );
          },
          onError: controller.addError,
        );
      },
      onCancel: () {
        snapshotStreamSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}
