part of firebase_database_web;

class OnDisconnectWeb extends OnDisconnect {
  firebase.OnDisconnect _onDisconnect;
  OnDisconnectWeb(this._onDisconnect);

  @override
  Future<void> set(value, {priority}) {
    if (priority != null) return _onDisconnect.set(value);
    return _onDisconnect.setWithPriority(value, priority);
  }

  @override
  Future<void> remove() {
    return _onDisconnect.remove();
  }

  @override
  Future<void> cancel() {
    return _onDisconnect.cancel();
  }

  @override
  Future<void> update(Map<String, dynamic> values) {
    return _onDisconnect.update(values);
  }
}
