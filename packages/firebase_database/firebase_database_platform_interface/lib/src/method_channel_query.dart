part of firebase_database_platform_interface;

class MethodChannelQuery extends Query {
  MethodChannelQuery({
    @required List<String> pathComponents,
    Map<String, dynamic> parameters,
  }) : super(
          pathComponents: pathComponents,
          parameters: parameters,
        );

  Stream<Event> _observe(EventType eventType) {
    Future<int> _handle;
    // It's fine to let the StreamController be garbage collected once all the
    // subscribers have cancelled; this analyzer warning is safe to ignore.
    StreamController<Event> controller; // ignore: close_sinks
    controller = StreamController<Event>.broadcast(
      onListen: () {
        _handle = MethodChannelDatabase.channel.invokeMethod<int>(
          'Query#observe',
          <String, dynamic>{
            'app': database.app?.name,
            'databaseURL': database.databaseURL,
            'path': path,
            'parameters': _parameters,
            'eventType': eventType.toString(),
          },
        ).then<int>((dynamic result) => result);
        _handle.then((int handle) {
          FirebaseDatabase._observers[handle] = controller;
        });
      },
      onCancel: () {
        _handle.then((int handle) async {
          await database._channel.invokeMethod<int>(
            'Query#removeObserver',
            <String, dynamic>{
              'app': database.app?.name,
              'databaseURL': database.databaseURL,
              'path': path,
              'parameters': _parameters,
              'handle': handle,
            },
          );
          FirebaseDatabase._observers.remove(handle);
        });
      },
    );
    return controller.stream;
  }

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(bool value) {
    return database._channel.invokeMethod<void>(
      'Query#keepSynced',
      <String, dynamic>{
        'app': database.app?.name,
        'databaseURL': database.databaseURL,
        'path': path,
        'parameters': _parameters,
        'value': value
      },
    );
  }
}
