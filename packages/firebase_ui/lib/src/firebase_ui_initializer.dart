abstract class FirebaseUIInitializer<T> {
  Set<Type> get dependencies => {};

  Future<void> initialize();

  T resolveDependency<T>() {
    return DependencyManager.resolve<T>(runtimeType);
  }
}

class DependencyManager {
  static final Map<Type, Map<Type, FirebaseUIInitializer>> _deps = {};

  static void inject(
    FirebaseUIInitializer target,
    Map<Type, FirebaseUIInitializer> deps,
  ) {
    _deps[target.runtimeType] = deps;
  }

  static T resolve<T>(Type target) {
    return _deps[target]![T]! as T;
  }
}
