abstract class FirebaseUIInitializer<T> {
  final T? params;

  FirebaseUIInitializer(this.params);

  Future<void> initialize([T? params]);
}
