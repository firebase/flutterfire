part of firebase_database_web;

class DataSnapshotWeb extends DataSnapshot {
  firebase.QueryEvent _queryEvent;

  DataSnapshotWeb(this._queryEvent);

  @override
  dynamic get value => _queryEvent.snapshot.val();

  @override
  String get key => _queryEvent.snapshot.key;
}
