part of firebase_database_platform_interface;

DataSnapshotPlatform _fromMapToPlatformSnapShot(Map snapshot) {
  return DataSnapshotPlatform(snapshot["key"], snapshot["value"]);
}

EventPlatform _fromMapToPlatformEvent(Map event) {
  return EventPlatform(
      _fromMapToPlatformSnapShot(event['snapshot']), event["EventPlatform"]);
}

DatabaseErrorPlatform _fromMapToPlatformDatabaseError(Map error) {
  return DatabaseErrorPlatform(
      error["code"], error["message"], error["details"]);
}
