part of firebase_database_web;

/// `Event` encapsulates a DataSnapshot and possibly also the key of its
/// previous sibling, which can be used to order the snapshots.
class EventWeb extends Event {
  EventWeb(firebase.QueryEvent event)
      : super(DataSnapshotWeb(event.snapshot), event.prevChildKey);
}

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshotWeb extends DataSnapshot {
  DataSnapshotWeb(firebase.DataSnapshot snapshot)
      : super(snapshot.key, snapshot.val());
}
