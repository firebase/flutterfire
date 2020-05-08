part of firebase_database_web;

/// Web implementation for firebase [OnDisconnect]
class OnDisconnectWeb extends OnDisconnect {
  web.OnDisconnect _onDisconnect;

  OnDisconnectWeb._(this._onDisconnect);

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
