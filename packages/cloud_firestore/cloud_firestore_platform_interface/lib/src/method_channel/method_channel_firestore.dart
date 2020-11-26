// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'method_channel_collection_reference.dart';
import 'method_channel_document_reference.dart';
import 'method_channel_query.dart';
import 'method_channel_transaction.dart';
import 'method_channel_write_batch.dart';
import 'utils/firestore_message_codec.dart';
import 'utils/exception.dart';

/// The entry point for accessing a Firestore.
///
/// You can get an instance by calling [FirebaseFirestore.instance].
class MethodChannelFirebaseFirestore extends FirebaseFirestorePlatform {
  /// Create an instance of [MethodChannelFirebaseFirestore] with optional [FirebaseApp]
  MethodChannelFirebaseFirestore({FirebaseApp app}) : super(appInstance: app) {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'Transaction#attempt':
          return _handleTransactionAttempt(call.arguments);
          break;
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });
    _initialized = true;
  }

  static int _methodChannelHandleId = 0;

  /// The [Settings] for this [MethodChannelFirebaseFirestore] instance.
  Settings _settings = Settings();

  /// Increments and returns the next channel ID handler for Firestore.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  /// When a transaction is attempted, it sends a [MethodChannel] call.
  /// The user handler is executed, and the result or error is emitted via
  /// a stream to the [runTransaction] handler. Once the handler has completed,
  /// a response to continue (with commands) or abort the transaction is sent.
  Future<Map<String, dynamic>> _handleTransactionAttempt(
      Map<dynamic, dynamic> arguments) async {
    final int transactionId = arguments['transactionId'];
    final TransactionPlatform transaction =
        MethodChannelTransaction(transactionId, arguments["appName"]);
    final StreamController controller =
        _transactionStreamControllerHandlers[transactionId];

    try {
      dynamic result = await _transactionHandlers[transactionId](transaction);

      // Broadcast the result. This allows the [runTransaction] handler to update
      // the current result. We can't send the result to native, since in some
      // cases it could be a non-primitive which would lose it's context (e.g.
      // returning a [DocumentSnapshot]).
      // If the transaction re-runs, the result will be updated.
      controller.add(result);

      // Once the user Future has completed, send the commands to native
      // to process the transaction.
      return <String, dynamic>{
        'type': 'SUCCESS',
        'commands': transaction.commands,
      };
    } catch (error) {
      // Allow the [runTransaction] method to listen to an error.
      controller.addError(error);

      // Signal native that a user error occurred, and finish the
      // transaction
      return <String, dynamic>{
        'type': 'ERROR',
      };
    }
  }

  /// Attach a [FirebaseException] to a given [StreamController].
  static void forwardErrorToController(
      StreamController controller, Map<dynamic, dynamic> arguments) async {
    if (controller == null) {
      return;
    }

    if (arguments['error'] is Map) {
      // Map means its an error from Native.
      Map<String, dynamic> errorMap =
          Map<String, dynamic>.from(arguments['error']);

      FirebaseException exception = FirebaseException(
        plugin: 'cloud_firestore',
        code: errorMap['code'],
        message: errorMap['message'],
      );
      controller.addError(exception);
    } else {
      // A non-map value means the error occurred in Dart, e.g. a type conversion issue,
      // this means it is most likely a library issue that should be reported so
      // it can be fixed.
      controller.addError(arguments['error']);
    }
  }

  /// The [FirebaseApp] instance to which this [FirebaseDatabase] belongs.
  ///
  /// If null, the default [FirebaseApp] is used.

  static bool _initialized = false;

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_firestore',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  /// The [EventChannel] used for query snapshots
  static EventChannel querySnapshotChannel = EventChannel(
    'plugins.flutter.io/firebase_firestore/query',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  /// The [EventChannel] used for document snapshots
  static EventChannel documentSnapshotChannel = EventChannel(
    'plugins.flutter.io/firebase_firestore/document',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  /// The [EventChannel] used for snapshotsInSync
  static EventChannel snapshotsInSyncChannel = EventChannel(
    'plugins.flutter.io/firebase_firestore/snapshotsInSync',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  /// The [EventChannel] used for transaction
  static EventChannel transactionChannel = EventChannel(
    'plugins.flutter.io/firebase_firestore/transaction',
    StandardMethodCodec(FirestoreMessageCodec()),
  );

  /// Stores the users [TransactionHandlers] for usage when a transaction is
  /// running.
  static final Map<int, TransactionHandler> _transactionHandlers =
      <int, TransactionHandler>{};

  /// Stores a transactions [StreamController]
  static final Map<int, StreamController> _transactionStreamControllerHandlers =
      <int, StreamController>{};

  /// A locally stored index of the transactions. This is incrememented each
  /// time a user calls [runTransaction].
  static int _transactionHandlerId = 0;

  /// Gets a [FirebaseFirestorePlatform] with specific arguments such as a different
  /// [FirebaseApp].
  @override
  FirebaseFirestorePlatform delegateFor({FirebaseApp app}) {
    return MethodChannelFirebaseFirestore(app: app);
  }

  @override
  WriteBatchPlatform batch() => MethodChannelWriteBatch(this);

  @override
  Future<void> clearPersistence() async {
    try {
      await channel
          .invokeMethod<void>('Firestore#clearPersistence', <String, dynamic>{
        'firestore': this,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> enablePersistence(
      [PersistenceSettings persistenceSettings]) async {
    throw UnimplementedError(
        'enablePersistence() is only available for Web. Use [Settings.persistenceEnabled] for other platforms.');
  }

  @override
  CollectionReferencePlatform collection(String path) {
    return MethodChannelCollectionReference(this, path);
  }

  @override
  QueryPlatform collectionGroup(String path) {
    return MethodChannelQuery(this, path, isCollectionGroupQuery: true);
  }

  @override
  Future<void> disableNetwork() async {
    try {
      await channel
          .invokeMethod<void>('Firestore#disableNetwork', <String, dynamic>{
        'firestore': this,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  DocumentReferencePlatform doc(String path) {
    return MethodChannelDocumentReference(this, path);
  }

  @override
  Future<void> enableNetwork() async {
    try {
      await channel
          .invokeMethod<void>('Firestore#enableNetwork', <String, dynamic>{
        'firestore': this,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Stream<void> snapshotsInSync() {
    int handle = MethodChannelFirebaseFirestore.nextMethodChannelHandleId;

    StreamSubscription<dynamic> querySnapshotStream;
    StreamController<void> controller; // ignore: close_sinks

    controller = StreamController<void>.broadcast(
      onListen: () async {
        querySnapshotStream = MethodChannelFirebaseFirestore
            .snapshotsInSyncChannel
            .receiveBroadcastStream(
          <String, dynamic>{
            'handle': handle,
            'firestore': this,
          },
        ).listen((event) {
          if (event.containsKey('error')) {
            MethodChannelFirebaseFirestore.forwardErrorToController(
              controller,
              event,
            );
          } else {
            controller.add(null);
          }
        }, onError: (error, stack) {
          // TODO: Handle these conditions
        });
      },
      onCancel: () {
        querySnapshotStream?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    assert(timeout.inMilliseconds > 0,
        'Transaction timeout must be more than 0 milliseconds');

    final int transactionId = _transactionHandlerId++;

    if (Platform.isIOS || Platform.isMacOS) {
      StreamSubscription<dynamic> snapshotStream;
      StreamController streamController = StreamController();

      _transactionHandlers[transactionId] = transactionHandler;
      _transactionStreamControllerHandlers[transactionId] = streamController;

      streamController = StreamController<T>.broadcast(
        onListen: () async {
          snapshotStream = MethodChannelFirebaseFirestore.transactionChannel
              .receiveBroadcastStream(
            <String, dynamic>{
              'firestore': this,
              'transactionId': transactionId,
              'timeout': timeout.inMilliseconds
            },
          ).listen((event) async {
            if (event.containsKey('attempt')) {
              final attempt = event['attempt'];
              final int transactionId = attempt['transactionId'];
              final TransactionPlatform transaction =
                  MethodChannelTransaction(transactionId, attempt["appName"]);

              try {
                dynamic result =
                    await _transactionHandlers[transactionId](transaction);

                // TODO: What should happen with the result?

                await MethodChannelFirebaseFirestore.channel
                    .invokeMethod('Transaction#storeResult', <String, dynamic>{
                  'transactionId': transactionId,
                  'result': {
                    'type': 'SUCCESS',
                    'commands': transaction.commands,
                  },
                });

                streamController.add(result);
              } catch (error) {
                // Allow the [runTransaction] method to listen to an error.
                streamController.addError(error);

                // Signal native that a user error occurred, and finish the
                // transaction
                await MethodChannelFirebaseFirestore.channel
                    .invokeMethod('Transaction#storeResult', <String, dynamic>{
                  'transactionId': transactionId,
                  'result': {
                    'type': 'ERROR',
                  }
                });
              }
            } else {
              // controller.add(event);
            }
          }, onError: (error, stack) {
            // TODO: Handle these conditions
          });
        },
        onCancel: () {
          snapshotStream?.cancel();
        },
      );

      return streamController.stream.first;
    } else {
      StreamController streamController = StreamController();

      _transactionHandlers[transactionId] = transactionHandler;
      _transactionStreamControllerHandlers[transactionId] = streamController;

      T result;
      Object exception;

      // If the uses [TransactionHandler] throws an error, the stream broadcasts
      // it so we don't lose it's context.
      StreamSubscription subscription =
          streamController.stream.listen((Object data) {
        result = data;
      }, onError: (Object e) {
        exception = e;
      });

      // The #create call only resolves once all transaction attempts have succeeded
      // or something failed.
      await channel.invokeMethod<T>('Transaction#create', <String, dynamic>{
        'firestore': this,
        'transactionId': transactionId,
        'timeout': timeout.inMilliseconds
      }).catchError((Object e) {
        exception = e;
      });

      // The transaction has completed (may have errored), cleanup the stream
      await subscription.cancel();
      _transactionStreamControllerHandlers.remove(transactionId);

      if (exception != null) {
        if (exception is PlatformException) {
          return Future.error(platformExceptionToFirebaseException(exception));
        } else {
          return Future.error(exception);
        }
      }

      return result;
    }
  }

  @override
  Settings get settings {
    return _settings;
  }

  @override
  set settings(Settings settings) {
    _settings = settings;
  }

  @override
  Future<void> terminate() async {
    try {
      await channel.invokeMethod<void>('Firestore#terminate', <String, dynamic>{
        'firestore': this,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> waitForPendingWrites() async {
    try {
      await channel.invokeMethod<void>(
          'Firestore#waitForPendingWrites', <String, dynamic>{
        'firestore': this,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }
}
