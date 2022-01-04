part of firebase.database_interop;

@JS('Query')
abstract class QueryJsImpl {
  external ReferenceJsImpl get ref;

  external set ref(ReferenceJsImpl r);

  external PromiseJsImpl<DataSnapshotJsImpl> get();

  external QueryJsImpl startAt(value, [String key]);

  external QueryJsImpl startAfter(value, [String key]);

  external QueryJsImpl endAt(value, [String key]);

  external QueryJsImpl endBefore(value, [String key]);

  external QueryJsImpl equalTo(value, [String key]);

  external bool isEqual(QueryJsImpl other);

  external QueryJsImpl limitToFirst(int limit);

  external QueryJsImpl limitToLast(int limit);

  external void off([
    String eventType,
    dynamic Function(DataSnapshotJsImpl, [String]) callback,
    context,
  ]);

  external void Function() on(
    String eventType,
    dynamic Function(DataSnapshotJsImpl, [String]) callback, [
    cancelCallbackOrContext,
    context,
  ]);

  external PromiseJsImpl<dynamic> once(
    String eventType, [
    dynamic Function(DataSnapshotJsImpl, [String]) callback,
    successCallback,
    failureCallbackOrContext,
    context,
  ]);

  external QueryJsImpl orderByChild(String path);

  external QueryJsImpl orderByKey();

  external QueryJsImpl orderByPriority();

  external QueryJsImpl orderByValue();

  external Object toJSON();

  @override
  external String toString();
}
