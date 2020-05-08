part of firebase_database_platform_interface;

/// Represents a query over the data at a particular location.
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  /// Create a [MethodChannelQuery] from [DatabaseReferencePlatform]
  MethodChannelOnDisconnect(
      {DatabasePlatform database, DatabaseReferencePlatform reference})
      : super(database: database, reference: reference);

  Future<void> set(dynamic value, {dynamic priority}) {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'OnDisconnect#set',
      <String, dynamic>{
        'app': database.appName(),
        'databaseURL': database.databaseURL,
        'path': reference.path,
        'value': value,
        'priority': priority
      },
    );
  }

  Future<void> remove() => set(null);

  Future<void> cancel() {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'OnDisconnect#cancel',
      <String, dynamic>{
        'app': database.appName(),
        'databaseURL': database.databaseURL,
        'path': reference.path,
      },
    );
  }

  Future<void> update(Map<String, dynamic> value) {
    return MethodChannelDatabase.channel.invokeMethod<void>(
      'OnDisconnect#update',
      <String, dynamic>{
        'app': database.appName(),
        'databaseURL': database.databaseURL,
        'path': reference.path,
        'value': value
      },
    );
  }
}
