part of firebase_auth;

class MultiFactor {
  MultiFactorPlatform _delegate;

  MultiFactor._(this._delegate);

  /// The users display name.
  ///
  /// Will be `null` if signing in anonymously or via password authentication.
  Future<MultiFactorSession> getSession() {
    return _delegate.getSession();
  }
}
