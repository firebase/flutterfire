import 'package:firebase_ui/src/dependency_manager.dart';

abstract class FirebaseUIInitializer<T> {
  Set<Type> get dependencies => {};

  Future<void> initialize();

  T resolveDependency<T>() {
    return DependencyManager.resolve<T>(runtimeType);
  }
}
