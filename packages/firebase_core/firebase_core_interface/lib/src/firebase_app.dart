// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of 'firebase.dart';

/// Represents a single Firebase app instance.
///
/// You can get an instance by calling [Firebase.app()].
class FirebaseApp {
  /// A [FirebaseApp] instance can only be accessed from a call to `app()` on
  /// [FirebaseCore].
  ///
  /// This constructor ensures that the delegate instance it is
  /// constructed with is one which extends [FirebaseAppPlatform].
  FirebaseApp._(this._delegate) {
    FirebaseAppPlatform.verify(_delegate);
  }

  final FirebaseAppPlatform _delegate;

  /// Deletes this app and frees up system resources.
  ///
  /// Once deleted, any plugin functionality using this app instance will throw
  /// an error.
  ///
  /// Deleting the default app is not possible and throws an exception.
  Future<void> delete() async {
    final registry = _registries[name];
    if (registry != null) {
      await Future.wait(
        registry.values.map((service) {
          return service.dispose().catchError((_) {});
        }),
      );
    }

    await _delegate.delete();
    _registries.remove(name);
  }

  /// The name of this [FirebaseApp].
  String get name => _delegate.name;

  /// The [FirebaseOptions] this app was created with.
  FirebaseOptions get options => _delegate.options;

  /// Returns whether automatic data collection is enabled or disabled for this
  /// app.
  ///
  /// Automatic data collection can be enabled or disabled via `setAutomaticDataCollectionEnabled`.
  bool get isAutomaticDataCollectionEnabled =>
      _delegate.isAutomaticDataCollectionEnabled;

  /// Sets whether automatic data collection is enabled or disabled for this
  /// app.
  ///
  /// To check whether it is currently enabled or not, call [isAutomaticDataCollectionEnabled].
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) {
    return _delegate.setAutomaticDataCollectionEnabled(enabled);
  }

  /// Sets whether automatic resource management is enabled or disabled for this
  /// app.
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) {
    return _delegate.setAutomaticResourceManagementEnabled(enabled);
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseApp) return false;
    return other.name == name && other.options == options;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(name, options);

  @override
  String toString() => '$FirebaseApp($name)';

  static final Map<String, Map<Type, _RegisteredFirebaseService>> _registries =
      {};

  /// Registers a service instance for this app.
  void registerService<T extends FirebaseService>(
    T service, {
    Future<void> Function(T service)? dispose,
  }) {
    final registry = _registries.putIfAbsent(name, () => {});
    registry[T] = _RegisteredFirebaseService(
      service,
      dispose == null ? null : () => dispose(service),
    );
  }

  /// Returns the service registered for this app as [T], or creates it from
  /// the factory registered with `registerFirebaseServiceFactory`, or `null`
  /// when there is neither.
  T? getService<T extends FirebaseService>() {
    final registered = _registries[name]?[T]?.service;
    if (registered != null) {
      return registered as T;
    }
    final factory = _serviceFactories[T];
    if (factory == null) {
      return null;
    }
    final service = factory.create(this) as T;
    final registry = _registries.putIfAbsent(name, () => {});
    registry[T] = _RegisteredFirebaseService(
      service,
      factory.disposer(service),
    );
    return service;
  }
}

/// A marker interface for Firebase services that can be registered in [FirebaseApp].
abstract class FirebaseService {}

final Map<Type, _FirebaseServiceFactory> _serviceFactories = {};

/// Registers how to create a [T] for any [FirebaseApp] that has none
/// registered.
///
/// For Firebase packages that must be reachable through
/// [FirebaseApp.getService] before the app has used them, such as the Auth
/// implementation handing out the token of a user restored from a previous
/// launch. Plugin registrants call this before `main`, when no [FirebaseApp]
/// exists yet. Not for app code.
///
/// [create] runs on the first `getService<T>()` on an app, and the result is
/// registered for that app as if by [FirebaseApp.registerService], so later
/// lookups return the same instance and [FirebaseApp.delete] calls [dispose]
/// on it. A service registered with [FirebaseApp.registerService] always takes
/// precedence.
void registerFirebaseServiceFactory<T extends FirebaseService>(
  T Function(FirebaseApp app) create, {
  Future<void> Function(T service)? dispose,
}) {
  _serviceFactories[T] = _FirebaseServiceFactory<T>(create, dispose);
}

class _RegisteredFirebaseService {
  _RegisteredFirebaseService(this.service, this._dispose);

  final FirebaseService service;
  final Future<void> Function()? _dispose;

  Future<void> dispose() async {
    await _dispose?.call();
  }
}

class _FirebaseServiceFactory<T extends FirebaseService> {
  _FirebaseServiceFactory(this.create, this._dispose);

  final T Function(FirebaseApp app) create;
  final Future<void> Function(T service)? _dispose;

  /// The dispose callback for [service], bound the way
  /// [FirebaseApp.registerService] binds its own, or `null` when the factory
  /// registered none.
  Future<void> Function()? disposer(FirebaseService service) {
    final dispose = _dispose;
    return dispose == null ? null : () => dispose(service as T);
  }
}
