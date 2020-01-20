part of firebase_database_web;

class OnDisconnectWeb extends OnDisconnect {
  firebase.OnDisconnect onDisconnect;
  OnDisconnectWeb(this.onDisconnect);

  @override
  Future<void> set(value, {priority}) {
    if (priority != null) return onDisconnect.set(value);
    return onDisconnect.setWithPriority(value, priority);
  }

  @override
  Future<void> remove() {
    // TODO: implement remove
    return super.remove();
  }

  @override
  Future<void> cancel() {
    return onDisconnect.cancel();
  }

  @override
  Future<void> update(Map<String, dynamic> values) {
    return onDisconnect.update(values);
  }
}
