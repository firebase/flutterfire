import 'package:firebase_ui/src/dependency_manager.dart';

abstract class FirebaseUIInitializer<T> {
  final T? params;
  Set<Type> get dependencies => {};

  FirebaseUIInitializer(this.params);

  Future<void> initialize([T? params]);
  T resolveDependency<T>() {
    return DependencyManager.resolve<T>(runtimeType);
  }
}
