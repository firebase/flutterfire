part of firebase.database_interop;

@JS('DataSnapshot')
@anonymous
abstract class DataSnapshotJsImpl {
  external String get key;

  external set key(String s);

  external ReferenceJsImpl get ref;

  external set ref(ReferenceJsImpl r);

  external DataSnapshotJsImpl child(String path);

  external bool exists();

  external dynamic exportVal();

  external bool forEach(void Function(dynamic) action);

  external dynamic getPriority();

  external bool hasChild(String path);

  external bool hasChildren();

  external int numChildren();

  external dynamic val();

  external Object toJSON();
}
