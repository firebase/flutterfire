import 'dart:async';

import 'package:meta/meta.dart';

@visibleForTesting
final snapshotCache = <Object, _ReferenceConnection>{};

/// Cache and share the connection with native when fetching snapshots
/// on the same reference but in different locations.
///
/// While the connection with native is cached, this still purposefully creates
/// a new stream.
/// This new stream will immediately emits the latest value emitted, if any.
///
/// This ensures that no matter when a second listener is added to an existing
/// snapshot connection, the new listener still properly obtains the latest
/// data available.
Stream<Snapshot> getCachedConnection<Snapshot>(
  Object key,
  Stream<Snapshot> Function() create,
) {
  // A stream that emits the latest value emitted by the cached native connection
  // followed by new events from the native connection.
  // ignore: close_sinks, should be safe to not close the controller since all listeners are removed
  final controllerWithLastEvent = StreamController<Snapshot>.broadcast();

  StreamSubscription? connectionSub;

  controllerWithLastEvent.onListen = () {
    assert(
      !controllerWithLastEvent.isClosed,
      'Cannot reuse a .snapshot() stream after all of its '
      'listeners have been removed',
    );

    // Caches the connection with native and keep a reference on the
    // latest event emitted.
    final connection = snapshotCache.putIfAbsent(key, () {
      late _ReferenceConnection<Snapshot> connection;

      final nativeBridgeStream = create();

      late StreamSubscription sub;
      // ignore: close_sinks, should be safe to not close the controller since all listeners are removed
      final nativeController = StreamController<Snapshot>.broadcast();

      nativeController.onListen = () {
        sub = nativeBridgeStream.listen(
          (event) {
            connection.lastSnapshot = (data, error) => data(event);
            nativeController.add(event);
          },
          onError: (Object err, StackTrace? stack) {
            connection.lastSnapshot = (data, error) => error(err, stack);
            nativeController.addError(err, stack);
          },
        );
      };

      nativeController.onCancel = () {
        sub.cancel();
        // When all listeners on the native bridge are removed, remove the
        // entry from cache to avoid memory leaks
        snapshotCache.remove(key);
      };

      return connection = _ReferenceConnection<Snapshot>(
        nativeController.stream,
      );
    }) as _ReferenceConnection<Snapshot>;

    // if an event or error was previously emitted, send it to the new stream.
    connection.lastSnapshot?.call(
      controllerWithLastEvent.add,
      controllerWithLastEvent.addError,
    );

    connectionSub = connection.stream.listen(
      // manually piping "connection.stream" as addStream would prevent
      // calling "controllerWithLastEvent.close" early.
      // This is important because "controllerWithLastEvent" may be closed
      // but "connectio.stream" may continue emitting events.
      controllerWithLastEvent.add,
      onError: controllerWithLastEvent.addError,
      // no need to close the controller in "onDone" as
      // controllerWithLastEvent.onCancel will always be called before,
      // which closes the controller.
    );
  };

  controllerWithLastEvent.onCancel = () {
    // Delaying the cancellation by one event-loop frame to make sure that
    // we are reusing the existing native bridge connection when a snapshot is
    // used like:
    //
    // StreamBuilder(stream: reference.snapshots(), ...)
    //
    // In this scenarion, StreamBuilder would cancel the previous stream
    // subscription then listen to the new stream.
    // This would call the previous controller's onCancel **before** the new
    // controller's onListen. Which would clear the native bridge cache
    // when the expected behaviour is to reuse the connection.
    return Future(() {
      connectionSub?.cancel();
    });
  };

  return controllerWithLastEvent.stream;
}

class _ReferenceConnection<Snapshot> {
  _ReferenceConnection(this.stream);

  final Stream<Snapshot> stream;

  void Function(
    void Function(Snapshot event) data,
    void Function(Object error, StackTrace? stackTrace) error,
  )? lastSnapshot;
}

/// Represents a call to [_JsonQuery.snapshot] with all its parameters.
@immutable
class SnapshotParameter {
  SnapshotParameter(this.reference, this.includeMetadataChanges);

  final Object reference;
  final bool includeMetadataChanges;

  @override
  bool operator ==(Object other) =>
      other is SnapshotParameter &&
      other.reference == reference &&
      other.includeMetadataChanges == includeMetadataChanges;

  @override
  int get hashCode => reference.hashCode ^ includeMetadataChanges.hashCode;

  @override
  String toString() {
    return 'Params(includeMetadataChanges: $includeMetadataChanges, reference: $reference)';
  }
}
