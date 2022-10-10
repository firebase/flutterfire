part of firebase.database_interop;

@JS('Query')
abstract class QueryJsImpl {
  external ReferenceJsImpl get ref;

  external bool isEqual(QueryJsImpl other);

  external Object toJSON();

  @override
  external String toString();
}
